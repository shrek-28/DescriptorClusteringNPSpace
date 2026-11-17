import argparse
import pandas as pd
import numpy as np


def main():
    parser = argparse.ArgumentParser(
        description="Classify HDBSCAN clusters based on core fractions and membership probability IQR."
    )

    parser.add_argument("--prob", required=True, help="Path to hdbscan_core_assignments.csv")
    parser.add_argument("--umap", required=True, help="Path to umap_with_clusters.csv")
    parser.add_argument("--output", required=True, help="Output CSV path")

    args = parser.parse_args()

    df_prob = pd.read_csv(args.prob)
    df_umap = pd.read_csv(args.umap)

    # Core fraction
    core_stats = (
        df_prob
        .assign(is_core=lambda x: x["probability"] >= 0.9)
        .groupby("cluster_core")
        .agg(core_size=("is_core", "sum"))
        .reset_index()
    )

    # Post-noise cluster size
    post_size = (
        df_umap
        .groupby("cluster_post")
        .agg(post_noise_size=("identifier", "count"))
        .reset_index()
        .rename(columns={"cluster_post": "cluster_core"})
    )

    # Merge sizes
    table1 = core_stats.merge(
        post_size,
        on="cluster_core",
        how="inner"
    )

    table1["core_fraction"] = (
        table1["core_size"] / table1["post_noise_size"]
    )

    # Probability IQR
    prob_iqr = (
        df_prob
        .groupby("cluster_core")["probability"]
        .quantile([0.25, 0.75])
        .unstack()
        .reset_index()
    )

    prob_iqr.columns = ["cluster_core", "q1", "q3"]
    prob_iqr["prob_IQR"] = prob_iqr["q3"] - prob_iqr["q1"]

    # Merge IQR
    table1 = table1.merge(
        prob_iqr[["cluster_core", "prob_IQR"]],
        on="cluster_core"
    )

    # Final verdict
    def verdict(row):
        if row.core_fraction < 0.3 and row.prob_IQR > 0.4:
            return "reject"
        if row.core_fraction >= 0.5:
            return "accept"
        return "borderline"

    table1["final_verdict"] = table1.apply(verdict, axis=1)

    table1.to_csv(args.output, index=False)

    print(f"Cluster classification saved to: {args.output}")
    print(f"Total clusters classified: {len(table1)}")


if __name__ == "__main__":
    main()