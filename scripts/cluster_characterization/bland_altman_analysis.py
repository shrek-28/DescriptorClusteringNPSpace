import pandas as pd
import numpy as np

# =====================================
# INPUT / OUTPUT
# =====================================
input_file = "data/cluster_profiling/cluster_full_chemical_profile.csv"
output_file = "data/cluster_profiling/bland_altman_statistics.csv"

# =====================================
# LOAD DATA
# =====================================
df = pd.read_csv(input_file)

# =====================================
# DESCRIPTORS
# =====================================
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

# =====================================
# COMPARISONS
# =====================================
comparisons = [
    ("mean_vs_medoid", "{d}_mean", "medoid_{d}"),
    ("mean_vs_centroid", "{d}_mean", "centroid_closest_{d}"),
    ("medoid_vs_centroid", "medoid_{d}", "centroid_closest_{d}"),
    ("medoid_vs_diverse_1", "medoid_{d}", "diverse_1_{d}"),
    ("medoid_vs_diverse_2", "medoid_{d}", "diverse_2_{d}"),
    ("medoid_vs_diverse_3", "medoid_{d}", "diverse_3_{d}"),
    ("medoid_vs_diverse_4", "medoid_{d}", "diverse_4_{d}"),
    ("medoid_vs_diverse_5", "medoid_{d}", "diverse_5_{d}")
]

# =====================================
# BLAND–ALTMAN COMPUTATION
# =====================================
results = []

for descriptor in descriptors:

    for comparison_name, x_template, y_template in comparisons:

        x_col = x_template.format(d=descriptor)
        y_col = y_template.format(d=descriptor)

        # skip missing columns
        if x_col not in df.columns or y_col not in df.columns:
            continue

        temp_df = df[[x_col, y_col]].copy()

        temp_df[x_col] = pd.to_numeric(temp_df[x_col], errors="coerce")
        temp_df[y_col] = pd.to_numeric(temp_df[y_col], errors="coerce")

        temp_df = temp_df.dropna()

        x = temp_df[x_col]
        y = temp_df[y_col]

        # Bland–Altman calculations
        mean_vals = (x + y) / 2
        diff_vals = x - y

        bias = diff_vals.mean()
        sd_diff = diff_vals.std(ddof=1)

        loa_upper = bias + 1.96 * sd_diff
        loa_lower = bias - 1.96 * sd_diff

        # additional stability metrics
        mean_abs_diff = np.mean(np.abs(diff_vals))
        rmse = np.sqrt(np.mean(diff_vals ** 2))

        results.append({
            "descriptor": descriptor,
            "comparison": comparison_name,

            "x_column": x_col,
            "y_column": y_col,

            "bias_mean_difference": round(bias, 2),
            "sd_difference": round(sd_diff, 2),

            "loa_upper": round(loa_upper, 2),
            "loa_lower": round(loa_lower, 2),

            "mean_absolute_difference": round(mean_abs_diff, 2),
            "rmse_difference": round(rmse, 2),

            "n_pairs": len(diff_vals)
        })

# =====================================
# SAVE OUTPUT
# =====================================
results_df = pd.DataFrame(results)
results_df.to_csv(output_file, index=False)

print(f"Saved Bland–Altman statistics table to: {output_file}")
print(results_df.head())