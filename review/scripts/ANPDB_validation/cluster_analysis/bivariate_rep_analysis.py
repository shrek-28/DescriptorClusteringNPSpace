
import argparse
import pandas as pd
from scipy.stats import linregress


def main():

    parser = argparse.ArgumentParser(
        description="Perform linear regression analysis between cluster representatives."
    )

    parser.add_argument(
        "--input",
        required=True,
        help="Input cluster chemical profile CSV file"
    )

    parser.add_argument(
        "--output",
        default="data/cluster_profiling/descriptor_regression_statistics.csv",
        help="Output CSV file for regression statistics"
    )

    args = parser.parse_args()

    # =====================================
    # LOAD DATA
    # =====================================
    df = pd.read_csv(args.input)

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

            if x_col not in df.columns or y_col not in df.columns:
                continue

            temp_df = df[[x_col, y_col]].copy()

            temp_df[x_col] = pd.to_numeric(temp_df[x_col], errors="coerce")
            temp_df[y_col] = pd.to_numeric(temp_df[y_col], errors="coerce")

            temp_df = temp_df.dropna()

            x = temp_df[x_col]
            y = temp_df[y_col]

            if len(temp_df) < 2 or x.nunique() < 2:
                continue

            # LINEAR REGRESSION
            regression = linregress(x, y)

            r_value = regression.rvalue
            r_squared = r_value ** 2
            slope = regression.slope

            results.append({
                "descriptor": descriptor,
                "comparison": comparison_name,

                "x_column": x_col,
                "y_column": y_col,

                "R": round(r_value, 2),
                "R2": round(r_squared, 2),
                "slope": round(slope, 2),
                "intercept": round(regression.intercept, 2)
            })

    # =====================================
    # SAVE OUTPUT
    # =====================================
    results_df = pd.DataFrame(results)

    results_df.to_csv(args.output, index=False)

    print(f"Saved regression statistics table to: {args.output}")
    print(results_df.head())


if __name__ == "__main__":
    main()
