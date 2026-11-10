import argparse
import os
import time

import numpy as np
import pandas as pd
import umap
import hdbscan

from scipy.spatial.distance import cdist
from scipy.cluster.hierarchy import linkage, fcluster

from sklearn.preprocessing import PowerTransformer, StandardScaler
from sklearn.metrics import (
    silhouette_score,
    davies_bouldin_score,
    calinski_harabasz_score
)
from sklearn.utils import resample


def calculate_medoid(X, indices):

    Xc = X[indices]
    distances = cdist(Xc, Xc)

    return indices[np.argmin(distances.sum(axis=1))]


def calculate_metrics(X, labels, sample_size=None):

    if len(np.unique(labels)) < 2:
        return np.nan, np.nan, np.nan

    if sample_size is not None and len(X) > sample_size:
        X, labels = resample(
            X,
            labels,
            n_samples=sample_size,
            random_state=42,
            stratify=labels
        )

    return (
        silhouette_score(X, labels),
        davies_bouldin_score(X, labels),
        calinski_harabasz_score(X, labels)
    )


def main():

    parser = argparse.ArgumentParser(
        description="UMAP-HDBSCAN clustering and representative selection"
    )

    parser.add_argument(
        "--input",
        required=True,
        help="Input descriptor CSV"
    )

    parser.add_argument(
        "--umap",
        required=True,
        help="Precomputed UMAP embedding (.npy)"
    )

    parser.add_argument(
        "--output",
        default="DATA/full_clustering_results",
        help="Output directory"
    )

    parser.add_argument(
        "--min-cluster-size",
        type=int,
        default=100
    )

    parser.add_argument(
        "--min-samples",
        type=int,
        default=10
    )

    parser.add_argument(
        "--alpha",
        type=float,
        default=0.7
    )

    parser.add_argument(
        "--threads",
        type=int,
        default=-1
    )

    parser.add_argument(
        "--target-clusters",
        type=int,
        default=None
    )

    parser.add_argument(
        "--silhouette-sample",
        type=int,
        default=20000
    )

    args = parser.parse_args()

    start_time = time.time()

    os.makedirs(args.output, exist_ok=True)

    # Load data

    df = pd.read_csv(args.input)

    if "identifier" not in df.columns:
        raise ValueError("Input CSV must contain an 'identifier' column.")

    identifiers = df["identifier"].astype(str).values

    X_umap = np.load(args.umap)

    if len(X_umap) != len(identifiers):
        raise ValueError("Identifier and UMAP dimensions do not match.")

    umap_cols = [
        f"UMAP_{i}" for i in range(X_umap.shape[1])
    ]

    # HDBSCAN clustering

    clusterer = hdbscan.HDBSCAN(
        min_cluster_size=args.min_cluster_size,
        min_samples=args.min_samples,
        cluster_selection_method="leaf",
        approx_min_span_tree=True,
        metric="euclidean",
        alpha=args.alpha,
        prediction_data=True,
        core_dist_n_jobs=args.threads
    )

    labels = clusterer.fit_predict(X_umap)

    n_clusters = len(set(labels)) - (1 if -1 in labels else 0)
    noise_fraction = np.mean(labels == -1)

    # Core metrics

    mask_core = labels != -1

    X_core = X_umap[mask_core]
    labels_core = labels[mask_core]

    sil_core, dbi_core, ch_core = calculate_metrics(
        X_core,
        labels_core,
        args.silhouette_sample
    )

    # Calculate medoids and centroids from core clusters

    cluster_ids = np.unique(labels_core)

    medoids = {}
    centroids = {}

    for c in cluster_ids:

        indices = np.where(labels == c)[0]

        medoids[c] = calculate_medoid(
            X_umap,
            indices
        )

        centroids[c] = X_umap[indices].mean(axis=0)

    medoid_indices = np.array(list(medoids.values()))
    medoid_vectors = X_umap[medoid_indices]
    medoid_ids = np.array(list(medoids.keys()))

    # Assign noise to nearest medoids

    labels_with_noise = labels.copy()

    noise_idx = np.where(labels == -1)[0]

    for i in range(0, len(noise_idx), 10000):

        batch_idx = noise_idx[i:i + 10000]

        distances = cdist(
            X_umap[batch_idx],
            medoid_vectors
        )

        nearest = np.argmin(distances, axis=1)

        labels_with_noise[batch_idx] = medoid_ids[nearest]

    # Hierarchical merging

    target_clusters = (
        args.target_clusters
        if args.target_clusters is not None
        else n_clusters
    )

    if not 1 <= target_clusters <= n_clusters:
        raise ValueError("Invalid target-clusters value.")

    if target_clusters < n_clusters:

        Z = linkage(
            medoid_vectors,
            method="average"
        )

        merged_labels = fcluster(
            Z,
            t=target_clusters,
            criterion="maxclust"
        )

        cluster_mapping = dict(
            zip(medoid_ids, merged_labels)
        )

        final_labels = np.array([
            cluster_mapping[c] for c in labels_with_noise
        ])

    else:

        final_labels = labels_with_noise.copy()

    # Metrics after noise assignment and merging

    sil_post, dbi_post, ch_post = calculate_metrics(
        X_umap,
        final_labels,
        args.silhouette_sample
    )

    # Master results table

    results_df = pd.DataFrame(
        X_umap,
        columns=umap_cols
    )

    results_df["identifier"] = identifiers
    results_df["cluster_core"] = labels
    results_df["cluster_post"] = labels_with_noise
    results_df["cluster_final"] = final_labels

    results_df.to_csv(
        os.path.join(args.output, "umap_with_clusters.csv"),
        index=False
    )

    # HDBSCAN assignments

    hdbscan_info = pd.DataFrame({
        "identifier": identifiers,
        "cluster_core": labels,
        "probability": clusterer.probabilities_,
        "outlier_score": clusterer.outlier_scores_
    })

    hdbscan_info.to_csv(
        os.path.join(args.output, "hdbscan_core_assignments.csv"),
        index=False
    )

    # Core and noise molecules

    results_df[results_df["cluster_core"] != -1].to_csv(
        os.path.join(args.output, "core_molecules.csv"),
        index=False
    )

    results_df[results_df["cluster_core"] == -1].to_csv(
        os.path.join(args.output, "hdbscan_noise_molecules.csv"),
        index=False
    )

    # Post-noise assignment molecules

    results_df[
        results_df["cluster_core"] == -1
    ].to_csv(
        os.path.join(args.output, "noise_assigned_molecules.csv"),
        index=False
    )

    results_df.to_csv(
        os.path.join(args.output, "post_noise_assignments.csv"),
        index=False
    )

    # Cluster sizes

    cluster_sizes_core = (
        results_df[results_df.cluster_core != -1]
        .cluster_core.value_counts()
        .rename("core_size")
    )

    cluster_sizes_post = (
        results_df.cluster_post.value_counts()
        .rename("post_size")
    )

    cluster_sizes_final = (
        results_df.cluster_final.value_counts()
        .rename("final_size")
    )

    cluster_sizes = pd.concat(
        [
            cluster_sizes_core,
            cluster_sizes_post,
            cluster_sizes_final
        ],
        axis=1
    ).fillna(0).astype(int).sort_index()

    cluster_sizes.to_csv(
        os.path.join(args.output, "cluster_sizes.csv")
    )

    # Core cluster centroids

    centroid_rows = []

    for c, centroid in centroids.items():

        centroid_rows.append({
            "cluster": c,
            "cluster_size": np.sum(labels == c),
            **dict(zip(umap_cols, centroid))
        })

    pd.DataFrame(centroid_rows).to_csv(
        os.path.join(args.output, "cluster_centroids.csv"),
        index=False
    )

    # Core cluster medoids

    medoid_rows = []

    for c, idx in medoids.items():

        medoid_rows.append({
            "cluster": c,
            "medoid_identifier": identifiers[idx],
            **dict(zip(umap_cols, X_umap[idx]))
        })

    pd.DataFrame(medoid_rows).to_csv(
        os.path.join(args.output, "cluster_medoids.csv"),
        index=False
    )

    # Molecules per cluster

    results_df[results_df.cluster_core != -1].groupby(
        "cluster_core"
    )["identifier"].apply(list).reset_index().to_csv(
        os.path.join(args.output, "cluster_molecules_core.csv"),
        index=False
    )

    results_df.groupby(
        "cluster_post"
    )["identifier"].apply(list).reset_index().to_csv(
        os.path.join(args.output, "cluster_molecules_post.csv"),
        index=False
    )

    # Seven representatives per post-noise cluster

    rep_rows = []

    for cid, group in results_df.groupby("cluster_post"):

        X = group[umap_cols].values
        ids = group["identifier"].values

        centroid = X.mean(axis=0)

        centroid_distances = cdist(
            X,
            centroid.reshape(1, -1)
        ).ravel()

        medoid_distances = cdist(X, X)

        medoid_idx = np.argmin(
            medoid_distances.sum(axis=1)
        )

        # Centroid-closest, excluding medoid

        centroid_order = np.argsort(centroid_distances)

        centroid_idx = next(
            i for i in centroid_order if i != medoid_idx
        ) if len(X) > 1 else medoid_idx

        # Five diverse representatives, excluding first two

        selected = [medoid_idx, centroid_idx]

        distances_to_selected = cdist(
            X,
            X[selected]
        ).min(axis=1)

        distances_to_selected[selected] = -np.inf

        diverse_indices = []

        for _ in range(min(5, len(X) - len(selected))):

            next_idx = np.argmax(distances_to_selected)

            diverse_indices.append(next_idx)
            selected.append(next_idx)

            new_distances = cdist(
                X,
                X[next_idx].reshape(1, -1)
            ).ravel()

            distances_to_selected = np.minimum(
                distances_to_selected,
                new_distances
            )

            distances_to_selected[selected] = -np.inf

        representatives = [
            ("medoid", medoid_idx),
            ("centroid_closest", centroid_idx)
        ]

        representatives.extend([
            (f"diverse_{i + 1}", idx)
            for i, idx in enumerate(diverse_indices)
        ])

        for rep_type, idx in representatives:

            rep_rows.append({
                "cluster": cid,
                "rep_type": rep_type,
                "identifier": ids[idx]
            })

    representatives_df = pd.DataFrame(rep_rows)

    representatives_df.to_csv(
        os.path.join(
            args.output,
            "cluster_representatives_7_per_cluster.csv"
        ),
        index=False
    )

    # Docking-ready molecule list

    representatives_df["identifier"].drop_duplicates().to_csv(
        os.path.join(args.output, "molecules_for_docking.txt"),
        index=False,
        header=False
    )

    # Save metrics

    metrics_df = pd.DataFrame([
        {
            "stage": "HDBSCAN_core",
            "n_clusters": n_clusters,
            "noise_fraction": noise_fraction,
            "silhouette": sil_core,
            "DBI": dbi_core,
            "CH": ch_core
        },
        {
            "stage": "Post_noise_assignment_and_merging",
            "n_clusters": len(np.unique(final_labels)),
            "noise_fraction": np.mean(final_labels == -1),
            "silhouette": sil_post,
            "DBI": dbi_post,
            "CH": ch_post
        }
    ])

    metrics_df.to_csv(
        os.path.join(args.output, "clustering_metrics.csv"),
        index=False
    )

    # Summary

    print("\n========== CLUSTERING METRICS ==========")

    print("\nHDBSCAN:")
    print("Clusters:", n_clusters)
    print("Noise fraction:", round(noise_fraction, 4))
    print("Silhouette:", round(sil_core, 4))
    print("DBI:", round(dbi_core, 4))
    print("Calinski-Harabasz:", round(ch_core, 4))

    print("\nAfter noise assignment and merging:")
    print("Clusters:", len(np.unique(final_labels)))
    print("Effective noise fraction:", np.mean(final_labels == -1))
    print("Silhouette:", round(sil_post, 4))
    print("DBI:", round(dbi_post, 4))
    print("Calinski-Harabasz:", round(ch_post, 4))

    print("\nMean final cluster size:", round(
        np.mean(list(np.unique(final_labels, return_counts=True)[1])), 2
    ))

    print("\nFiles saved to:", args.output)
    print("Runtime:", round((time.time() - start_time) / 60, 2), "minutes")


if __name__ == "__main__":
    main()