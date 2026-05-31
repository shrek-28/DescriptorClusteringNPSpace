import numpy as np 
import pandas as pd
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler

df = pd.read_csv("data/final_complete_descriptor_matrix.csv")
df = df.drop('Unnamed: 0', axis=1)
df.set_index('identifier', inplace=True)

scaler = StandardScaler()

X_all_scaled = scaler.fit_transform(df)

# Optional: keep as DataFrame
X_all_scaled_df = pd.DataFrame(
    X_all_scaled,
    columns=df.columns,
    index=df.index
)

pca_all = PCA()
X_all_pca = pca_all.fit_transform(X_all_scaled)

explained_variance_all = pca_all.explained_variance_ratio_
cumulative_variance_all = np.cumsum(explained_variance_all)

pca_all_table = pd.DataFrame({
    "PC": np.arange(1, len(explained_variance_all) + 1),
    "explained_variance": explained_variance_all,
    "cumulative_variance": cumulative_variance_all
})

pca_all_table.to_csv("data/pca_data/pca_all_80_descriptors.csv", index=False)
