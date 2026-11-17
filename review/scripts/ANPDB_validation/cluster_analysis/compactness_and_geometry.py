
import argparse
import pandas as pd
import numpy as np
from scipy.spatial.distance import cdist
import ast
import time
from numpy.linalg import det


def main():
    parser = argparse.ArgumentParser(
        description="Calculate structural metrics for HDBSCAN clusters in UMAP space."
    )

    parser.add_argument("--umap", required=True, help="UMAP coordinates with cluster assignments")
    parser.add_argument("--centroids", required=True, help="Cluster centroids CSV")
    parser.add_argument("--medoids", required=True, help="Cluster medoids CSV")
    parser.add_argument("--core-mols", required=True, help="Core cluster molecule lists CSV")
    parser.add_argument("--post-mols", required=True, help="Post-noise cluster molecule lists CSV")
    parser.add_argument("--output", required=True, help="Output CSV path")
    parser.add_argument("--n-components", type=int, default=12, help="Number of UMAP dimensions (default: 12)")

    args = parser.parse_args()

    start_time = time.time()

    print("Loading files...")

    umap_df = pd.read_csv(args.umap)
    centroid_df = pd.read_csv(args.centroids)
    medoid_df = pd.read_csv(args.medoids)
    core_mols_df = pd.read_csv(args.core_mols)
    post_mols_df = pd.read_csv(args.post_mols)

    umap_cols = [f"UMAP_{i}" for i in range(args.n_components)]

    results = []

    total_clusters = len(centroid_df)
    print(f"Total clusters to process: {total_clusters}")

    for idx, cluster_id in enumerate(centroid_df["cluster_post"], 1):

        cluster_start = time.time()
        print(f"[{idx}/{total_clusters}] Processing cluster {cluster_id}...")

        # Centroid
        centroid = centroid_df.loc[
            centroid_df["cluster_post"] == cluster_id,
            umap_cols
        ].values

        if len(centroid) == 0:
            continue

        # Molecule lists
        post_row = post_mols_df[post_mols_df["cluster_post"] == cluster_id]
        core_row = core_mols_df[core_mols_df["cluster_core"] == cluster_id]

        if post_row.empty:
            continue

        post_ids = ast.literal_eval(post_row["identifier"].values[0])
        core_ids = ast.literal_eval(core_row["identifier"].values[0]) if not core_row.empty else []

        # Coordinates
        post_coords = umap_df[
            umap_df["identifier"].isin(post_ids)
        ][umap_cols].values

        if len(post_coords) == 0:
            continue

        # 1. Medoid-centroid distance
        medoid_row = medoid_df[medoid_df["cluster"] == cluster_id]

        if medoid_row.empty:
            medoid_centroid_dist = np.nan
        else:
            medoid_id = medoid_row["medoid_identifier"].values[0]
            medoid_coords = umap_df[
                umap_df["identifier"] == medoid_id
            ][umap_cols].values

            medoid_centroid_dist = (
                np.linalg.norm(medoid_coords - centroid)
                if len(medoid_coords) > 0 else np.nan
            )

        # 2. Intra-cluster spread (post)
        distances_post = cdist(post_coords, centroid)
        mean_post = np.mean(distances_post)
        std_post = np.std(distances_post)

        # 3. Core spread
        if len(core_ids) > 0:
            core_coords = umap_df[
                umap_df["identifier"].isin(core_ids)
            ][umap_cols].values

            distances_core = cdist(core_coords, centroid)
            mean_core = np.mean(distances_core)
            std_core = np.std(distances_core)
        else:
            mean_core = np.nan
            std_core = np.nan

        # 4. Covariance-based volume proxy
        if len(post_coords) > args.n_components:
            cov_matrix = np.cov(post_coords, rowvar=False)

            try:
                cov_volume = np.sqrt(det(cov_matrix))
            except Exception:
                cov_volume = np.nan
        else:
            cov_volume = np.nan

        # 5. Density gradient
        density_gradient = (
            mean_post - mean_core
            if not np.isnan(mean_core) else np.nan
        )

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

    # Save results
    final_metrics = pd.DataFrame(results)
    final_metrics.to_csv(args.output, index=False)

    total_time = time.time() - start_time

    print(f"\nAll clusters processed in {total_time:.2f} seconds.")
    print(f"Results saved to: {args.output}")
    print(f"Clusters successfully processed: {len(final_metrics)}")


if __name__ == "__main__":
    main()
