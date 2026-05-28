import os
import glob
import pandas as pd


def summarize_docking_folder(folder_path, output_file=None):

    summary = []

    pattern = os.path.join(folder_path, "*_results.csv")
    files = glob.glob(pattern)

    for file in files:

        filename = os.path.basename(file)
        cluster_id = filename.replace("_results.csv", "")

        df = pd.read_csv(file)

        affinity = pd.to_numeric(
            df["Affinity (kcal/mol)"],
            errors="coerce"
        ).dropna()

        if len(affinity) == 0:
            continue

        min_aff = affinity.min()
        max_aff = affinity.max()

        summary.append({
            "cluster_id": cluster_id,
            "n_molecules": len(affinity),
            "min_affinity": min_aff,
            "max_affinity": max_aff,
            "range_affinity": max_aff - min_aff,
            "mean_affinity": affinity.mean(),
            "median_affinity": affinity.median()
        })

    summary_df = pd.DataFrame(summary)

    if output_file:
        summary_df.to_csv(output_file, index=False)

    return summary_df

summary_df = summarize_docking_folder(folder_path="data/random_molecule_docking_results", output_file="data/representative_analytics/random_molecules_distribution.csv")
summary_df = summarize_docking_folder(folder_path="data/random_molecule_docking_results/small", output_file="data/representative_analytics/random_molecules_distribution_small.csv")
summary_df = summarize_docking_folder(folder_path="data/random_molecule_docking_results/medium", output_file="data/representative_analytics/random_molecules_distribution_medium.csv")
summary_df = summarize_docking_folder(folder_path="data/random_molecule_docking_results/large", output_file="data/representative_analytics/random_molecules_distribution_large.csv")
