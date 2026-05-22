# Descriptor Overlap + Unique Descriptor Analysis
import pandas as pd
import itertools
import ast

# LOAD DATA
df = pd.read_csv("data/method_analysis/descriptor_lists.csv")

# CONVERT STRING LIST --> PYTHON SET
df["descriptor_set"] = df["descriptors"].apply(
    lambda x: set(ast.literal_eval(x))
)

# FUNCTION: COMPUTE OVERLAPS

def compute_overlap(data, compare_col):

    results = []

    unique_values = sorted(data[compare_col].unique())

    # -----------------------------------------------------
    # ALL COMBINATIONS
    # -----------------------------------------------------

    for r in range(2, len(unique_values) + 1):

        for combo in itertools.combinations(unique_values, r):

            descriptor_sets = []

            for val in combo:

                temp = data[
                    data[compare_col] == val
                ]

                merged_set = set.union(
                    *temp["descriptor_set"].tolist()
                )

                descriptor_sets.append(merged_set)

            common = set.intersection(*descriptor_sets)

            results.append({
                "comparison":
                    " vs ".join(map(str, combo)),

                "n_common":
                    len(common),

                "common_descriptors":
                    ", ".join(sorted(common)),

                "analysis_type":
                    "overlap"
            })

    return pd.DataFrame(results)

# FUNCTION: COMPUTE UNIQUE DESCRIPTORS
def compute_unique(data, compare_col):

    results = []

    unique_values = sorted(data[compare_col].unique())

    descriptor_dict = {}

    # STORE DESCRIPTOR SETS
    for val in unique_values:

        temp = data[
            data[compare_col] == val
        ]

        descriptor_dict[val] = set.union(
            *temp["descriptor_set"].tolist()
        )

    # FIND UNIQUE DESCRIPTORS
    for val in unique_values:

        current = descriptor_dict[val]

        other_sets = [
            descriptor_dict[x]
            for x in unique_values
            if x != val
        ]

        others = set.union(*other_sets)

        unique_desc = current - others

        results.append({
            "comparison": str(val),

            "n_common": len(unique_desc),

            "common_descriptors":
                ", ".join(sorted(unique_desc)),

            "analysis_type":
                "unique"
        })

    return pd.DataFrame(results)

# 1. ACROSS DESCRIPTOR COUNTS - Keep method + band constant

descriptor_count_results = []

for method in df["method"].unique():

    for band in df["band"].unique():

        temp = df[
            (df["method"] == method) &
            (df["band"] == band)
        ]

        if len(temp) < 2:
            continue

        overlap_res = compute_overlap(
            temp,
            compare_col="desc_count"
        )

        unique_res = compute_unique(
            temp,
            compare_col="desc_count"
        )

        combined = pd.concat(
            [overlap_res, unique_res],
            ignore_index=True
        )

        combined["method"] = method
        combined["band"] = band

        descriptor_count_results.append(combined)

descriptor_count_results = pd.concat(
    descriptor_count_results,
    ignore_index=True
)

# 2. ACROSS METHODS - Keep descriptor count + band constant
method_results = []

for count in df["desc_count"].unique():

    for band in df["band"].unique():

        temp = df[
            (df["desc_count"] == count) &
            (df["band"] == band)
        ]

        if len(temp) < 2:
            continue

        overlap_res = compute_overlap(
            temp,
            compare_col="method"
        )

        unique_res = compute_unique(
            temp,
            compare_col="method"
        )

        combined = pd.concat(
            [overlap_res, unique_res],
            ignore_index=True
        )

        combined["desc_count"] = count
        combined["band"] = band

        method_results.append(combined)

method_results = pd.concat(
    method_results,
    ignore_index=True
)

# 3. ACROSS BANDS - Keep descriptor count + method constant
band_results = []

for count in df["desc_count"].unique():

    for method in df["method"].unique():

        temp = df[
            (df["desc_count"] == count) &
            (df["method"] == method)
        ]

        if len(temp) < 2:
            continue

        overlap_res = compute_overlap(
            temp,
            compare_col="band"
        )

        unique_res = compute_unique(
            temp,
            compare_col="band"
        )

        combined = pd.concat(
            [overlap_res, unique_res],
            ignore_index=True
        )

        combined["desc_count"] = count
        combined["method"] = method

        band_results.append(combined)

band_results = pd.concat(
    band_results,
    ignore_index=True
)

# # EXPORT RESULTS

descriptor_count_results.to_csv(
    "data/method_analysis/across_descriptor_counts.csv",
    index=False
)

method_results.to_csv(
    "data/method_analysis/across_methods.csv",
    index=False
)

band_results.to_csv(
    "data/method_analysis/across_bands.csv",
    index=False
)

# OPTIONAL: SHOW SAMPLE OUTPUTS

print("ACROSS BANDS")

print(
    band_results.head(20)
)

print("ACROSS DESCRIPTOR COUNTS")

print(
    descriptor_count_results.head(20)
)

print("ACROSS METHODS")

print(
    method_results.head(20)
)