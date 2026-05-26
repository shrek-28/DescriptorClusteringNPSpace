import pandas as pd
import numpy as np
from scipy.stats import skew, kurtosis

# =========================
# INPUT / OUTPUT
# =========================
input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv"

stats_output_file = "data/cluster_profiling/representative_analysis.csv"
difference_output_file = "data/cluster_profiling/representative_difference_analysis.csv"

# =========================
# LOAD DATA
# =========================
df = pd.read_csv(input_file)

# =========================
# DESCRIPTORS
# =========================
descriptors = [
    "MolWt",
    "LogP",
    "AromaticRingCount",
    "FractionCSP3",
    "TPSA",
    "HBD",
    "HBA",
    "RotatableBonds"
]

# =========================
# REPRESENTATIVES
# =========================
representatives = {
    "mean": lambda d: f"{d}_mean",
    "median": lambda d: f"{d}_median",
    "medoid": lambda d: f"medoid_{d}",
    "centroid_closest": lambda d: f"centroid_closest_{d}",
    "diverse_1": lambda d: f"diverse_1_{d}",
    "diverse_2": lambda d: f"diverse_2_{d}",
    "diverse_3": lambda d: f"diverse_3_{d}",
    "diverse_4": lambda d: f"diverse_4_{d}",
    "diverse_5": lambda d: f"diverse_5_{d}"
}

# =========================
# TABLE 1:
# REPRESENTATIVE STATISTICS
# =========================
stats_results = []

for descriptor in descriptors:

    for rep_name, col_func in representatives.items():

        col = col_func(descriptor)

        if col not in df.columns:
            continue

        series = pd.to_numeric(df[col], errors="coerce").dropna()

        stats_results.append({
            "descriptor": descriptor,
            "representative": rep_name,
            "column_name": col,

            "min": series.min(),
            "max": series.max(),
            "mean": series.mean(),
            "median": series.median(),
            "std_dev": series.std(),
            "variance": series.var(),
            "skew": skew(series),
            "kurtosis": kurtosis(series)
        })

stats_df = pd.DataFrame(stats_results)
stats_df.to_csv(stats_output_file, index=False)

# =========================
# TABLE 2:
# ABSOLUTE DIFFERENCE METRICS
# =========================
difference_results = []

for descriptor in descriptors:

    mean_col = f"{descriptor}_mean"
    median_col = f"{descriptor}_median"

    diverse_cols = [
        f"diverse_1_{descriptor}",
        f"diverse_2_{descriptor}",
        f"diverse_3_{descriptor}",
        f"diverse_4_{descriptor}",
        f"diverse_5_{descriptor}"
    ]

    compare_reps = {
        "medoid": f"medoid_{descriptor}",
        "centroid_closest": f"centroid_closest_{descriptor}",
        "diverse_1": f"diverse_1_{descriptor}",
        "diverse_2": f"diverse_2_{descriptor}",
        "diverse_3": f"diverse_3_{descriptor}",
        "diverse_4": f"diverse_4_{descriptor}",
        "diverse_5": f"diverse_5_{descriptor}"
    }

    # -------------------------
    # AVG ABS DIFFERENCE
    # BETWEEN 5 DIVERSE REPS
    # -------------------------
    diverse_matrix = df[diverse_cols]

    pairwise_diffs = []

    for i in range(len(diverse_cols)):
        for j in range(i + 1, len(diverse_cols)):

            diff = np.abs(
                diverse_matrix[diverse_cols[i]] -
                diverse_matrix[diverse_cols[j]]
            )

            pairwise_diffs.append(diff.mean())

    avg_diverse_difference = np.mean(pairwise_diffs)

    # -------------------------
    # |mean - rep|
    # |median - rep|
    # -------------------------
    for rep_name, rep_col in compare_reps.items():

        mean_abs_diff = np.abs(
            df[mean_col] - df[rep_col]
        ).mean()

        median_abs_diff = np.abs(
            df[median_col] - df[rep_col]
        ).mean()

        difference_results.append({
            "descriptor": descriptor,
            "representative": rep_name,

            "avg_abs_mean_difference": mean_abs_diff,
            "avg_abs_median_difference": median_abs_diff,

            "avg_pairwise_diverse_difference":
                avg_diverse_difference
        })

difference_df = pd.DataFrame(difference_results)

difference_df.to_csv(difference_output_file, index=False)

print(f"Saved statistics table: {stats_output_file}")
print(f"Saved difference table: {difference_output_file}")