
import argparse
import pandas as pd
import numpy as np
from scipy.stats import skew, kurtosis


def main():

    parser = argparse.ArgumentParser(
        description="Perform representative statistics and difference analysis."
    )

    parser.add_argument(
        "--input",
        required=True,
        help="Input cluster chemical profile CSV file"
    )

    parser.add_argument(
        "--stats-output",
        default="data/cluster_profiling/representative_analysis.csv",
        help="Output CSV file for representative statistics"
    )

    parser.add_argument(
        "--difference-output",
        default="data/cluster_profiling/representative_difference_analysis.csv",
        help="Output CSV file for representative difference analysis"
    )

    args = parser.parse_args()

    # =========================
    # LOAD DATA
    # =========================
    df = pd.read_csv(args.input)

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

                "min": round(series.min(), 2),
                "max": round(series.max(), 2),
                "mean": round(series.mean(), 2),
                "median": round(series.median(), 2),
                "std_dev": round(series.std(), 2),
                "variance": round(series.var(), 2),
                "skew": round(skew(series), 2),
                "kurtosis": round(kurtosis(series), 2)
            })

    stats_df = pd.DataFrame(stats_results)
    stats_df.to_csv(args.stats_output, index=False)

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

        # AVG ABS DIFFERENCE BETWEEN 5 DIVERSE REPS
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

        # |mean - rep| and |median - rep|
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

                "avg_abs_mean_difference": round(mean_abs_diff, 2),
                "avg_abs_median_difference": round(median_abs_diff, 2),

                "avg_pairwise_diverse_difference":
                    round(avg_diverse_difference, 2)
            })

    difference_df = pd.DataFrame(difference_results)

    difference_df.to_csv(args.difference_output, index=False)

    print(f"Saved statistics table: {args.stats_output}")
    print(f"Saved difference table: {args.difference_output}")


if __name__ == "__main__":
    main()
