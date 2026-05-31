import pandas as pd
from collections import Counter
import ast

# Load dataset
df = pd.read_csv("data/method_analysis/descriptor_lists.csv")

# Convert descriptor strings to lists
df['descriptors'] = df['descriptors'].apply(ast.literal_eval)

# Flatten descriptor list
all_descriptors = [
    descriptor
    for descriptor_list in df['descriptors']
    for descriptor in descriptor_list
]

# Count occurrences
descriptor_counts = Counter(all_descriptors)

# Total number of rows
n_rows = len(df)

# Build results table
result_df = pd.DataFrame(
    descriptor_counts.items(),
    columns=['descriptor', 'count']
)

# Percentage occurrence = (count / number of rows) * 100
result_df['percentage_occurrence'] = (
    result_df['count'] / n_rows * 100
).round(2)

# Sort descending
result_df = result_df.sort_values(
    by='count',
    ascending=False
).reset_index(drop=True)

result_df.to_csv("data/method_analysis/descriptor_occurrence_analysis.csv", index=False)