import numpy as np
import umap
import time
from sklearn.preprocessing import PowerTransformer
from sklearn.preprocessing import StandardScaler
import pandas as pd
import hdbscan
from sklearn.metrics import silhouette_score
from sklearn.utils import resample
from scipy.spatial.distance import cdist
from scipy.cluster.hierarchy import linkage, fcluster
from sklearn.metrics import davies_bouldin_score, calinski_harabasz_score
import os 

df = pd.read_csv("DATA/20desc_training_matrix.csv")
df = df.drop('Unnamed: 0', axis=1)
df.set_index('identifier', inplace=True)

pt = PowerTransformer(method='yeo-johnson', standardize=True)
X_transformed = pt.fit_transform(df.values)

scaler = StandardScaler()
X_scaled = scaler.fit_transform(X_transformed)

X_umap = np.load("MODELS/X_umap_try2.npy")

clusterer = hdbscan.HDBSCAN(
    min_cluster_size=100,
    min_samples=10,
    cluster_selection_method="leaf",   # microclusters
    approx_min_span_tree=True,
    metric='euclidean',               # can also try 'cosine'
    alpha=0.7,                        # default stability pruning
    prediction_data=True,              # allow future assignments
    core_dist_n_jobs=-1                # parallel CPU computation
)

labels = clusterer.fit_predict(X_umap)
n_clusters = len(set(labels)) - (1 if -1 in labels else 0)
noise_fraction = (labels == -1).mean()

mask = labels != -1
X_clean = X_umap[mask]
labels_clean = labels[mask]

# sample at most 50k points
X_s, y_s = resample(
    X_clean,
    labels_clean,
    n_samples=min(50000, len(X_clean)),
    random_state=42,
    stratify=labels_clean
)

sil_score = silhouette_score(X_s, y_s, metric="euclidean")

cluster_ids = np.unique(labels)
cluster_ids = cluster_ids[cluster_ids != -1]  # ignore noise

medoids = {}
for c in cluster_ids:
    idx = np.where(labels == c)[0]
    Xc = X_umap[idx]
    D = cdist(Xc, Xc)
    medoid_idx = idx[np.argmin(D.sum(axis=1))]
    medoids[c] = medoid_idx

noise_idx = np.where(labels == -1)[0]
X_noise = X_umap[noise_idx]
medoid_vectors = np.array([X_umap[i] for i in medoids.values()])

# Distance from each noise point to all medoids
dist_to_medoids = cdist(X_noise, medoid_vectors)
assigned_clusters = np.array(list(medoids.keys()))[np.argmin(dist_to_medoids, axis=1)]

# Update labels
labels_with_noise = labels.copy()
labels_with_noise[noise_idx] = assigned_clusters

medoid_vectors = np.array([X_umap[i] for i in medoids.values()])
Z = linkage(medoid_vectors, method='average')

target_clusters = n_clusters  # adjust as needed
merged_labels = fcluster(Z, t=target_clusters, criterion='maxclust')

# Map merged labels back to all points
final_labels = np.array([merged_labels[list(medoids.keys()).index(l)] for l in labels_with_noise])

# Silhouette (all points included now)
sil_score = silhouette_score(X_umap, labels_with_noise, sample_size=20000, random_state=42)

# Cluster sizes
import pandas as pd
unique, counts = np.unique(labels_with_noise, return_counts=True)
cluster_sizes = dict(zip(unique, counts))

# core points only
mask_core = labels != -1
X_core = X_umap[mask_core]
labels_core = labels[mask_core]

# DBI
dbi = davies_bouldin_score(X_core, labels_core)

# Calinski-Harabasz
ch_score = calinski_harabasz_score(X_core, labels_core)

dbi_post = davies_bouldin_score(X_umap, labels_with_noise)
ch_post = calinski_harabasz_score(X_umap, labels_with_noise)

print("Clusters:", n_clusters)
print("Noise fraction:", noise_fraction)
print("Silhouette Score:", sil_score)
print("Number of medoids:", len(medoids))
print("DBI (core clusters):", dbi)
print("Calinski-Harabasz score (core clusters):", ch_score)
print("\n")
print("Clusters after assigning noise:", len(set(labels_with_noise)))
print("Effective noise fraction:", (labels_with_noise == -1).mean())
print("Silhouette score after assigning noise:", sil_score)
print("Mean cluster size after noise assignment:", np.mean(list(cluster_sizes.values())))
print("DBI (post-hoc assignment):", dbi_post)
print("CH score (post-hoc assignment):", ch_post)

final_labels = labels_with_noise


OUTDIR = "DATA/full_clustering_results"
os.makedirs(OUTDIR, exist_ok=True)

umap_cols = [f"UMAP_{i}" for i in range(X_umap.shape[1])]

# 1. Master UMAP + cluster table
results_df = pd.DataFrame(
    X_umap,
    columns=umap_cols
)

results_df["identifier"] = df["identifier"].values
results_df["cluster_core"] = labels
results_df["cluster_post"] = final_labels

results_df.to_csv(f"{OUTDIR}/umap_with_clusters.csv", index=False)

# 2. HDBSCAN probabilities (core info)
# ============================================================
hdbscan_info = pd.DataFrame({
    "identifier": df["identifier"].values,
    "cluster_core": labels,
    "probability": clusterer.probabilities_
})

hdbscan_info.to_csv(
    f"{OUTDIR}/hdbscan_core_assignments.csv",
    index=False
)

# 3. Cluster sizes (core vs post)
cluster_sizes_core = (
    results_df[results_df.cluster_core != -1]
    .cluster_core.value_counts()
    .rename("core_size")
)

cluster_sizes_post = (
    results_df.cluster_post
    .value_counts()
    .rename("post_size")
)

cluster_sizes = (
    pd.concat([cluster_sizes_core, cluster_sizes_post], axis=1)
    .fillna(0)
    .astype(int)
    .sort_index()
)

cluster_sizes.to_csv(f"{OUTDIR}/cluster_sizes.csv")

# 4. Cluster centroids (post-assignment)
centroids = (
    results_df
    .groupby("cluster_post")[umap_cols]
    .mean()
)

centroids.to_csv(f"{OUTDIR}/cluster_centroids.csv")

# 5. Cluster medoids (closest to centroid)
medoid_rows = []

for cid, group in results_df.groupby("cluster_post"):
    X = group[umap_cols].values
    centroid = X.mean(axis=0)

    d = cdist(X, centroid.reshape(1, -1)).ravel()
    idx = np.argmin(d)

    medoid_rows.append({
        "cluster": cid,
        "medoid_identifier": group.iloc[idx]["identifier"],
        "distance_to_centroid": d[idx]
    })

medoids_df = pd.DataFrame(medoid_rows)
medoids_df.to_csv(f"{OUTDIR}/cluster_medoids.csv", index=False)

# 6. Molecules per cluster

# Core clusters (noise excluded)
cluster_molecules_core = (
    results_df[results_df.cluster_core != -1]
    .groupby("cluster_core")["identifier"]
    .apply(list)
    .reset_index()
)

cluster_molecules_core.to_csv(
    f"{OUTDIR}/cluster_molecules_core.csv",
    index=False
)

# Post-hoc clusters (all molecules)
cluster_molecules_post = (
    results_df
    .groupby("cluster_post")["identifier"]
    .apply(list)
    .reset_index()
)

cluster_molecules_post.to_csv(
    f"{OUTDIR}/cluster_molecules_post.csv",
    index=False
)

# 7. Representatives per cluster
#    medoid + centroid-closest + 5 diverse
rep_rows = []

for cid, group in results_df.groupby("cluster_post"):
    X = group[umap_cols].values
    ids = group["identifier"].values

    centroid = X.mean(axis=0)

    d_centroid = cdist(X, centroid.reshape(1, -1)).ravel()
    medoid_idx = np.argmin(d_centroid)

    d_medoid = cdist(X, X[medoid_idx].reshape(1, -1)).ravel()

    # avoid outliers
    radius_cutoff = np.percentile(d_medoid, 80)
    valid = np.where(
        (d_medoid <= radius_cutoff) &
        (np.arange(len(X)) != medoid_idx)
    )[0]

    diverse_idxs = valid[np.argsort(d_medoid[valid])[::-1]]

    # medoid
    rep_rows.append({
        "cluster": cid,
        "rep_type": "medoid",
        "identifier": ids[medoid_idx]
    })

    # centroid-closest (excluding medoid)
    centroid_closest = np.argsort(d_centroid)[1]
    rep_rows.append({
        "cluster": cid,
        "rep_type": "centroid_closest",
        "identifier": ids[centroid_closest]
    })

    # 5 diverse representatives
    for i, idx in enumerate(diverse_idxs[:5]):
        rep_rows.append({
            "cluster": cid,
            "rep_type": f"diverse_{i+1}",
            "identifier": ids[idx]
        })

representatives_df = pd.DataFrame(rep_rows)
representatives_df.to_csv(
    f"{OUTDIR}/cluster_representatives_7_per_cluster.csv",
    index=False
)

# 8. Docking-ready molecule list
docking_list = (
    representatives_df["identifier"]
    .drop_duplicates()
)

docking_list.to_csv(
    f"{OUTDIR}/molecules_for_docking.txt",
    index=False,
    header=False
)

print("ALL FILES SAVED")