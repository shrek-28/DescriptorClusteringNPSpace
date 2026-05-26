import pandas as pd
from pathlib import Path

# =====================================================
# INPUT FILES
# =====================================================

# Representative mapping file
rep_map_file = "data/full_clustering/stratified/representative_molecules_for_docking.csv"

# Cluster size metadata
cluster_size_file = "data/full_clustering/stratified/validation_clusters_size_stratified.csv"

# Docking result files folder
results_folder = Path("data/representative_docking_results_files")

# =====================================================
# REPRESENTATIVE RESULT FILES
# =====================================================

result_files = {
    "medoid": results_folder / "medoid_results.csv",
    "centroid_closest": results_folder / "centroid_closest_results.csv",
    "diverse_1": results_folder / "diverse_1_results.csv",
    "diverse_2": results_folder / "diverse_2_results.csv",
    "diverse_3": results_folder / "diverse_3_results.csv",
    "diverse_4": results_folder / "diverse_4_results.csv",
    "diverse_5": results_folder / "diverse_5_results.csv"
}

# =====================================================
# LOAD REPRESENTATIVE MAP
# =====================================================

rep_df = pd.read_csv(rep_map_file)

# =====================================================
# LOAD CLUSTER SIZE INFO
# =====================================================

size_df = pd.read_csv(cluster_size_file)

# Keep only required columns
size_df = size_df[["cluster_id", "size_bin"]]

# =====================================================
# LOAD ALL DOCKING SCORES
# =====================================================

all_scores = []

for rep_type, filepath in result_files.items():

    df = pd.read_csv(filepath)

    # Normalize ligand IDs
    df["identifier"] = (
        df["Ligand"]
        .str.replace("minimized_", "", regex=False)
        .str.strip()
    )

    df = df.rename(columns={"Affinity (kcal/mol)": "affinity"})

    df["rep_type"] = rep_type

    all_scores.append(
        df[["identifier", "affinity", "rep_type"]]
    )

scores_df = pd.concat(all_scores, ignore_index=True)

# =====================================================
# MERGE REPRESENTATIVES WITH DOCKING SCORES
# =====================================================

merged = rep_df.merge(
    scores_df,
    on=["identifier", "rep_type"],
    how="left"
)

# =====================================================
# FIND BEST REPRESENTATIVE PER CLUSTER
# =====================================================
# Lower docking score = better

best_per_cluster = (
    merged
    .sort_values("affinity")
    .groupby("cluster", as_index=False)
    .first()
)

# =====================================================
# TABLE 1
# Count how many times each rep_type wins
# =====================================================

table1 = (
    best_per_cluster["rep_type"]
    .value_counts()
    .reset_index()
)

table1.columns = ["rep_type", "num_clusters_best"]

print("\n================ TABLE 1 ================\n")
print(table1)

# Save
table1.to_csv("data/representative_analytics/best_rep_counts.csv", index=False)

# =====================================================
# ADD SIZE BIN
# =====================================================

best_per_cluster = best_per_cluster.merge(
    size_df,
    left_on="cluster",
    right_on="cluster_id",
    how="left"
)

# =====================================================
# TABLE 2
# Stratified by cluster size
# =====================================================

table2 = (
    best_per_cluster
    .groupby(["size_bin", "rep_type"])
    .size()
    .reset_index(name="count")
    .pivot(index="size_bin", columns="rep_type", values="count")
    .fillna(0)
    .astype(int)
)

print("\n================ TABLE 2 ================\n")
print(table2)

# Save
table2.to_csv("data/representative_analytics/size_stratified_best_rep.csv")

# =====================================================
# OPTIONAL:
# FULL BEST REPRESENTATIVE TABLE
# =====================================================

best_per_cluster_output = best_per_cluster[
    [
        "cluster",
        "size_bin",
        "rep_type",
        "identifier",
        "affinity"
    ]
]

best_per_cluster_output.to_csv(
    "data/representative_analytics/best_representative_per_cluster.csv",
    index=False
)

print("\nSaved:")
print("- table1_best_rep_counts.csv")
print("- table2_size_stratified_best_rep.csv")
print("- best_representative_per_cluster.csv")