import pandas as pd

# Read complete correlation matrix
corr_matrix = pd.read_csv("data/complete_correlation_matrix/correlation_matrix_spearman.csv", index_col=0)

pairwise_df = (corr_matrix.stack().reset_index())

pairwise_df.columns = [
    "Descriptor_1",
    "Descriptor_2",
    "Correlation"
]

pairwise_df = pairwise_df[
    pairwise_df["Descriptor_1"] != pairwise_df["Descriptor_2"]
]

pairwise_df["Pair"] = pairwise_df.apply(
    lambda x: tuple(sorted([x["Descriptor_1"],
                            x["Descriptor_2"]])),
    axis=1
)

pairwise_df = (
    pairwise_df
    .drop_duplicates(subset="Pair")
    .drop(columns="Pair")
)

pairwise_df = pairwise_df.reindex(
    pairwise_df["Correlation"]
    .abs()
    .sort_values(ascending=False)
    .index
)

pairwise_df.to_csv(
    "data/complete_correlation_matrix/pairwise_correlations.csv",
    index=False
)

print(pairwise_df.head())