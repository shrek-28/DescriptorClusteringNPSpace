import numpy as np
import pandas as pd
import os

# Config

OUTDIR = "/DATA/full_clustering_results"
RANDOM_SEED = 42
N_CLUSTERS_TOTAL = 20
MOLECULES_PER_CLUSTER = 25

np.random.seed(RANDOM_SEED)

# Load existing CSVs

cluster_sizes = pd.read_csv(f"{OUTDIR}/cluster_sizesnew.csv")
cluster_molecules = pd.read_csv(f"{OUTDIR}/cluster_molecules_postnew.csv")
representatives = pd.read_csv(
    f"{OUTDIR}/cluster_representatives_7_per_cluster.csv"
)

# Parse molecule lists safely
cluster_molecules["identifier"] = cluster_molecules["identifier"].apply(eval)


# cluster_id is index in your CSV
cluster_sizes = cluster_sizes.reset_index()
cluster_sizes.rename(columns={"index": "cluster_id"}, inplace=True)

# Remove noise cluster if present
cluster_sizes = cluster_sizes[cluster_sizes["cluster_id"] != -1]

# Stratify clusters by SIZE ONLY

cluster_sizes["size_bin"] = pd.qcut(
    cluster_sizes["post_size"],
    q=3,
    labels=["small", "medium", "large"]
)

# Target distribution (sums to 20)
bin_targets = {
    "small": 7,
    "medium": 7,
    "large": 6
}

selected_clusters = []

for size_bin, n_target in bin_targets.items():
    subset = cluster_sizes[cluster_sizes["size_bin"] == size_bin]

    sampled = subset.sample(
        n=min(n_target, len(subset)),
        random_state=RANDOM_SEED
    )

    selected_clusters.append(sampled)

selected_clusters = pd.concat(selected_clusters)

selected_cluster_ids = selected_clusters["cluster_id"].tolist()

# Save selected clusters
selected_clusters.to_csv(
    f"DATA/full_clustering_stratified/validation_clusters_size_stratified.csv",
    index=False
)

# Sample RANDOM molecules per selected cluster

random_rows = []

for cid in selected_cluster_ids:
    mols = cluster_molecules.loc[
        cluster_molecules["cluster_post"] == cid,
        "identifier"
    ].iloc[0]

    n = min(MOLECULES_PER_CLUSTER, len(mols))
    sampled = np.random.choice(mols, size=n, replace=False)

    for m in sampled:
        random_rows.append({
            "cluster_id": cid,
            "identifier": m
        })

random_molecules_df = pd.DataFrame(random_rows)

random_molecules_df.to_csv(
    f"DATA/full_clustering_stratified/random_molecules_for_docking.csv",
    index=False
)

# Prepare representative molecules (subset to validation clusters)

rep_validation = representatives[
    representatives["cluster"].isin(selected_cluster_ids)
].copy()

rep_validation.to_csv(
    f"DATA/full_clustering_stratified//representative_molecules_for_docking.csv",
    index=False
)

# Create ONE unified docking list (random + reps)

all_molecules = pd.concat([
    random_molecules_df[["identifier"]],
    rep_validation[["identifier"]]
]).drop_duplicates()

all_molecules.to_csv(
    f"{OUTDIR}/ALL_molecules_for_docking.txt",
    index=False,
    header=False
)

# Final summary

print("VALIDATION DATASET PREPARED\n")

print("Clusters selected:", len(selected_cluster_ids))
print("Random molecules:", len(random_molecules_df))
print("Representative molecules:", rep_validation["identifier"].nunique())
print("Total unique molecules to dock:", len(all_molecules))

print("\nSaved files:")
print(" - validation_clusters_size_stratified.csv")
print(" - random_molecules_for_docking.csv")
print(" - representative_molecules_for_docking.csv")
print(" - ALL_molecules_for_docking.txt")