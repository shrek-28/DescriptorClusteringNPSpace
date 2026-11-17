
import argparse
import pandas as pd
import numpy as np


def main():
    parser = argparse.ArgumentParser(
        description="Calculate HDBSCAN cluster membership probability statistics."
    )

    parser.add_argument("--input", required=True, help="HDBSCAN assignments CSV")
    parser.add_argument("--output", required=True, help="Output CSV path")

    args = parser.parse_args()

    # Load HDBSCAN assignments
    df = pd.read_csv(args.input)

    # Remove noise cluster
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
    cluster_stats["IQR_probability"] = (
        cluster_stats["q75"] - cluster_stats["q25"]
    )

    # Drop intermediate percentiles
    cluster_stats = cluster_stats.drop(columns=["q25", "q75"])

    # Save results
    cluster_stats.to_csv(args.output, index=False)

    print(cluster_stats)
    print(f"\nResults saved to: {args.output}")
    print(f"Total clusters processed: {len(cluster_stats)}")


if __name__ == "__main__":
    main()
