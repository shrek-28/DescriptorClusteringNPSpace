# Descriptor Occurrence Analysis and Percentage Plots
import pandas as pd
import ast
from collections import Counter

# =========================
# Load dataset
# =========================

df = pd.read_csv("data/method_analysis/descriptor_lists.csv")

# Convert string lists into Python lists
df['descriptors'] = df['descriptors'].apply(ast.literal_eval)

# =========================
# Descriptor occurrence table
# =========================

def generate_descriptor_table(subset_df):
    all_descriptors = [
        descriptor
        for descriptor_list in subset_df['descriptors']
        for descriptor in descriptor_list
    ]

    descriptor_counts = Counter(all_descriptors)

    result_df = pd.DataFrame(
        descriptor_counts.items(),
        columns=['descriptor', 'count']
    )

    n_rows = len(subset_df)

    result_df['percentage_occurrence'] = (
        result_df['count'] / n_rows * 100
    ).round(2)

    result_df = result_df.sort_values(
        by='count',
        ascending=False
    ).reset_index(drop=True)

    return result_df

# =========================
# Generate tables for all methods
# =========================

methods = df['method'].unique()

for method in methods:

    method_df = df[df['method'] == method]

    result_df = generate_descriptor_table(method_df)

    print(f"\n===== {method} =====")
    print(result_df)

    # Save table
    result_df.to_csv(f"data/method_analysis/desc_method_wise/{method}_descriptor_occurrence.csv", index=False)

# =========================
# Generate tables for each band and descriptor count
# =========================

bands = ['band1', 'band2', 'band3', 'band4']
descriptor_counts = [10, 15, 20, 25]

for method in methods:
    for band in bands:
        for desc_count in descriptor_counts:

            subset_df = df[
                (df['method'] == method) &
                (df['band'] == band) &
                (df['desc_count'] == desc_count)
            ]

            if len(subset_df) == 0:
                continue

            result_df = generate_descriptor_table(subset_df)

            filename = f"data/method_analysis/desc_band_wise/{method}_{band}_{desc_count}_occurrence.csv"
            result_df.to_csv(filename, index=False)

print("Analysis complete.")
