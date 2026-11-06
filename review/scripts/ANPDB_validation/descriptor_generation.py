
import argparse
import numpy as np
import pandas as pd
import networkx as nx

from pathlib import Path
from itertools import combinations

from rdkit import Chem
from rdkit.Chem import Descriptors, Descriptors3D, rdMolDescriptors
from rdkit.Chem.EState.EState import EStateIndices


# ============================================================
# DESCRIPTOR OUTPUT
# ============================================================

COLUMNS = [
    "identifier",
    "AromaticRingCount",
    "BridgeheadAtomCount",
    "HeteroatomCount",
    "StereocenterCount",
    "TripleBondCount",
    "PMI1",
    "PMI2",
    "SpherocityIndex",
    "InertialShapeFactor",
    "Max_EState",
    "Min_EState",
    "Avg_EState",
    "Carbonyl",
    "Largest_ring_size",
    "BertzCTIndex",
    "AtomInformationContent",
    "TPSA",
    "GraphDistanceDistributionEntropy",
    "PathComplexityIndex",
    "ShapeIndex"
]


# ============================================================
# E-STATE DESCRIPTORS
# ============================================================

def calculate_estate_descriptors(mol):

    values = EStateIndices(mol)

    if len(values) == 0:
        return np.nan, np.nan, np.nan

    return (
        float(np.max(values)),
        float(np.min(values)),
        float(np.mean(values))
    )


# ============================================================
# MOLECULAR GRAPH
# ============================================================

def build_graph(mol):

    G = nx.Graph()

    for atom in mol.GetAtoms():
        G.add_node(
            atom.GetIdx(),
            symbol=atom.GetSymbol()
        )

    for bond in mol.GetBonds():
        G.add_edge(
            bond.GetBeginAtomIdx(),
            bond.GetEndAtomIdx(),
            order=float(bond.GetBondTypeAsDouble())
        )

    return G


# ============================================================
# ATOM INFORMATION CONTENT
# ============================================================

def atom_information_content(G):

    if G.number_of_nodes() == 0:
        return 0.0

    symbols = [
        data["symbol"]
        for _, data in G.nodes(data=True)
    ]

    _, counts = np.unique(
        symbols,
        return_counts=True
    )

    probabilities = counts / counts.sum()

    return float(
        -(probabilities * np.log2(probabilities)).sum()
    )


# ============================================================
# GRAPH DISTANCE DISTRIBUTION ENTROPY
# ============================================================

def distance_distribution_entropy(G):

    if G.number_of_nodes() < 2:
        return 0.0

    largest_component = max(
        nx.connected_components(G),
        key=len
    )

    H = G.subgraph(largest_component)

    if H.number_of_nodes() < 2:
        return 0.0

    shortest_paths = dict(
        nx.all_pairs_shortest_path_length(H)
    )

    nodes = list(H.nodes())

    distances = [
        shortest_paths[u][v]
        for u, v in combinations(nodes, 2)
    ]

    if not distances:
        return 0.0

    _, counts = np.unique(
        distances,
        return_counts=True
    )

    probabilities = counts / counts.sum()

    return float(
        -(probabilities * np.log2(probabilities)).sum()
    )


# ============================================================
# PATH COMPLEXITY INDEX
# ============================================================

def path_complexity_index(G, max_len=3):

    n = G.number_of_nodes()

    if n == 0:
        return 0.0

    total_paths = 0

    nodes = list(G.nodes())

    for source, target in combinations(nodes, 2):

        paths = nx.all_simple_paths(
            G,
            source,
            target,
            cutoff=max_len
        )

        total_paths += sum(1 for _ in paths)

    return float(total_paths / n)


# ============================================================
# MAIN DESCRIPTOR CALCULATION
# ============================================================

def calculate_descriptors(sdf_mol, identifier):

    if sdf_mol is None:
        raise ValueError("Invalid SDF molecule")

    if sdf_mol.GetNumConformers() == 0:
        raise ValueError("No 3D coordinates found")

    # --------------------------------------------------------
    # 1. Preserve original 3D molecule
    # --------------------------------------------------------

    mol_3d = sdf_mol

    # --------------------------------------------------------
    # 2. Convert to canonical isomeric SMILES
    # --------------------------------------------------------

    mol_no_h = Chem.RemoveHs(mol_3d)

    smiles = Chem.MolToSmiles(
        mol_no_h,
        canonical=True,
        isomericSmiles=True
    )

    mol = Chem.MolFromSmiles(smiles)

    if mol is None:
        raise ValueError("SMILES conversion failed")

    # --------------------------------------------------------
    # 3. E-State descriptors
    # --------------------------------------------------------

    max_estate, min_estate, avg_estate = (
        calculate_estate_descriptors(mol)
    )

    # --------------------------------------------------------
    # 4. Molecular graph descriptors
    # --------------------------------------------------------

    G = build_graph(mol)

    atom_information = atom_information_content(G)

    distance_entropy = distance_distribution_entropy(G)

    path_complexity = path_complexity_index(
        G,
        max_len=3
    )

    # --------------------------------------------------------
    # 5. Ring descriptors
    # --------------------------------------------------------

    atom_rings = mol.GetRingInfo().AtomRings()

    largest_ring_size = max(
        (len(ring) for ring in atom_rings),
        default=0
    )

    # --------------------------------------------------------
    # 6. Carbonyl count
    # --------------------------------------------------------

    carbonyl_pattern = Chem.MolFromSmarts(
        "[CX3]=[OX1]"
    )

    carbonyl_count = len(
        mol.GetSubstructMatches(carbonyl_pattern)
    )

    # --------------------------------------------------------
    # 7. 3D descriptors
    # --------------------------------------------------------

    pmi1 = Descriptors3D.PMI1(mol_3d)

    pmi2 = Descriptors3D.PMI2(mol_3d)

    spherocity = Descriptors3D.SpherocityIndex(
        mol_3d
    )

    inertial_shape = Descriptors3D.InertialShapeFactor(
        mol_3d
    )

    # Retain original pipeline definition
    shape_index = inertial_shape

    # --------------------------------------------------------
    # 8. Remaining molecular descriptors
    # --------------------------------------------------------

    aromatic_ring_count = (
        rdMolDescriptors.CalcNumAromaticRings(mol)
    )

    bridgehead_count = (
        rdMolDescriptors.CalcNumBridgeheadAtoms(mol)
    )

    heteroatom_count = (
        rdMolDescriptors.CalcNumHeteroatoms(mol)
    )

    stereocenter_count = len(
        Chem.FindMolChiralCenters(
            mol,
            includeUnassigned=True
        )
    )

    triple_bond_count = sum(
        1
        for bond in mol.GetBonds()
        if bond.GetBondType() == Chem.BondType.TRIPLE
    )

    bertz_ct = Descriptors.BertzCT(mol)

    tpsa = rdMolDescriptors.CalcTPSA(mol)

    # --------------------------------------------------------
    # 9. Return descriptors
    # --------------------------------------------------------

    return {

        "identifier": identifier,

        "AromaticRingCount": aromatic_ring_count,

        "BridgeheadAtomCount": bridgehead_count,

        "HeteroatomCount": heteroatom_count,

        "StereocenterCount": stereocenter_count,

        "TripleBondCount": triple_bond_count,

        "PMI1": pmi1,

        "PMI2": pmi2,

        "SpherocityIndex": spherocity,

        "InertialShapeFactor": inertial_shape,

        "Max_EState": max_estate,

        "Min_EState": min_estate,

        "Avg_EState": avg_estate,

        "Carbonyl": carbonyl_count,

        "Largest_ring_size": largest_ring_size,

        "BertzCTIndex": bertz_ct,

        "AtomInformationContent": atom_information,

        "TPSA": tpsa,

        "GraphDistanceDistributionEntropy": distance_entropy,

        "PathComplexityIndex": path_complexity,

        "ShapeIndex": shape_index
    }


# ============================================================
# PROCESS SDF DIRECTORY
# ============================================================

def process_directory(input_dir, output_file):

    input_dir = Path(input_dir)
    output_file = Path(output_file)

    output_file.parent.mkdir(
        parents=True,
        exist_ok=True
    )

    sdf_files = sorted(
        input_dir.glob("*.sdf")
    )

    print(f"Total SDF files: {len(sdf_files)}")

    results = []
    failed = []

    for i, sdf_file in enumerate(sdf_files, 1):

        try:

            supplier = Chem.SDMolSupplier(
                str(sdf_file),
                removeHs=False,
                sanitize=True
            )

            valid_records = 0

            for record_idx, mol in enumerate(supplier):

                if mol is None:
                    raise ValueError(
                        f"Invalid SDF record: {record_idx + 1}"
                    )

                # Prefer an identifier stored in the SDF.
                if mol.HasProp("identifier"):
                    identifier = mol.GetProp("identifier")
                elif mol.HasProp("IDENTIFIER"):
                    identifier = mol.GetProp("IDENTIFIER")
                elif len(supplier) > 1:
                    identifier = (
                        f"{sdf_file.stem}_{record_idx + 1}"
                    )
                else:
                    identifier = sdf_file.stem

                descriptors = calculate_descriptors(
                    mol,
                    identifier
                )

                results.append(descriptors)
                valid_records += 1

            if valid_records == 0:
                raise ValueError("No valid molecules found")

            print(
                f"[{i}/{len(sdf_files)}] SUCCESS: "
                f"{sdf_file.name}"
            )

        except Exception as e:

            failed.append({
                "identifier": sdf_file.stem,
                "error": str(e)
            })

            print(
                f"[{i}/{len(sdf_files)}] FAILED: "
                f"{sdf_file.name} | {e}"
            )

    # --------------------------------------------------------
    # Save descriptor results
    # --------------------------------------------------------

    df = pd.DataFrame(
        results,
        columns=COLUMNS
    )

    df.to_csv(
        output_file,
        index=False
    )

    # --------------------------------------------------------
    # Save failed molecules
    # --------------------------------------------------------

    if failed:

        failed_df = pd.DataFrame(failed)

        failed_df.to_csv(
            output_file.parent / "failed_molecules.csv",
            index=False
        )

    # --------------------------------------------------------
    # Summary
    # --------------------------------------------------------

    print("\n" + "=" * 50)
    print("DESCRIPTOR CALCULATION COMPLETED")
    print("=" * 50)

    print(f"Total input files: {len(sdf_files)}")
    print(f"Successful molecules: {len(results)}")
    print(f"Failed files: {len(failed)}")
    print(f"Descriptors calculated: {len(COLUMNS) - 1}")
    print(f"Output: {output_file}")

    return df


# ============================================================
# MAIN
# ============================================================

if __name__ == "__main__":

    parser = argparse.ArgumentParser(
        description="Calculate 20 molecular descriptors from 3D SDF files"
    )

    parser.add_argument(
        "--input",
        required=True,
        help="Directory containing 3D SDF files"
    )

    parser.add_argument(
        "--output",
        required=True,
        help="Output descriptor CSV"
    )

    args = parser.parse_args()

    process_directory(
        args.input,
        args.output
    )
