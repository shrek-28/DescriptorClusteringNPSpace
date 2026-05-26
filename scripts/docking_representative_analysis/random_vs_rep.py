import pandas as pd
from pathlib import Path

# ==========================================
# INPUTS
# ==========================================
random_dir = Path("data/random_molecule_docking_results")

representatives_file = "data/representative_analytics/combined_representative_affinity_analysis.csv"

# ==========================================
# OUTPUT FILE
# ==========================================
output_file = "data/representative_analytics/random_vs_rep.csv"

# ==========================================
# LOAD REPRESENTATIVE DATA
# ==========================================
rep_df = pd.read_csv(representatives_file)

# ==========================================
# EXTRACT SIZE INFORMATION
# ==========================================
size_df = rep_df[
    ["cluster", "size_bin"]
].drop_duplicates()

# ==========================================
# PIVOT REPRESENTATIVE TABLE
# ==========================================
rep_pivot = rep_df.pivot_table(
    index="cluster",
    columns="rep_type",
    values="affinity",
    aggfunc="first"
).reset_index()

# ==========================================
# GET RANDOM FILES
# ==========================================
random_files = sorted(random_dir.glob("*_results.csv"))

results = []

# ==========================================
# PROCESS RANDOM FILES
# ==========================================
for rf in random_files:
    
    cluster = int(rf.stem.replace("_results", ""))
    
    # --------------------------------------
    # RANDOM MOLECULE AVERAGE
    # --------------------------------------
    random_df = pd.read_csv(rf)
    
    avg_random = random_df["Affinity (kcal/mol)"].mean()
    
    row = {
        "cluster": cluster,
        "avg_random": avg_random
    }
    
    results.append(row)

# ==========================================
# CREATE RANDOM SUMMARY TABLE
# ==========================================
random_summary = pd.DataFrame(results)

# ==========================================
# MERGE ALL TABLES
# ==========================================
final_df = (
    random_summary
    .merge(size_df, on="cluster", how="left")
    .merge(rep_pivot, on="cluster", how="left")
)

# ==========================================
# COLUMN ORDER
# ==========================================
final_df = final_df[
    [
        "cluster",
        "size_bin",
        "avg_random",
        "medoid",
        "centroid_closest",
        "diverse_1",
        "diverse_2",
        "diverse_3",
        "diverse_4",
        "diverse_5"
    ]
]

# ==========================================
# SAVE OUTPUT
# ==========================================
final_df.to_csv(output_file, index=False)

print(f"Saved: {output_file}")