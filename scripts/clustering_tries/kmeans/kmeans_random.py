import cudf
import cupy as cp
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from cuml.cluster import KMeans
from cuml.preprocessing import StandardScaler
from sklearn.preprocessing import PowerTransformer
from sklearn.metrics import silhouette_score, calinski_harabasz_score, davies_bouldin_score

gdf = cudf.read_csv("data/sample_df.csv")
X = gdf.select_dtypes(include=['float64', 'int64']).to_pandas()

skew_vals = X.skew()
print("Average skewness before:", skew_vals.mean())

pt = PowerTransformer(method='yeo-johnson', standardize=False)
X_pt = pt.fit_transform(X)

# Standardize to mean=0, std=1 (for distance-based algorithms)
from sklearn.preprocessing import StandardScaler as CPUScaler
scaler = CPUScaler()
X_scaled = scaler.fit_transform(X_pt)

print("Average skewness after:", pd.DataFrame(X_pt, columns=X.columns).skew().mean())

# Convert to GPU array
X_gpu = cp.asarray(X_scaled)

n_clusters_list = list(range(270, 500, 5))
init_methods = ['k-means++', 'random']
max_iters = [300, 500, 700, 1000]

init = "random"
results_random = []

for max_iter in max_iters:
    for k in n_clusters_list:
        kmeans = KMeans(n_clusters=k, init=init, max_iter=max_iter, random_state=42)
        labels = kmeans.fit_predict(X_gpu)

        inertia = float(kmeans.inertia_)
        labels_cpu = cp.asnumpy(labels)
        X_cpu = np.asarray(X_scaled)

        silhouette = silhouette_score(X_cpu, labels_cpu)
        ch = calinski_harabasz_score(X_cpu, labels_cpu)
        db = davies_bouldin_score(X_cpu, labels_cpu)

        results_random.append({
            "init": init,
            "max_iter": max_iter,
            "k": k,
            "inertia": inertia,
            "silhouette": silhouette,
            "calinski_harabasz": ch,
            "davies_bouldin": db
        })

        print(f"Done: init={init}, iter={max_iter}, k={k}")

results_random.to_csv("data/clustering_try_results/kmeans/kmeansrandom.csv", index=False)