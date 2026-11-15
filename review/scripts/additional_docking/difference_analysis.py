
import argparse
import itertools
from pathlib import Path

import numpy as np
import pandas as pd


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", required=True)
    parser.add_argument(
        "-o", "--output",
        default="../data/representative_analytics/difference_analysis"
    )
    args = parser.parse_args()

    output = Path(args.output)
    output.mkdir(parents=True, exist_ok=True)

    df = pd.read_csv(args.input)
    df.columns = (
        df.columns.str.replace("*", "", regex=False).str.strip()
    )

    molecules = [
        "medoid",
        "centroid_closest",
        "diverse_1",
        "diverse_2",
        "diverse_3",
        "diverse_4",
        "diverse_5"
    ]

    required = ["cluster", "size_bin", "avg_random"] + molecules
    missing = set(required) - set(df.columns)

    if missing:
        raise ValueError(f"Missing columns: {sorted(missing)}")

    df[molecules + ["avg_random"]] = df[
        molecules + ["avg_random"]
    ].apply(pd.to_numeric, errors="coerce")

    pairwise = []
    random_comparison = []
    summary = []

    for _, row in df.iterrows():

        cluster = row["cluster"]

        values = {
            m: row[m]
            for m in molecules
            if pd.notna(row[m])
        }

        scores = list(values.values())

        # Pairwise differences
        for mol1, mol2 in itertools.combinations(values, 2):

            score1 = values[mol1]
            score2 = values[mol2]

            pairwise.append({
                "cluster": cluster,
                "size_bin": row["size_bin"],
                "molecule_1": mol1,
                "molecule_2": mol2,
                "score_1": score1,
                "score_2": score2,
                "signed_difference": score2 - score1,
                "absolute_difference": abs(score2 - score1)
            })

        # Comparison against average random
        random_score = row["avg_random"]

        for molecule, score in values.items():

            if pd.notna(random_score):

                random_comparison.append({
                    "cluster": cluster,
                    "size_bin": row["size_bin"],
                    "molecule": molecule,
                    "docking_score": score,
                    "avg_random": random_score,
                    "signed_difference": score - random_score,
                    "absolute_difference": abs(
                        score - random_score
                    )
                })

        # Cluster-level summary
        pairwise_diffs = [
            abs(values[a] - values[b])
            for a, b in itertools.combinations(values, 2)
        ]

        summary.append({
            "cluster": cluster,
            "size_bin": row["size_bin"],
            "n_molecules": len(scores),
            "n_pairwise_comparisons": len(pairwise_diffs),
            "best_score": min(scores) if scores else np.nan,
            "worst_score": max(scores) if scores else np.nan,
            "score_range": (
                max(scores) - min(scores) if scores else np.nan
            ),
            "mean_score": np.mean(scores) if scores else np.nan,
            "std_score": np.std(scores) if scores else np.nan,
            "mean_pairwise_difference": (
                np.mean(pairwise_diffs)
                if pairwise_diffs else np.nan
            ),
            "median_pairwise_difference": (
                np.median(pairwise_diffs)
                if pairwise_diffs else np.nan
            ),
            "max_pairwise_difference": (
                max(pairwise_diffs)
                if pairwise_diffs else np.nan
            )
        })

    pd.DataFrame(pairwise).to_csv(
        output / "pairwise_differences.csv",
        index=False
    )

    pd.DataFrame(random_comparison).to_csv(
        output / "random_comparison.csv",
        index=False
    )

    pd.DataFrame(summary).to_csv(
        output / "difference_summary.csv",
        index=False
    )

    print(f"Analysis completed.")
    print(f"Output directory: {output.resolve()}")
    print(f"Clusters analysed: {len(summary)}")
    print(f"Pairwise comparisons: {len(pairwise)}")
    print(f"Random comparisons: {len(random_comparison)}")
    print(
        f"Clusters without valid representative scores: "
        f"{sum(s['n_molecules'] == 0 for s in summary)}"
    )


if __name__ == "__main__":
    main()
