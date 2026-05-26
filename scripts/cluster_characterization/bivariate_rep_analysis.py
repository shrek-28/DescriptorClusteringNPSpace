import pandas as pd
import numpy as np
from scipy.stats import linregress

# =====================================
# INPUT / OUTPUT
# =====================================
input_file = "data/cluster_profiling/cluster_full_chemical_profile.csv"
output_file = "data/cluster_profiling/descriptor_regression_statistics.csv"

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
# COMPUTE REGRESSION METRICS
# =====================================
results = []

for descriptor in descriptors:

    for comparison_name, x_template, y_template in comparisons:

        x_col = x_template.format(d=descriptor)
        y_col = y_template.format(d=descriptor)

        # skip if columns missing
        if x_col not in df.columns or y_col not in df.columns:
            continue

        # numeric conversion
        temp_df = df[[x_col, y_col]].copy()

        temp_df[x_col] = pd.to_numeric(temp_df[x_col], errors="coerce")
        temp_df[y_col] = pd.to_numeric(temp_df[y_col], errors="coerce")

        temp_df = temp_df.dropna()

        x = temp_df[x_col]
        y = temp_df[y_col]

        # linear regression
        regression = linregress(x, y)

        r_value = regression.rvalue
        r_squared = r_value ** 2
        slope = regression.slope

        results.append({
            "descriptor": descriptor,
            "comparison": comparison_name,

            "x_column": x_col,
            "y_column": y_col,

            "R": round(r_value,2),
            "R2": round(r_squared,2),
            "slope": round(slope,2),

            "intercept": round(regression.intercept, 2),
        })

# =====================================
# SAVE OUTPUT
# =====================================
results_df = pd.DataFrame(results)

results_df.to_csv(output_file, index=False)

print(f"Saved regression statistics table to: {output_file}")
print(results_df.head())