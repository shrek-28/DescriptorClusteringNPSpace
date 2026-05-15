### This is hierarchical clustering 
### Code produces: Clusters, Dendrogram
### Feature Selection: done by picking the feature with lowest correlations 

import pandas as pd
import numpy as np
from scipy.cluster.hierarchy import linkage, fcluster, dendrogram, set_link_color_palette
from scipy.spatial.distance import squareform
import matplotlib.pyplot as plt
import seaborn as sns

corr_df = pd.read_csv("DATA/flat_files/correlation_flat_band1_0.5_0.85.csv")

features = sorted(set(corr_df['feature1']).union(set(corr_df['feature2'])))
corr_matrix = pd.DataFrame(np.eye(len(features)), index=features, columns=features)

for _, row in corr_df.iterrows():
    f1, f2, c = row['feature1'], row['feature2'], row['corr']
    corr_matrix.loc[f1, f2] = c
    corr_matrix.loc[f2, f1] = c

distance_matrix = 1 - corr_matrix.abs()
dist_condensed = squareform(distance_matrix.values, checks=False)

Z = linkage(dist_condensed, method='average')

desired_clusters = 10
threshold = None

for t in np.linspace(0.01, 1.0, 1000):  
    clusters = fcluster(Z, t=t, criterion='distance')
    n_clusters = len(np.unique(clusters))
    if n_clusters == desired_clusters:
        threshold = t
        break

if threshold is None:
    diffs = []
    for t in np.linspace(0.01, 1.0, 1000):
        clusters = fcluster(Z, t=t, criterion='distance')
        diffs.append((abs(len(np.unique(clusters)) - desired_clusters), t))
    threshold = min(diffs, key=lambda x: x[0])[1]
    clusters = fcluster(Z, t=threshold, criterion='distance')

feature_clusters = pd.DataFrame({
    'feature': corr_matrix.index,
    'cluster': clusters
}).sort_values('cluster')

print(f"Number of clusters formed: {len(feature_clusters['cluster'].unique())}")
print(f"Distance threshold used: {threshold:.4f}")
print(feature_clusters)

## picking the features 

selected_features = []

for c in feature_clusters['cluster'].unique():
    members = feature_clusters[feature_clusters['cluster'] == c]['feature']
    sub_corr = corr_matrix.loc[members, members]
    
    mean_corr = sub_corr.mean().sort_values(ascending=True)
    top_feature = mean_corr.index[0]
    selected_features.append(top_feature)

selected_features_df = pd.DataFrame({'selected_feature': selected_features})

selected_list_max_fts = selected_features_df['selected_feature'].to_list()

final_df = pd.read_csv("DATA/final_complete_descriptor_matrix.csv")

final_df.set_index('identifier', inplace=True)
final_df = final_df[selected_list_max_fts]

min_corr = final_df.corr()
plt.figure(figsize=(24, 12))
sns.heatmap(
    min_corr,
    annot=True, fmt=".2f",
    cmap='coolwarm', vmin=-1, vmax=1,
    linewidths=0.5,
    cbar_kws={'label': 'Spearman Correlation'}
)
plt.xticks(rotation=45, ha='right', fontsize=12)
plt.yticks(fontsize=12)
plt.tight_layout()

plt.savefig("PLOTS/hierarchical-dendrograms/10desc/band1/min_avg_corr_cmatrix_10_clusters.png")
plt.show()