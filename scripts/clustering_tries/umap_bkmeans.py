import time, gc, os, random
import pandas as pd
import numpy as np
import cupy as cp
import cudf
from sklearn.metrics import silhouette_score, davies_bouldin_score, calinski_harabasz_score

GPU_AVAILABLE = False
try:
    import cuml
    from cuml.cluster import BisectingKMeans as cuBisect
    from cuml.manifold import UMAP as cuUMAP
    import cupy as cp
    GPU_AVAILABLE = True
    print("🚀 GPU Mode Enabled (cuML)")
except:
    from sklearn.cluster import BisectingKMeans
    from umap import UMAP
    GPU_AVAILABLE = False
    print("GPU unavailable → Using CPU fallback.")

# ---- Hyperparameter search space ----
umap_space = {
    "n_neighbors": [10, 20, 30, 40, 50],
    "n_components": [2, 3, 5],
    "min_dist": [0.0, 0.1, 0.25, 0.5],
    "metric": ["euclidean", "cosine", "manhattan"]
}

bisect_space = {
    "n_clusters": [300, 350, 400, 450, 500, 600],
    "init": ["k-means++", "random"],
    "max_iter": [100, 200, 300],
    "bisecting_strategy": ["biggest_inertia", "largest_cluster"]}

def sample(params):
    return {k: random.choice(v) for k, v in params.items()}

def free():
    gc.collect()
    if GPU_AVAILABLE:
        cp.get_default_memory_pool().free_all_blocks()
        cp.get_default_pinned_memory_pool().free_all_blocks()

df= pd.read_csv("DATA/sample_df.csv")
df = df.drop('Unnamed: 0', axis=1)
df.set_index('identifier', inplace=True)

X = df.values

if GPU_AVAILABLE:
    X_gpu = cp.asarray(X)

# ---- Metrics ----

RESULT_FILE = "umap_bisecting_results.csv"
results = []

# ---- Experiment ----
N_TRIALS = 30
for trial in range(N_TRIALS):
    start = time.time()
    print(f"\n===== Trial {trial+1}/{N_TRIALS} =====")

    try:
        u = sample(umap_space)
        b = sample(bisect_space)

        print("🎛 UMAP Params:", u)
        print("🎛 Bisecting KMeans Params:", b)

        # --- UMAP ---
        if GPU_AVAILABLE:
            um = cuUMAP(**u, random_state=42)
            X_embed = um.fit_transform(X_gpu)
            X_cpu = cp.asnumpy(X_embed)
        else:
            um = UMAP(**u, random_state=42)
            X_cpu = um.fit_transform(X)

        # --- Bisecting KMeans ---
        if GPU_AVAILABLE:
            model = cuBisect(**b, random_state=42)
        else:
            model = BisectingKMeans(**b, random_state=42)

        labels = model.fit_predict(X_cpu)

        # Skip invalid result
        if len(np.unique(labels)) < 2:
            print("⚠ Only 1 cluster found — skipping.")
            continue

        # --- Metrics ---
        sil = silhouette_score(X_cpu, labels)
        dbi = davies_bouldin_score(X_cpu, labels)
        ch = calinski_harabasz_score(X_cpu, labels)

        rec = {
            "trial": trial+1,
            **{f"UMAP_{k}": v for k, v in u.items()},
            **{f"BKMeans_{k}": v for k, v in b.items()},
            "clusters": len(np.unique(labels)),
            "silhouette": sil,
            "dbi": dbi,
            "calinski_harabasz": ch
        }

        results.append(rec)
        pd.DataFrame(results).to_csv(RESULT_FILE, index=False)
        print("Saved Result ✔")

    except Exception as e:
        print(f" ERROR:", e)

    finally:
        free()

    print(f"Duration: {time.time()-start:.2f}s")

print("\nDONE — Results stored at:", RESULT_FILE)
