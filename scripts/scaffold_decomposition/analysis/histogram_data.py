import pandas as pd

# Read dataset
df = pd.read_csv("data/scaffold_decomposition/all_bemis_murcko_scaffolds_with_frequency.csv")

# 1. BIN SIZE = 50  (1–1000)

bins_50 = list(range(0, 1001, 50))
table_50 = (
    pd.cut(
        df["frequency"],
        bins=bins_50,
        right=True
    )
    .value_counts()
    .sort_index()
    .reset_index()
)
table_50.columns = ["Frequency_Bin", "Scaffold_Count"]
print("\n===== BIN SIZE 50 (1–1000) =====")
print(table_50)

# 2. BIN SIZE = 10  (1–100)

bins_10 = list(range(0, 101, 10))
table_10 = (
    pd.cut(
        df["frequency"],
        bins=bins_10,
        right=True
    )
    .value_counts()
    .sort_index()
    .reset_index()
)
table_10.columns = ["Frequency_Bin", "Scaffold_Count"]
print("\n===== BIN SIZE 10 (1–100) =====")
print(table_10)

# 3. EXACT FREQUENCY COUNTS (1–10)
table_exact_1_10 = (
    df[df["frequency"].between(1, 10)]["frequency"]
    .value_counts()
    .sort_index()
    .reset_index()
)

table_exact_1_10.columns = ["Frequency", "Scaffold_Count"]

print("\n===== EXACT FREQUENCY COUNTS (1–10) =====")
print(table_exact_1_10)

table_50.to_csv("data/scaffold_decomposition/frequency_bins_50.csv", index=False)
table_10.to_csv("data/scaffold_decomposition/frequency_bins_10.csv", index=False)
table_exact_1_10.to_csv("data/scaffold_decomposition/frequency_exact_1_10.csv", index=False)

print(table_50['Scaffold_Count'].sum())
print(table_10['Scaffold_Count'].sum())
print(table_exact_1_10['Scaffold_Count'].sum())