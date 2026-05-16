# =============================
# CONFIGURATION
# =============================

INPUT_CSV = r"top_scaffolds/smiles_data_full.csv"
SMILES_COLUMN = "canonical_smiles"

OUTPUT_ALL_SCAFFOLDS = r"c:/Users/admin/Documents/Major_Project/top_scaffolds/all_bemis_murcko_scaffolds_with_frequency.csv"
OUTPUT_TOP_20 = r"c:/Users/admin/Documents/Major_Project/top_scaffolds/top_20_bemis_murcko_scaffolds.csv"

CHUNK_SIZE = 10000


# =============================
# IMPORTS
# =============================

from rdkit import Chem
from rdkit.Chem.Scaffolds import MurckoScaffold
from collections import Counter
from tqdm import tqdm
import pandas as pd


# =============================
# LOAD DATA
# =============================

print("Loading SMILES file...")
df = pd.read_csv(INPUT_CSV)

if SMILES_COLUMN not in df.columns:
    raise ValueError(f"Column '{SMILES_COLUMN}' not found in input file")

smiles_list = df[SMILES_COLUMN].dropna().astype(str).tolist()
total_smiles = len(smiles_list)

print(f"Total SMILES loaded: {total_smiles}")


# =============================
# SCAFFOLD EXTRACTION (CHUNKED)
# =============================

scaffold_counts = Counter()
failed = 0
processed = 0

for i in tqdm(range(0, total_smiles, CHUNK_SIZE), desc="Processing chunks"):
    chunk = smiles_list[i:i + CHUNK_SIZE]

    for smi in chunk:
        processed += 1

        mol = Chem.MolFromSmiles(smi)
        if mol is None:
            failed += 1
            continue

        # Skip disconnected structures (salts, mixtures)
        if len(Chem.GetMolFrags(mol)) > 1:
            continue


        try:
            scaffold = MurckoScaffold.GetScaffoldForMol(mol)
            if scaffold is None:
                continue

            scaf_smi = Chem.MolToSmiles(scaffold, canonical=True)

            if scaf_smi == "":
                continue
            scaffold_counts[scaf_smi] += 1

        except Exception:
            failed += 1
            continue


print("\nProcessing complete.")
print(f"Total molecules processed: {processed}")
print(f"Failed molecules: {failed}")
print(f"Unique scaffolds found: {len(scaffold_counts)}")


# =============================
# SAVE ALL SCAFFOLDS
# =============================

print("\nSaving all scaffolds...")

all_scaffolds_df = pd.DataFrame(
    scaffold_counts.items(),
    columns=["bemis_murcko_scaffold_smiles", "frequency"]
).sort_values("frequency", ascending=False)

all_scaffolds_df.to_csv(OUTPUT_ALL_SCAFFOLDS, index=False)

print(f"Saved: {OUTPUT_ALL_SCAFFOLDS}")


# =============================
# SAVE TOP 20 SCAFFOLDS
# =============================

print("\nSaving top 20 scaffolds...")

top_20_df = all_scaffolds_df.head(20)
top_20_df.to_csv(OUTPUT_TOP_20, index=False)

print(f"Saved: {OUTPUT_TOP_20}")


print("\nDONE.")
