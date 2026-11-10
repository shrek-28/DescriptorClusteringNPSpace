
import argparse
import ast
import os

import numpy as np
import pandas as pd


def parse_args():
    parser = argparse.ArgumentParser(
        description="Prepare size-stratified clusters and molecules for docking."
    )

    parser.add_argument("--cluster-sizes", required=True)
    parser.add_argument("--cluster-molecules", required=True)
    parser.add_argument("--representatives", required=True)
    parser.add_argument(
        "--output",
        default="DATA/full_clustering_stratified"
    )
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--clusters-per-stratum", type=int, default=7)
    parser.add_argument("--molecules-per-cluster", type=int, default=25)

    return parser.parse_args()


def main():
    args = parse_args()

    os.makedirs(args.output, exist_ok=True)

    rng = np.random.default_rng(args.seed)

    # Load input files
    cluster_sizes = pd.read_csv(args.cluster_sizes)
    cluster_molecules = pd.read_csv(args.cluster_molecules)
    representatives = pd.read_csv(args.representatives)

    # Identify cluster ID column
    if "cluster_id" not in cluster_sizes.columns:
        if "Unnamed: 0" in cluster_sizes.columns:
            cluster_sizes.rename(
                columns={"Unnamed: 0": "cluster_id"},
                inplace=True
            )
        elif cluster_sizes.columns[0].startswith("Unnamed:"):
            cluster_sizes.rename(
                columns={cluster_sizes.columns[0]: "cluster_id"},
                inplace=True
            )
        else:
            cluster_sizes.reset_index(inplace=True)
            cluster_sizes.rename(
                columns={"index": "cluster_id"},
                inplace=True
            )

    # Remove noise cluster
    cluster_sizes = cluster_sizes[
        cluster_sizes["cluster_id"] != -1
    ].copy()

    # Parse molecule lists
    cluster_molecules["identifier"] = cluster_molecules[
        "identifier"
    ].apply(ast.literal_eval)

    # Create three size strata
    cluster_sizes["size_bin"] = pd.qcut(
        cluster_sizes["post_size"].rank(method="first"),
        q=3,
        labels=["small", "medium", "large"]
    )

    # Select clusters
    selected_clusters = []

    for size_bin in ["small", "medium", "large"]:

        subset = cluster_sizes[
            cluster_sizes["size_bin"] == size_bin
        ]

        if len(subset) < args.clusters_per_stratum:
            raise ValueError(
                f"Only {len(subset)} clusters available in "
                f"{size_bin} stratum; "
                f"{args.clusters_per_stratum} required."
            )

        sampled = subset.sample(
            n=args.clusters_per_stratum,
            random_state=args.seed
        )

        selected_clusters.append(sampled)

    selected_clusters = pd.concat(
        selected_clusters,
        ignore_index=True
    )

    selected_cluster_ids = selected_clusters[
        "cluster_id"
    ].tolist()

    selected_clusters.to_csv(
        os.path.join(
            args.output,
            "validation_clusters_size_stratified.csv"
        ),
        index=False
    )

    # Random sampling excluding representatives
    random_rows = []

    for cid in selected_cluster_ids:

        mols = cluster_molecules.loc[
            cluster_molecules["cluster_post"] == cid,
            "identifier"
        ].iloc[0]

        reps = representatives.loc[
            representatives["cluster"] == cid,
            "identifier"
        ].tolist()

        representative_set = set(reps)

        available_molecules = [
            molecule for molecule in mols
            if molecule not in representative_set
        ]

        n = min(
            args.molecules_per_cluster,
            len(available_molecules)
        )

        sampled = rng.choice(
            available_molecules,
            size=n,
            replace=False
        )

        for molecule in sampled:
            random_rows.append({
                "cluster_id": cid,
                "identifier": molecule
            })

    random_molecules_df = pd.DataFrame(
        random_rows,
        columns=["cluster_id", "identifier"]
    )

    random_molecules_df.to_csv(
        os.path.join(
            args.output,
            "random_molecules_for_docking.csv"
        ),
        index=False
    )

    # Select representatives from the same clusters
    rep_validation = representatives[
        representatives["cluster"].isin(selected_cluster_ids)
    ].copy()

    rep_validation.to_csv(
        os.path.join(
            args.output,
            "representative_molecules_for_docking.csv"
        ),
        index=False
    )

    # Combine and remove any remaining duplicate identifiers
    all_molecules = pd.concat(
        [
            random_molecules_df[["identifier"]],
            rep_validation[["identifier"]]
        ],
        ignore_index=True
    ).drop_duplicates(subset="identifier")

    all_molecules.to_csv(
        os.path.join(
            args.output,
            "ALL_molecules_for_docking.txt"
        ),
        index=False,
        header=False
    )

    # Summary
    print("\nValidation selection summary")
    print("----------------------------")

    for size_bin in ["small", "medium", "large"]:

        selected = selected_clusters[
            selected_clusters["size_bin"] == size_bin
        ]

        cluster_ids = selected["cluster_id"].tolist()

        n_random = len(
            random_molecules_df[
                random_molecules_df["cluster_id"].isin(cluster_ids)
            ]
        )

        n_reps = len(
            rep_validation[
                rep_validation["cluster"].isin(cluster_ids)
            ]
        )

        print(
            f"{size_bin.capitalize()}: "
            f"{len(selected)} clusters, "
            f"{n_random} random molecules, "
            f"{n_reps} representatives"
        )

    print("\nTotal selected clusters:", len(selected_clusters))
    print("Total random molecules:", len(random_molecules_df))
    print("Total representatives:", len(rep_validation))
    print("Unique molecules for docking:", len(all_molecules))
    print("\nOutput directory:", args.output)


if __name__ == "__main__":
    main()
