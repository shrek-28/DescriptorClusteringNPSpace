import pandas as pd
import numpy as np
from scipy.spatial import ConvexHull
from scipy.spatial.distance import cdist
import ast
import time
from numpy.linalg import det

# =========================
# Start timing
# =========================
start_time = time.time()

print("Loading files...")

umap_df = pd.read_csv("DATA/full_clustering_results/umap_with_clusters.csv")
centroid_df = pd.read_csv("DATA/full_clustering_results/cluster_centroids.csv")
medoid_df = pd.read_csv("DATA/full_clustering_results/cluster_medoids.csv")
core_mols_df = pd.read_csv("DATA/full_clustering_results/cluster_molecules_core.csv")
post_mols_df = pd.read_csv("DATA/full_clustering_results/cluster_molecules_post.csv")

umap_cols = [f"UMAP_{i}" for i in range(12)]

results = []

total_clusters = len(centroid_df)
print(f"Total clusters to process: {total_clusters}")

# =========================
# Loop through clusters
# =========================
for idx, cluster_id in enumerate(centroid_df["cluster_post"], 1):

    cluster_start = time.time()
    print(f"[{idx}/{total_clusters}] Processing cluster {cluster_id}...")

    # ---- Centroid
    centroid = centroid_df.loc[
        centroid_df["cluster_post"] == cluster_id,
        umap_cols
    ].values

    if len(centroid) == 0:
        continue

    # ---- Molecule lists
    post_row = post_mols_df[post_mols_df["cluster_post"] == cluster_id]
    core_row = core_mols_df[core_mols_df["cluster_core"] == cluster_id]

    if post_row.empty:
        continue

    post_ids = ast.literal_eval(post_row["identifier"].values[0])
    core_ids = ast.literal_eval(core_row["identifier"].values[0]) if not core_row.empty else []

    # ---- Coordinates
    post_coords = umap_df[umap_df["identifier"].isin(post_ids)][umap_cols].values

    if len(post_coords) == 0:
        continue
    

    # =========================================================
    # 1. Medoid–centroid distance
    # =========================================================
    medoid_row = medoid_df[medoid_df["cluster"] == cluster_id]

    if medoid_row.empty:
        medoid_centroid_dist = np.nan
    else:
        medoid_id = medoid_row["medoid_identifier"].values[0]
        medoid_coords = umap_df[umap_df["identifier"] == medoid_id][umap_cols].values
        medoid_centroid_dist = np.linalg.norm(medoid_coords - centroid) if len(medoid_coords) > 0 else np.nan

    # =========================================================
    # 2. Intra-cluster spread (post)
    # =========================================================
    distances_post = cdist(post_coords, centroid)
    mean_post = np.mean(distances_post)
    std_post = np.std(distances_post)

    # =========================================================
    # 3. Core spread
    # =========================================================
    if len(core_ids) > 0:
        core_coords = umap_df[umap_df["identifier"].isin(core_ids)][umap_cols].values
        distances_core = cdist(core_coords, centroid)
        mean_core = np.mean(distances_core)
        std_core = np.std(distances_core)
    else:
        mean_core = np.nan
        std_core = np.nan


    # =========================================================
    # 4B. Covariance-based volume proxy (robust alternative)
    # determinant of covariance matrix
    # =========================================================
    if len(post_coords) > 12:
        cov_matrix = np.cov(post_coords, rowvar=False)
        try:
            cov_volume = np.sqrt(det(cov_matrix))
        except:
            cov_volume = np.nan
    else:
        cov_volume = np.nan

    # =========================================================
    # 5. Density gradient
    # =========================================================
    density_gradient = mean_post - mean_core if not np.isnan(mean_core) else np.nan

    results.append({
        "cluster_id": cluster_id,
        "medoid_centroid_distance": medoid_centroid_dist,
        "mean_distance_post": mean_post,
        "std_distance_post": std_post,
        "mean_distance_core": mean_core,
        "std_distance_core": std_core,
        "covariance_volume": cov_volume,
        "density_gradient": density_gradient
    })


    cluster_time = time.time() - cluster_start
    print(f"Cluster {cluster_id} done in {cluster_time:.2f} sec")

# =========================
# Save results
# =========================
final_metrics = pd.DataFrame(results)
final_metrics.to_csv("DATA/cluster_profiling/cluster_structural_metrics_12D_full.csv", index=False)

total_time = time.time() - start_time
print(f"\nAll clusters processed in {total_time:.2f} seconds.")