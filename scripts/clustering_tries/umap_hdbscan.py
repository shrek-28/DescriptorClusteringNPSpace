import cudf
import cupy as cp
import numpy as np
import pandas as pd
from cuml.manifold import UMAP
from cuml.cluster import HDBSCAN
from cuml.preprocessing import StandardScaler as GPUScaler
from sklearn.preprocessing import PowerTransformer
from sklearn.preprocessing import StandardScaler as CPUScaler
from sklearn.metrics import silhouette_score, calinski_harabasz_score, davies_bouldin_score
from scipy.spatial.distance import cdist
import time
import gc
import os
from statistics import mean

df = pd.read_csv("DATA/sample_df.csv")
df = df.drop('Unnamed: 0', axis=1)
df.set_index('identifier', inplace=True)

gdf = cudf.from_pandas(df)

X = gdf.select_dtypes(include=['float64', 'int64']).to_pandas()

# Skewness check
print("Avg skew before:", X.skew().mean())

# Yeo–Johnson transform (handles zeros & negatives)
pt = PowerTransformer(method='yeo-johnson', standardize=False)
X_pt = pt.fit_transform(X)

# Standardize (CPU, more stable)
cpu_scaler = CPUScaler()
X_scaled = cpu_scaler.fit_transform(X_pt)

print("Avg skew after:", pd.DataFrame(X_pt, columns=X.columns).skew().mean())

# Convert to GPU
X_gpu = cp.asarray(X_scaled)

umap_space = {
    "n_neighbors": [10, 15, 30, 45, 60],           
    "n_components": [2, 3, 5, 10],                  
    "min_dist": [0.0, 0.1, 0.3, 0.5],               
    "metric": ["euclidean", "l2", "cosine"],       
    "spread": [0.8, 1.0, 1.2],                      
    "local_connectivity": [1, 5, 10],              
    "repulsion_strength": [0.8, 1.0, 1.5],          
    "negative_sample_rate": [1, 5, 10],             
    "init": ["spectral", "random"]
}

hdbscan_space = {
    "min_cluster_size": [15, 25, 50, 80, 120],   
    "min_samples": [1, 5, 10, 15],               
    "metric": ["euclidean", "l2"],               
    "cluster_selection_method": ["leaf", "eom"],
    "cluster_selection_epsilon": [0.0, 0.1, 0.2],
    "alpha": [1.0, 1.2, 1.5]                     
}

def safe_sample(space):
    params = {}
    for k, v in space.items():
        choice = np.random.choice(v)

        # Convert numpy types → python native
        if isinstance(choice, (np.str_, np.bool_, np.integer, np.floating)):
            choice = choice.item()

        params[k] = choice
    return params

## ADDITIONAL METRICS

def dunn_index(X, labels):
    labels = np.array(labels)
    valid = labels >= 0
    if len(np.unique(labels[valid])) < 2:
        return -1

    clusters = [X[labels == c] for c in np.unique(labels[valid])]

    inter = np.inf
    for i in range(len(clusters)):
        for j in range(i+1, len(clusters)):
            dist = np.min(cdist(clusters[i], clusters[j]))
            inter = min(inter, dist)

    intra = 0
    for cluster in clusters:
        if len(cluster) > 1:
            intra = max(intra, np.max(cdist(cluster, cluster)))

    return inter / intra if intra > 0 else -1


def cluster_purity(labels):
    labels = np.array(labels)
    valid = labels[labels >= 0]
    if len(valid) == 0:
        return -1
    _, counts = np.unique(valid, return_counts=True)
    return np.max(counts) / len(valid)

N_TRIALS = 50
RESULTS_FILE = "results_db_umap_hdbscan.csv"
results_db = []

# Resume previous results if exist
if os.path.exists(RESULTS_FILE):
    results_db = pd.read_csv(RESULTS_FILE).to_dict('records')
    print(f"Loaded {len(results_db)} previous trials.")

durations = []

def free_gpu():
    cp.get_default_memory_pool().free_all_blocks()
    cp.get_default_pinned_memory_pool().free_all_blocks()
    gc.collect()

for trial in range(len(results_db), N_TRIALS):
    start = time.time()
    print(f"\n====================")
    print(f"=== Trial {trial+1}/{N_TRIALS} ===")
    print("====================")

    try:
        # Sample params
        u = safe_sample(umap_space)
        h = safe_sample(hdbscan_space)

        print("\n[UMAP PARAMS]")
        for k, v in u.items():
            print(f"  {k} = {v}")

        print("\n[HDBSCAN PARAMS]")
        for k, v in h.items():
            print(f"  {k} = {v}")

        # ------------------------------
        # UMAP
        # ------------------------------
        print("\nRunning UMAP...")
        umap_model = UMAP(**u, random_state=42)
        X_umap = umap_model.fit_transform(X_gpu)
        X_umap_cpu = cp.asnumpy(X_umap)
        print("UMAP done.")

        # ------------------------------
        # HDBSCAN
        # ------------------------------
        print("Running HDBSCAN...")
        hdb = HDBSCAN(**h)
        labels = hdb.fit_predict(X_umap)
        labels_cpu = cp.asnumpy(labels)
        print("HDBSCAN done.")

        if (labels_cpu == -1).all():
            print("⚠ All noise → skipping trial.")
            free_gpu()
            continue

        # ------------------------------
        # Metrics
        # ------------------------------
        print("Calculating metrics...")
        sil = silhouette_score(X_umap_cpu, labels_cpu)
        dbi = davies_bouldin_score(X_umap_cpu, labels_cpu)
        ch = calinski_harabasz_score(X_umap_cpu, labels_cpu)
        dunn = dunn_index(X_umap_cpu, labels_cpu)
        purity = cluster_purity(labels_cpu)

        n_clusters = len(set(labels_cpu)) - (1 if -1 in labels_cpu else 0)
        noise_fraction = (labels_cpu == -1).mean()
        print(f"Clusters: {n_clusters}, Noise: {noise_fraction:.2f}, Silhouette: {sil:.3f}")

        # ------------------------------
        # Save results immediately
        # ------------------------------
        record = {}
        # Flatten UMAP params
        for k, v in u.items():
            record[f"umap_{k}"] = v
        # Flatten HDBSCAN params
        for k, v in h.items():
            record[f"hdbscan_{k}"] = v
        # Metrics
        record.update({
            "silhouette": sil,
            "dbi": dbi,
            "ch_score": ch,
            "dunn": dunn,
            "purity": purity,
            "clusters": n_clusters,
            "noise_fraction": noise_fraction
        })

        results_db.append(record)
        pd.DataFrame(results_db).to_csv(RESULTS_FILE, index=False)
        print("Saved")

    except Exception as e:
        print(f"Error in Trial {trial+1}: {e}")

    finally:
        # GPU cleanup
        del X_umap, X_umap_cpu, labels, labels_cpu
        del umap_model, hdb
        free_gpu()

        if (trial + 1) % 7 == 0:
            print("Periodic GPU reset...")
            free_gpu()

    # Progress
    end = time.time()
    duration = end - start
    durations.append(duration)
    avg = mean(durations)
    remaining = (N_TRIALS - (trial+1)) * avg
    print(f"Time this trial: {duration:.2f}s")
    print(f"Avg per trial: {avg:.2f}s")
    print(f"ETA remaining: {remaining/60:.2f} min")