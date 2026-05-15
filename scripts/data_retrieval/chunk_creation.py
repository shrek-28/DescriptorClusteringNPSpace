import pandas as pd
import math
import os

input_csv = r"C:/Users/admin/Documents/Major_Project/DATA/Step_1_Data/molecules.csv"  
output_dir = r"C:/Users/admin/Documents/Major_Project/DATA/Step_1_Data/split_chunks"         
chunk_size = 50000            

os.makedirs(output_dir, exist_ok=True)

df = pd.read_csv(input_csv)

df_sorted = df.sort_values(by="identifier")

num_chunks = math.ceil(len(df_sorted) / chunk_size)

for i in range(num_chunks):
    start = i * chunk_size
    end = start + chunk_size
    chunk = df_sorted.iloc[start:end]
    chunk_file = os.path.join(output_dir, f"chunk_{i+1}.csv")
    chunk.to_csv(chunk_file, index=False)
    print(f"Saved {chunk_file} with {len(chunk)} molecules")

print(f"Total molecules: {len(df_sorted)}, Total chunks: {num_chunks}")
