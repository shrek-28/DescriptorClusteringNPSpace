import os
import pandas as pd
import numpy as np

ROOT_DIR = "data/methods"

# Store all values
results = []

# Traverse methods
for method in os.listdir(ROOT_DIR):

    method_path = os.path.join(ROOT_DIR, method)

    if not os.path.isdir(method_path):
        continue

    # Traverse descriptor folders
    for desc_folder in os.listdir(method_path):

        desc_path = os.path.join(method_path, desc_folder)

        if not os.path.isdir(desc_path):
            continue

        # Extract descriptor count
        desc_count = int(desc_folder.split("_")[0])

        # Traverse band files
        for band_num in range(1, 5):

            band_file = os.path.join(desc_path, f"band{band_num}.csv")

            if not os.path.exists(band_file):
                continue

            # Read correlation matrix
            corr_matrix = pd.read_csv(band_file, index_col=0)

            # Remove diagonal
            mask = ~np.eye(corr_matrix.shape[0], dtype=bool)

            # Compute mean absolute correlation
            mean_corr = np.abs(corr_matrix.where(mask)).stack().mean()

            results.append({
                "method": method,
                "band": f"band{band_num}",
                "descriptor_count": desc_count,
                "mean_abs_correlation": mean_corr
            })

# Full dataframe
results_df = pd.DataFrame(results)

# ============================================================
# 3-WAY HEATMAP DATA
# rows    -> method + band
# columns -> descriptor count
# values  -> mean absolute correlation
# ============================================================

heatmap_df = results_df.pivot_table(
    index=["method", "band"],
    columns="descriptor_count",
    values="mean_abs_correlation"
)

# Save
results_df.to_csv("data/method_analysis/correlation_analysis/full_summary.csv", index=False)
heatmap_df.to_csv("data/method_analysis/correlation_analysis/heatmap_3way.csv")

print("\n=== Heatmap Data ===")
print(heatmap_df)

print("\nSaved:")
print("- full_summary.csv")
print("- heatmap_3way.csv")