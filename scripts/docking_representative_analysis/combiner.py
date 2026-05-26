import pandas as pd
import glob
import os

# =========================================================
# INPUT FILES
# =========================================================

# Mapping file
mapping_file = "data/full_clustering/stratified/representative_molecules_for_docking.csv"

# Cluster size file
size_file = "data/full_clustering/stratified/validation_clusters_size_stratified.csv"

# Folder containing:
# - medoid_results.csv
# - centroid_closest_results.csv
# - diverse_1_results.csv ... diverse_5_results.csv
results_dir = "data/representative_docking_results_files"

# Output
output_file = "data/representative_analytics/combined_representative_affinity_analysis.csv"

# =========================================================
# LOAD FILES
# =========================================================

mapping_df = pd.read_csv(mapping_file)
size_df = pd.read_csv(size_file)

# =========================================================
# LOAD ALL RESULT FILES
# =========================================================

result_files = glob.glob(os.path.join(results_dir, "*_results.csv"))

all_results = []

for file in result_files:

    rep_type = os.path.basename(file).replace("_results.csv", "")

    df = pd.read_csv(file)

    # Standardize ligand ID
    df["identifier"] = (
        df["Ligand"]
        .str.replace("minimized_", "", regex=False)
        .str.strip()
    )

    df = df.rename(columns={"Affinity (kcal/mol)": "affinity"})

    df["rep_type"] = rep_type

    all_results.append(df[["identifier", "affinity", "rep_type"]])

results_df = pd.concat(all_results, ignore_index=True)

# =========================================================
# MERGE MAPPING + SCORES
# =========================================================

merged_df = mapping_df.merge(
    results_df,
    on=["identifier", "rep_type"],
    how="left"
)

# =========================================================
# ADD SIZE INFORMATION
# =========================================================

size_df = size_df.rename(columns={"cluster_id": "cluster"})

merged_df = merged_df.merge(
    size_df[["cluster", "size_bin", "core_size", "post_size"]],
    on="cluster",
    how="left"
)

# =========================================================
# OPTIONAL COLUMN ORDER
# =========================================================

merged_df = merged_df[
    [
        "cluster",
        "size_bin",
        "core_size",
        "post_size",
        "rep_type",
        "identifier",
        "affinity"
    ]
]

# =========================================================
# SAVE
# =========================================================

merged_df.to_csv(output_file, index=False)

print(f"Saved: {output_file}")