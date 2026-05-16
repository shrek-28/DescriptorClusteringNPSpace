import glob
import pandas as pd
import os

folder = "DATA/Step_1_Data/split_chunks"
files = glob.glob(os.path.join(folder, "*.csv"))

chunks_df = pd.concat(
    (pd.read_csv(f) for f in files),
    ignore_index=True
)

other_df = pd.read_csv("DATA/final_complete_descriptor_matrix.csv")

final_df = chunks_df.merge(
    other_df,
    on="identifier",        # exact column name
    how="inner"             # change if you know what you're doing
)

final_df = final_df[['identifier', 'canonical_smiles']]
final_df.to_csv("top_scaffolds/smiles_data_full.csv")