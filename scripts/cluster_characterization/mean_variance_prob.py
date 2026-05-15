import pandas as pd
import numpy as np

# Load HDBSCAN assignments
df = pd.read_csv("DATA/full_clustering_results/hdbscan_core_assignments.csv")  

# Remove noise cluster if labeled as -1
df = df[df["cluster_core"] != -1]

# Compute statistics per cluster
cluster_stats = (
    df.groupby("cluster_core")["probability"]
      .agg(
          mean_probability="mean",
          variance_probability="var",
          q25=lambda x: np.percentile(x, 25),
          q75=lambda x: np.percentile(x, 75)
      )
      .reset_index()
)

# Compute IQR
cluster_stats["IQR_probability"] = cluster_stats["q75"] - cluster_stats["q25"]

# Drop intermediate percentiles
cluster_stats = cluster_stats.drop(columns=["q25", "q75"])

# Save if needed
cluster_stats.to_csv("DATA/cluster_profiling/cluster_probability_stats.csv", index=False)

print(cluster_stats)