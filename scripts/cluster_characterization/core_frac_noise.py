import pandas as pd
import numpy as np

df_prob = pd.read_csv("DATA/full_clustering_results/hdbscan_core_assignments.csv")
df_umap   = pd.read_csv("DATA/full_clustering_results/umap_with_clusters.csv")

core_stats = (
    df_prob
    .assign(is_core=lambda x: x["probability"] >= 0.9)
    .groupby("cluster_core")
    .agg(
        core_size=("is_core", "sum")
    )
    .reset_index()
)

# -------------------------
# Post-noise cluster size
# -------------------------
post_size = (
    df_umap
    .groupby("cluster_post")
    .agg(
        post_noise_size=("identifier", "count")
    )
    .reset_index()
    .rename(columns={"cluster_post": "cluster_core"})
)

# -------------------------
# Merge sizes
# -------------------------
table1 = core_stats.merge(
    post_size,
    on="cluster_core",
    how="inner"
)

table1["core_fraction"] = (
    table1["core_size"] / table1["post_noise_size"]
)

# -------------------------
# Probability IQR
# -------------------------
prob_iqr = (
    df_prob
    .groupby("cluster_core")["probability"]
    .quantile([0.25, 0.75])
    .unstack()
    .reset_index()
)

prob_iqr.columns = ["cluster_core", "q1", "q3"]
prob_iqr["prob_IQR"] = prob_iqr["q3"] - prob_iqr["q1"]

# -------------------------
# Merge IQR
# -------------------------
table1 = table1.merge(
    prob_iqr[["cluster_core", "prob_IQR"]],
    on="cluster_core"
)

# -------------------------
# Final verdict
# -------------------------
def verdict(row):
    if row.core_fraction < 0.3 and row.prob_IQR > 0.4:
        return "reject"
    if row.core_fraction >= 0.5:
        return "accept"
    return "borderline"

table1["final_verdict"] = table1.apply(verdict, axis=1)

table1.to_csv("DATA/cluster_profiling/core_frac_classification.csv")