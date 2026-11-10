import argparse
import os
import numpy as np
import pandas as pd
import hdbscan
import umap

from scipy.spatial.distance import cdist
from scipy.cluster.hierarchy import linkage, fcluster

from sklearn.preprocessing import PowerTransformer, StandardScaler
from sklearn.metrics import (
    silhouette_score,
    davies_bouldin_score,
    calinski_harabasz_score
)

UMAP_CONFIGS = [
    {"n_neighbors": 30, "min_dist": 0.30, "n_components": 12, "n_epochs": 150},
    {"n_neighbors": 30, "min_dist": 0.10, "n_components": 12, "n_epochs": 150},
    {"n_neighbors": 50, "min_dist": 0.30, "n_components": 12, "n_epochs": 150},
    {"n_neighbors": 30, "min_dist": 0.30, "n_components": 12, "n_epochs": 300},
    {"n_neighbors": 30, "min_dist": 0.10, "n_components": 12, "n_epochs": 300},
    {"n_neighbors": 15, "min_dist": 0.10, "n_components": 12, "n_epochs": 150},
    {"n_neighbors": 15, "min_dist": 0.30, "n_components": 12, "n_epochs": 150},
    {"n_neighbors": 50, "min_dist": 0.10, "n_components": 12, "n_epochs": 150},
    {"n_neighbors": 50, "min_dist": 0.50, "n_components": 12, "n_epochs": 150}
]

HDBSCAN_CONFIGS = [
    {"min_cluster_size": 20, "min_samples": 5},
    {"min_cluster_size": 30, "min_samples": 3},
    {"min_cluster_size": 30, "min_samples": 5},
    {"min_cluster_size": 30, "min_samples": 7},
    {"min_cluster_size": 40, "min_samples": 5},
    {"min_cluster_size": 50, "min_samples": 5},
    {"min_cluster_size": 50, "min_samples": 10},
    {"min_cluster_size": 75, "min_samples": 5}
]

def calculate_metrics(X, labels):
    if len(np.unique(labels)) < 2 or len(np.unique(labels)) >= len(labels):
        return np.nan, np.nan, np.nan

    return (
        silhouette_score(X, labels),
        davies_bouldin_score(X, labels),
        calinski_harabasz_score(X, labels)
    )


def calculate_medoid(X):
    best_index = None
    best_distance = np.inf

    for start in range(0, len(X), 512):
        distances = cdist(X[start:start + 512], X)
        sums = distances.sum(axis=1)

        local_index = np.argmin(sums)
        if sums[local_index] < best_distance:
            best_distance = sums[local_index]
            best_index = start + local_index

    return best_index


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--input",
        default="DATA/20desc_training_matrix.csv"
    )
    parser.add_argument(
        "--output",
        default="umap_hdbscan_grid_results.csv"
    )
    parser.add_argument("--threads", type=int, default=-1)
    parser.add_argument("--target-clusters", type=int, default=None)
    args = parser.parse_args()

    df = pd.read_csv(args.input)

    identifiers = df["identifier"].values

    features = df.drop(
        columns=["identifier"],
        errors="ignore"
    ).select_dtypes(include=[np.number])

    features = features.drop(
        columns=[c for c in features.columns if c.startswith("Unnamed:")],
        errors="ignore"
    )

    features = features.loc[:, features.nunique() > 1]

    X = PowerTransformer(
        method="yeo-johnson"
    ).fit_transform(features)

    X = StandardScaler().fit_transform(X)

    if len(X) != len(identifiers):
        raise ValueError("Feature and identifier dimensions do not match.")

    results = []

    for ui, uparams in enumerate(UMAP_CONFIGS, 1):

        print(f"\nUMAP configuration U{ui}: {uparams}")

        reducer = umap.UMAP(
            **uparams,
            metric="euclidean",
            low_memory=True,
            densmap=False,
            random_state=42
        )

        X_umap = reducer.fit_transform(X)

        # os.makedirs("UMAP_embeddings", exist_ok=True)
        # np.save(f"UMAP_embeddings/U{ui}.npy", X_umap)

        for hi, hparams in enumerate(HDBSCAN_CONFIGS, 1):

            print(f"  HDBSCAN H{hi}: {hparams}")

            clusterer = hdbscan.HDBSCAN(
                **hparams,
                metric="euclidean",
                cluster_selection_method="leaf",
                alpha=1.0,
                approx_min_span_tree=True,
                prediction_data=True,
                core_dist_n_jobs=args.threads
            )

            labels = clusterer.fit_predict(X_umap)

            cluster_ids = np.unique(labels[labels != -1])
            n_clusters = len(cluster_ids)
            noise_fraction = np.mean(labels == -1)

            if n_clusters < 2:
                print("  Skipping: fewer than two clusters.")
                continue

            # Pre-noise assignment metrics
            core_mask = labels != -1
            sil_pre, dbi_pre, ch_pre = calculate_metrics(
                X_umap[core_mask],
                labels[core_mask]
            )

            # Calculate exact cluster medoids
            medoid_indices = []

            for c in cluster_ids:
                indices = np.where(labels == c)[0]
                medoid_local = calculate_medoid(X_umap[indices])
                medoid_indices.append(indices[medoid_local])

            medoid_indices = np.array(medoid_indices)
            medoid_vectors = X_umap[medoid_indices]

            # Assign noise molecules to nearest medoid
            labels_assigned = labels.copy()
            noise_indices = np.where(labels == -1)[0]

            for start in range(0, len(noise_indices), 10000):
                batch = noise_indices[start:start + 10000]

                distances = cdist(
                    X_umap[batch],
                    medoid_vectors
                )

                nearest = np.argmin(distances, axis=1)
                labels_assigned[batch] = cluster_ids[nearest]

            # Optional hierarchical merging of medoids
            target = (
                args.target_clusters
                if args.target_clusters is not None
                else n_clusters
            )

            if not 1 <= target <= n_clusters:
                raise ValueError(
                    f"Invalid target-clusters value: {target}. "
                    f"This run produced {n_clusters} clusters."
                )

            if target < n_clusters:
                Z = linkage(medoid_vectors, method="average")
                merged_labels = fcluster(
                    Z,
                    t=target,
                    criterion="maxclust"
                )

                mapping = dict(zip(cluster_ids, merged_labels))
                final_labels = np.array([
                    mapping[c] for c in labels_assigned
                ])
            else:
                final_labels = labels_assigned

            # Post-noise assignment metrics
            sil_post, dbi_post, ch_post = calculate_metrics(
                X_umap,
                final_labels
            )

            post_clusters = len(np.unique(final_labels))

            results.append({
                "UMAP_config": f"U{ui}",
                "n_neighbors": uparams["n_neighbors"],
                "min_dist": uparams["min_dist"],
                "n_components": uparams["n_components"],
                "n_epochs": uparams["n_epochs"],
                "min_cluster_size": hparams["min_cluster_size"],
                "min_samples": hparams["min_samples"],
                "alpha": 1.0,
                "n_clusters": n_clusters,
                "noise_fraction": noise_fraction,
                "pre_silhouette": sil_pre,
                "pre_DBI": dbi_pre,
                "pre_CH": ch_pre,
                "post_n_clusters": post_clusters,
                "post_noise": 0,
                "post_silhouette": sil_post,
                "post_DBI": dbi_post,
                "post_CH": ch_post
            })

            print(
                f"  Clusters: {n_clusters} | "
                f"Noise: {noise_fraction:.4f} | "
                f"Pre-silhouette: {sil_pre:.4f} | "
                f"Post-silhouette: {sil_post:.4f}"
            )

            pd.DataFrame(results).to_csv(args.output, index=False)

    results_df = pd.DataFrame(results)
    results_df.to_csv(args.output, index=False)

    print("\nFinal results:")
    print(results_df.to_string(index=False))
    print(f"\nResults saved to: {args.output}")


if __name__ == "__main__":
    main()