
import argparse
import pandas as pd
import numpy as np
import ast
import time
from rdkit import Chem
from rdkit.Chem.Scaffolds import MurckoScaffold


def main():
    parser = argparse.ArgumentParser(
        description="Generate cluster-level chemical profiles using Murcko scaffolds and molecular descriptors."
    )

    parser.add_argument("--descriptors", required=True, help="Complete descriptor matrix CSV")
    parser.add_argument("--clusters", required=True, help="Post-noise cluster molecule lists CSV")
    parser.add_argument("--representatives", required=True, help="Cluster representatives CSV")
    parser.add_argument("--output", required=True, help="Output CSV path")

    args = parser.parse_args()

    start_time = time.time()
    print("Loading files...")

    # Load files
    desc_df = pd.read_csv(args.descriptors)
    cluster_post_df = pd.read_csv(args.clusters)
    rep_df = pd.read_csv(args.representatives)

    descriptor_cols = [
        "MolWt", "LogP", "AromaticRingCount",
        "FractionCSP3", "TPSA", "HBD", "HBA", "RotatableBonds"
    ]

    # Murcko scaffold function
    def get_scaffold(smiles):
        mol = Chem.MolFromSmiles(smiles)
        if mol is None:
            return None
        scaffold = MurckoScaffold.GetScaffoldForMol(mol)
        return Chem.MolToSmiles(scaffold)

    print("Computing Murcko scaffolds...")
    desc_df["Murcko"] = desc_df["smiles"].apply(get_scaffold)

    results = []

    # Loop through clusters
    total_clusters = len(cluster_post_df)

    for idx, row in enumerate(cluster_post_df.itertuples(), 1):

        cluster_id = row.cluster_post
        print(f"[{idx}/{total_clusters}] Processing cluster {cluster_id}")

        mol_ids = ast.literal_eval(row.identifier)

        cluster_df = desc_df[
            desc_df["identifier"].isin(mol_ids)
        ].copy()

        if cluster_df.empty:
            continue

        cluster_result = {"cluster_id": cluster_id}

        # 1. Dominant Murcko scaffold
        scaffold_counts = cluster_df["Murcko"].value_counts()

        if len(scaffold_counts) > 0:
            dominant_scaffold = scaffold_counts.index[0]
            dominant_fraction = scaffold_counts.iloc[0] / len(cluster_df)
        else:
            dominant_scaffold = None
            dominant_fraction = np.nan

        cluster_result["dominant_scaffold"] = dominant_scaffold
        cluster_result["dominant_scaffold_fraction"] = dominant_fraction

        # 2. Descriptor summary
        for col in descriptor_cols:

            values = cluster_df[col].dropna()

            if len(values) == 0:
                cluster_result[f"{col}_mean"] = np.nan
                cluster_result[f"{col}_median"] = np.nan
                cluster_result[f"{col}_std"] = np.nan
                cluster_result[f"{col}_IQR"] = np.nan
                continue

            q1 = np.percentile(values, 25)
            q3 = np.percentile(values, 75)

            cluster_result[f"{col}_mean"] = np.mean(values)
            cluster_result[f"{col}_median"] = np.median(values)
            cluster_result[f"{col}_std"] = np.std(values)
            cluster_result[f"{col}_IQR"] = q3 - q1

        # 3. Representative molecules
        rep_subset = rep_df[rep_df["cluster"] == cluster_id]

        for _, rep_row in rep_subset.iterrows():

            rep_type = rep_row["rep_type"]
            rep_id = rep_row["identifier"]

            mol_row = desc_df[
                desc_df["identifier"] == rep_id
            ]

            if mol_row.empty:
                continue

            # Scaffold
            cluster_result[f"{rep_type}_Murcko"] = mol_row["Murcko"].values[0]

            # Descriptor values
            for col in descriptor_cols:
                cluster_result[f"{rep_type}_{col}"] = mol_row[col].values[0]

        results.append(cluster_result)

    # Save final table
    final_df = pd.DataFrame(results)
    final_df.to_csv(args.output, index=False)

    print(f"\nTotal clusters processed: {len(final_df)}")
    print(f"Results saved to: {args.output}")
    print(f"Done in {time.time() - start_time:.2f} seconds.")


if __name__ == "__main__":
    main()
