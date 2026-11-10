
import argparse
import pandas as pd
from pathlib import Path


# =========================================================
# CONFIGURATION
# =========================================================

METHODS = [
    "medoid",
    "centroid_closest",
    "diverse_1",
    "diverse_2",
    "diverse_3",
    "diverse_4",
    "diverse_5"
]

# CLUSTERS_BY_SIZE = {
#     "small": [210, 398, 591, 802, 993],
#     "medium": [1308, 319, 811, 952, 971],
#     "large": [1292, 1313, 676, 831, 964]
# }

CLUSTERS_BY_SIZE = {
    "small": [],
    "medium": [],
    "large": []
}


# =========================================================
# LOAD RANDOM MOLECULE MAPPING
# =========================================================

def load_random_mapping(path):

    df = pd.read_csv(path, dtype=str)

    df.columns = df.columns.str.strip()

    if "cluster_id" not in df.columns and "cluster" in df.columns:
        df = df.rename(columns={"cluster": "cluster_id"})

    required = {"cluster_id", "identifier"}

    if not required.issubset(df.columns):
        raise ValueError(
            f"{path} must contain columns: {required}. "
            f"Found: {list(df.columns)}"
        )

    df["identifier"] = df["identifier"].str.strip()
    df["cluster_id"] = df["cluster_id"].str.strip()

    return df[["cluster_id", "identifier"]]


# =========================================================
# LOAD REPRESENTATIVE MOLECULE MAPPING
# =========================================================

def load_representative_mapping(path):

    df = pd.read_csv(path, dtype=str)

    df.columns = df.columns.str.strip()

    required = {"cluster", "rep_type", "identifier"}

    if not required.issubset(df.columns):
        raise ValueError(
            f"{path} must contain columns: {required}. "
            f"Found: {list(df.columns)}"
        )

    df = df.rename(
        columns={
            "cluster": "cluster_id",
            "rep_type": "method"
        }
    )

    df["cluster_id"] = df["cluster_id"].str.strip()
    df["identifier"] = df["identifier"].str.strip()
    df["method"] = df["method"].str.strip()

    invalid = set(df["method"].dropna()) - set(METHODS)

    if invalid:
        raise ValueError(
            f"Unknown representative types: {invalid}"
        )

    if df.duplicated(["cluster_id", "method"]).any():
        raise ValueError(
            "Duplicate representative methods found within a cluster."
        )

    if df["identifier"].duplicated().any():
        raise ValueError(
            "Duplicate representative identifiers found."
        )

    return df[["cluster_id", "identifier", "method"]]


# =========================================================
# LOAD DOCKING RESULTS
# =========================================================

def load_docking_results(path):

    df = pd.read_csv(path)

    df.columns = df.columns.str.strip()

    required = {
        "molecule",
        "best_score_kcal_mol",
        "status"
    }

    if not required.issubset(df.columns):
        raise ValueError(
            f"{path} must contain columns: {required}. "
            f"Found: {list(df.columns)}"
        )

    df["identifier"] = (
        df["molecule"]
        .astype(str)
        .str.replace(r"^minimized_", "", regex=True)
        .str.replace(r"\.[sS][dD][fF]$", "", regex=True)
        .str.strip()
    )

    df["best_score_kcal_mol"] = pd.to_numeric(
        df["best_score_kcal_mol"],
        errors="coerce"
    )

    df = df[
        (df["status"].astype(str).str.strip() == "success") &
        (df["best_score_kcal_mol"].notna())
    ].copy()

    return df


# =========================================================
# SELECT CLUSTERS BY SIZE STRATUM
# =========================================================

def filter_selected_clusters(clusters):

    selected = {
        size: [str(cluster) for cluster in ids]
        for size, ids in CLUSTERS_BY_SIZE.items()
        if ids
    }

    if not selected:
        return clusters

    mask = pd.Series(False, index=clusters.index)

    for size, ids in selected.items():

        mask |= (
            (clusters["size_bin"] == size) &
            (clusters["cluster_id"].isin(ids))
        )

    return clusters[mask].copy()


# =========================================================
# PROCESS RANDOM DOCKING
# =========================================================

def prepare_random_data(results, mapping):

    df = results.merge(
        mapping,
        on="identifier",
        how="inner",
        validate="many_to_one"
    )

    return (
        df.groupby("cluster_id")["best_score_kcal_mol"]
        .mean()
        .rename("avg_random")
        .reset_index()
    )


# =========================================================
# PROCESS REPRESENTATIVE DOCKING
# =========================================================

def prepare_representative_data(results, mapping):

    df = results.merge(
        mapping,
        on="identifier",
        how="inner",
        validate="one_to_one"
    )

    return (
        df.pivot(
            index="cluster_id",
            columns="method",
            values="best_score_kcal_mol"
        )
        .reset_index()
        .rename_axis(None, axis=1)
    )


# =========================================================
# MAIN
# =========================================================

def main():

    parser = argparse.ArgumentParser(
        description="Prepare random vs representative docking data."
    )

    parser.add_argument(
        "--random-results",
        required=True,
        help="Random docking results CSV"
    )

    parser.add_argument(
        "--representative-results",
        required=True,
        help="Representative docking results CSV"
    )

    parser.add_argument(
        "--random-molecules",
        required=True,
        help="Random molecule-to-cluster mapping CSV"
    )

    parser.add_argument(
        "--representative-molecules",
        required=True,
        help="Representative molecule mapping CSV"
    )

    parser.add_argument(
        "--clusters",
        required=True,
        help="Size-stratified validation clusters CSV"
    )

    parser.add_argument(
        "-o", "--output",
        required=True,
        help="Output CSV path"
    )

    args = parser.parse_args()

    # -----------------------------------------------------
    # LOAD DOCKING RESULTS
    # -----------------------------------------------------

    random_results = load_docking_results(
        args.random_results
    )

    representative_results = load_docking_results(
        args.representative_results
    )

    # -----------------------------------------------------
    # LOAD MOLECULE MAPPINGS
    # -----------------------------------------------------

    random_mapping = load_random_mapping(
        args.random_molecules
    )

    representative_mapping = load_representative_mapping(
        args.representative_molecules
    )

    # -----------------------------------------------------
    # LOAD CLUSTER INFORMATION
    # -----------------------------------------------------

    clusters = pd.read_csv(
        args.clusters,
        dtype={"cluster_id": str}
    )

    clusters.columns = clusters.columns.str.strip()

    if not {"cluster_id", "size_bin"}.issubset(clusters.columns):
        raise ValueError(
            "Cluster file must contain cluster_id and size_bin."
        )

    clusters["cluster_id"] = clusters["cluster_id"].str.strip()
    clusters["size_bin"] = (
        clusters["size_bin"].str.strip().str.lower()
    )

    clusters = clusters[
        ["cluster_id", "size_bin"]
    ]

    if clusters["cluster_id"].duplicated().any():
        raise ValueError(
            "Duplicate cluster IDs found in validation cluster file."
        )

    # -----------------------------------------------------
    # FILTER SELECTED CLUSTERS
    # -----------------------------------------------------

    clusters = filter_selected_clusters(clusters)

    if clusters.empty:
        raise ValueError(
            "No clusters selected. Check CLUSTERS_BY_SIZE."
        )

    print("\nSelected clusters:")

    for size in ["small", "medium", "large"]:

        selected = clusters.loc[
            clusters["size_bin"] == size,
            "cluster_id"
        ].tolist()

        print(f"{size}: {selected}")

    # -----------------------------------------------------
    # PROCESS RANDOM DOCKING
    # -----------------------------------------------------

    random_df = prepare_random_data(
        random_results,
        random_mapping
    )

    # -----------------------------------------------------
    # PROCESS REPRESENTATIVE DOCKING
    # -----------------------------------------------------

    representative_df = prepare_representative_data(
        representative_results,
        representative_mapping
    )

    # -----------------------------------------------------
    # COMBINE DATASETS
    # -----------------------------------------------------

    final_df = (
        clusters
        .merge(
            random_df,
            on="cluster_id",
            how="left"
        )
        .merge(
            representative_df,
            on="cluster_id",
            how="left"
        )
    )

    # -----------------------------------------------------
    # ENSURE ALL METHOD COLUMNS EXIST
    # -----------------------------------------------------

    for method in METHODS:

        if method not in final_df.columns:
            final_df[method] = pd.NA

    # -----------------------------------------------------
    # FINAL COLUMN FORMAT
    # -----------------------------------------------------

    final_df = final_df.rename(
        columns={
            "cluster_id": "cluster"
        }
    )

    final_df = final_df[
        [
            "cluster",
            "size_bin",
            "avg_random",
            *METHODS
        ]
    ]

    # -----------------------------------------------------
    # SAVE OUTPUT
    # -----------------------------------------------------

    output = Path(args.output)

    output.parent.mkdir(
        parents=True,
        exist_ok=True
    )

    final_df.to_csv(
        output,
        index=False
    )

    # -----------------------------------------------------
    # SUMMARY
    # -----------------------------------------------------

    print("\nProcessing complete.")
    print(f"Output: {output}")
    print(f"Clusters: {len(final_df)}")
    print(
        f"Random docking successes: {len(random_results)}"
    )
    print(
        f"Representative docking successes: "
        f"{len(representative_results)}"
    )

    print("\nMissing values per method:")
    print(
        final_df[
            ["avg_random", *METHODS]
        ].isna().sum()
    )


if __name__ == "__main__":
    main()
