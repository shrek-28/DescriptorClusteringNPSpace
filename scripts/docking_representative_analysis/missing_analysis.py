import pandas as pd
import glob
import os

# =========================
# INPUTS
# =========================
rep_map_file = "data/full_clustering/stratified/representative_molecules_for_docking.csv"
results_folder = "data/representative_docking_results_files"  # folder containing *_results.csv files

# =========================
# LOAD REPRESENTATIVE MAP
# =========================
rep_df = pd.read_csv(rep_map_file)

# =========================
# BUILD LOOKUP FROM FILES
# =========================
rep_lookup = {}

for file in glob.glob(os.path.join(results_folder, "*_results.csv")):
    rep_type = os.path.basename(file).replace("_results.csv", "")

    df = pd.read_csv(file)

    # normalize ligand IDs
    ligands = (
        df["Ligand"]
        .str.replace("minimized_", "", regex=False)
        .str.strip()
        .tolist()
    )

    rep_lookup[rep_type] = set(ligands)

# =========================
# CHECK MISSING ENTRIES
# =========================
missing_records = []

for _, row in rep_df.iterrows():
    cluster = row["cluster"]
    rep_type = row["rep_type"]
    identifier = row["identifier"].strip()

    if rep_type not in rep_lookup:
        # optional: treat as fully missing category
        missing_records.append((cluster, rep_type, identifier, "rep_type_file_missing"))
        continue

    if identifier not in rep_lookup[rep_type]:
        missing_records.append((cluster, rep_type, identifier, "not_found_in_results"))

# =========================
# OUTPUT
# =========================
missing_df = pd.DataFrame(
    missing_records,
    columns=["cluster", "rep_type", "identifier", "issue"]
)

missing_df.to_csv("data/representative_analytics/missing_representatives.csv", index=False)

print(missing_df.head())
print("Total missing:", len(missing_df))