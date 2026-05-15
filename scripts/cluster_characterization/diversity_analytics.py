import pandas as pd
import numpy as np
import ast
import time
from rdkit import Chem
from rdkit.Chem import rdFingerprintGenerator
from rdkit.DataStructs import TanimotoSimilarity

start_time = time.time()
print("Loading files...")

# =========================
# Load files
# =========================
cluster_post_df = pd.read_csv("DATA/full_clustering_results/cluster_molecules_post.csv")
medoid_df = pd.read_csv("DATA/full_clustering_results/cluster_medoids.csv")
smiles_df = pd.read_csv("DATA/molecules.csv")  # identifier, canonical_smiles

# =========================
# Fingerprint generator (modern API)
# =========================
print("Initializing Morgan fingerprint generator...")

morgan_gen = rdFingerprintGenerator.GetMorganGenerator(
    radius=2,
    fpSize=2048
)

def get_fp(smiles):
    mol = Chem.MolFromSmiles(smiles)
    if mol is None:
        return None
    return morgan_gen.GetFingerprint(mol)

# Compute fingerprints once
print("Computing fingerprints...")
smiles_df["fp"] = smiles_df["canonical_smiles"].apply(get_fp)

# Build lookup dictionary
fp_dict = dict(zip(smiles_df["identifier"], smiles_df["fp"]))

print("Fingerprints ready.")

# =========================
# 1️⃣ Within-cluster similarity
# =========================
print("Computing within-cluster similarity...")

cluster_within_results = []

for row in cluster_post_df.itertuples():
    cluster_id = row.cluster_post
    mol_ids = ast.literal_eval(row.identifier)

    fps = [fp_dict.get(mid) for mid in mol_ids if fp_dict.get(mid) is not None]

    if len(fps) < 2:
        continue

    sims = []

    for i in range(len(fps)):
        for j in range(i + 1, len(fps)):
            sims.append(TanimotoSimilarity(fps[i], fps[j]))

    mean_within = np.mean(sims)

    cluster_within_results.append({
        "cluster_id": cluster_id,
        "mean_within_similarity": mean_within
    })

within_df = pd.DataFrame(cluster_within_results)

# =========================
# 2️⃣ Between-cluster medoid similarity
# =========================
print("Computing between-cluster medoid similarity...")

medoid_ids = medoid_df["medoid_identifier"].tolist()
medoid_fps = [fp_dict.get(mid) for mid in medoid_ids if fp_dict.get(mid) is not None]

between_sims = []

for i in range(len(medoid_fps)):
    for j in range(i + 1, len(medoid_fps)):
        between_sims.append(
            TanimotoSimilarity(medoid_fps[i], medoid_fps[j])
        )

mean_between = np.mean(between_sims) if between_sims else 0

# =========================
# Combine results
# =========================
within_df["mean_between_medoid_similarity"] = mean_between
within_df["separation_ratio"] = (
    within_df["mean_within_similarity"] / mean_between
    if mean_between != 0 else np.nan
)

within_df.to_csv("DATA/cluster_profiling/cluster_similarity_validation.csv", index=False)

print("\nDone.")
print(f"Mean between-cluster medoid similarity: {mean_between:.4f}")
print(f"Finished in {time.time() - start_time:.2f} seconds.")