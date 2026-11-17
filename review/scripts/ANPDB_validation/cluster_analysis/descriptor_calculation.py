
import argparse
import os
import pandas as pd
from rdkit import Chem
from rdkit.Chem import Descriptors, Lipinski, rdMolDescriptors


def main():
    parser = argparse.ArgumentParser(
        description="Calculate molecular descriptors from a folder of SDF files."
    )

    parser.add_argument("--input", required=True, help="Folder containing SDF files")
    parser.add_argument("--output", required=True, help="Output CSV path")

    args = parser.parse_args()

    descriptor_cols = [
        "SMILES", "MolWt", "LogP", "AromaticRingCount",
        "FractionCSP3", "TPSA", "HBD", "HBA", "RotatableBonds"
    ]

    results = []

    sdf_files = [
        f for f in os.listdir(args.input)
        if f.lower().endswith(".sdf")
    ]

    print(f"Total SDF files found: {len(sdf_files)}")

    valid = 0
    invalid = 0

    for idx, filename in enumerate(sdf_files, 1):

        filepath = os.path.join(args.input, filename)
        print(f"[{idx}/{len(sdf_files)}] Processing {filename}")

        supplier = Chem.SDMolSupplier(
            filepath,
            removeHs=True,
            sanitize=True
        )

        for mol in supplier:

            if mol is None:
                invalid += 1
                continue

            identifier = (
                mol.GetProp("MoleculeID")
                if mol.HasProp("MoleculeID")
                else os.path.splitext(filename)[0]
            )

            descriptors = {
                "identifier": identifier,
                "SMILES": Chem.MolToSmiles(mol),
                "MolWt": Descriptors.MolWt(mol),
                "LogP": Descriptors.MolLogP(mol),
                "AromaticRingCount": rdMolDescriptors.CalcNumAromaticRings(mol),
                "FractionCSP3": rdMolDescriptors.CalcFractionCSP3(mol),
                "TPSA": Descriptors.TPSA(mol),
                "HBD": Lipinski.NumHDonors(mol),
                "HBA": Lipinski.NumHAcceptors(mol),
                "RotatableBonds": Lipinski.NumRotatableBonds(mol)
            }

            results.append(descriptors)
            valid += 1

    df = pd.DataFrame(
        results,
        columns=["identifier"] + descriptor_cols
    )

    df.to_csv(args.output, index=False)

    print("\nProcessing complete.")
    print(f"Valid molecules: {valid}")
    print(f"Invalid molecules: {invalid}")
    print(f"Results saved to: {args.output}")


if __name__ == "__main__":
    main()
