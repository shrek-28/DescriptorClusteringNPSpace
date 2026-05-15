import pandas as pd 
import glob
import os

missing_mol = pd.read_csv("Step_2_Feature_Generation/3D_desc_cleaner/problem_molecules.csv")
missing_mol['Molecule_ID'] = missing_mol['Molecule_ID'].str.replace(r'^minimized_|\.sdf$', '', regex=True)

folder_path = "Step_2_Feature_Generation/Physicochemical_Descriptors"

all_files = glob.glob(os.path.join(folder_path, "*.csv"))
df = pd.concat((pd.read_csv(f) for f in all_files), ignore_index=True)

missing_mol['Molecule_ID'] = missing_mol['Molecule_ID'].str.replace(r'^minimized_|/.sdf$', '', regex=True)

ids_to_check = missing_mol['Molecule_ID'].tolist()

final_df = df[~df['identifier'].isin(ids_to_check)].reset_index(drop=True)

final_df.to_csv("Step_2_Feature_Generation/Final_Compiled_Descriptor_Sets/Resulting_Data/physicochemical_compiled.csv")