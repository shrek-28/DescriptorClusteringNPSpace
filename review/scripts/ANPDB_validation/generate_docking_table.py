
import argparse
import pandas as pd


def main():

    parser = argparse.ArgumentParser(
        description="Generate representative vs random docking comparison table."
    )

    parser.add_argument("--representatives", required=True,
                        help="Representative molecules CSV")
    parser.add_argument("--random", required=True,
                        help="Random molecules CSV")
    parser.add_argument("--scores", required=True,
                        help="Docking scores CSV")
    parser.add_argument("--cluster-sizes", required=True,
                        help="Cluster sizes CSV")
    parser.add_argument("--output", required=True,
                        help="Output CSV path")

    args = parser.parse_args()

    # Read input files
    reps = pd.read_csv(args.representatives)
    random = pd.read_csv(args.random)
    scores = pd.read_csv(args.scores)
    sizes = pd.read_csv(args.cluster_sizes)

    # Standardize identifiers
    reps["identifier"] = reps["identifier"].astype(str).str.strip()
    random["identifier"] = random["identifier"].astype(str).str.strip()
    scores["molecule"] = scores["molecule"].astype(str).str.strip()

    # Retain successful docking results
    scores = scores[scores["status"].str.lower() == "success"].copy()

    scores["best_score_kcal_mol"] = pd.to_numeric(
        scores["best_score_kcal_mol"], errors="coerce"
    )

    scores = scores.dropna(subset=["best_score_kcal_mol"])

    # Molecule-to-score mapping
    score_map = scores.set_index("molecule")["best_score_kcal_mol"]

    # Attach representative docking scores
    reps["docking_score"] = reps["identifier"].map(score_map)

    # Attach random molecule docking scores
    random["docking_score"] = random["identifier"].map(score_map)

    # Calculate average random docking score per cluster
    random_avg = (
        random.groupby("cluster_id")["docking_score"]
        .mean()
        .rename("avg_random")
    )

    # Pivot representative docking scores
    rep_table = reps.pivot_table(
        index="cluster",
        columns="rep_type",
        values="docking_score",
        aggfunc="first"
    )

    # Ensure all representative columns are present
    rep_columns = [
        "medoid",
        "centroid_closest",
        "diverse_1",
        "diverse_2",
        "diverse_3",
        "diverse_4",
        "diverse_5"
    ]

    rep_table = rep_table.reindex(columns=rep_columns)

    # Combine results
    result = (
        sizes.set_index("cluster_id")[["size_bin"]]
        .join(random_avg)
        .join(rep_table, how="left")
    )

    result.index.name = "cluster"

    # Final column order
    result = result.reset_index()

    result = result[
        ["cluster", "size_bin", "avg_random"] + rep_columns
    ]

    # Round docking scores
    score_columns = ["avg_random"] + rep_columns
    result[score_columns] = result[score_columns].round(3)

    # Save output
    result.to_csv(args.output, index=False)

    print(f"Output saved to: {args.output}")
    print(f"Total clusters: {len(result)}")


if __name__ == "__main__":
    main()
