from pathlib import Path
import pandas as pd

# Root folder
root_dir = Path("/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/methods")

results = []

# Traverse all band CSVs
for csv_file in root_dir.rglob("band*.csv"):
    
    # Extract metadata
    method = csv_file.parts[-3]
    desc_count = csv_file.parts[-2].split("_")[0]
    band = csv_file.stem
    
    # Read only header
    df = pd.read_csv(csv_file, nrows=0)
    
    # Remove first column from headers
    descriptors = df.columns[1:].tolist()
    
    results.append({
        "method": method,
        "desc_count": desc_count,
        "band": band,
        "descriptors": descriptors
    })

# Convert to dataframe
results_df = pd.DataFrame(results)

results_df.to_csv("data/method_analysis/descriptor_lists.csv", index=False)