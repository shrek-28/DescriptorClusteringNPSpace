import pandas as pd 
from collections import defaultdict
import matplotlib.pyplot as plt 
import seaborn as sns

df = pd.read_csv("DATA/flat_files/correlation_flat_band1_0.5_0.85.csv")
corrmat = df.drop('Unnamed: 0', axis=1)

grouped_feature_ls = []
correlated_groups = []

for feature in corrmat.feature1.unique():
    if feature not in grouped_feature_ls:
        correlated_block = corrmat[corrmat.feature1 == feature]
        grouped_feature_ls += list(correlated_block.feature2.unique()) + [feature]
        correlated_groups.append(correlated_block)

print('found {} correlated groups'.format(len(correlated_groups)))

df = pd.concat([correlated_groups[i] for i in range(0, len(correlated_groups))], axis=0)

## GREEDY MAXIMUM COVERAGE 
def method1_greedy_max_coverage(df, target_count=23, corr_threshold=0.75):
    """
    Greedy algorithm: Iteratively select features that maximize coverage
    while avoiding redundancy
    """
    # Get all unique features
    all_features = set(df['feature1'].unique()) | set(df['feature2'].unique())
    
    # Build correlation dictionary
    correlations = defaultdict(list)
    for _, row in df.iterrows():
        correlations[row['feature1']].append((row['feature2'], row['corr']))
        correlations[row['feature2']].append((row['feature1'], row['corr']))
    
    selected = []
    remaining = all_features.copy()
    
    # Count connections for each feature (importance score)
    feature_importance = {f: len(correlations[f]) for f in all_features}
    
    while len(selected) < target_count and remaining:
        best_feature = None
        best_score = -1
        
        for feature in remaining:
            # Score = importance - penalty for correlation with selected
            score = feature_importance[feature]
            
            # Penalty for high correlation with already selected features
            for sel_feature in selected:
                for corr_feature, corr_val in correlations[feature]:
                    if corr_feature == sel_feature and corr_val > corr_threshold:
                        score -= corr_val * 10  # Heavy penalty
            
            if score > best_score:
                best_score = score
                best_feature = feature
        
        if best_feature:
            selected.append(best_feature)
            remaining.remove(best_feature)
    
    return selected

selected1 = method1_greedy_max_coverage(df, target_count=10)
print(f"Selected {len(selected1)} features:")
print(selected1[:10], "...")

final_df = pd.read_csv("DATA/final_complete_descriptor_matrix.csv")

final_df.set_index('identifier', inplace=True)
final_df = final_df[selected1]

min_corr = final_df.corr()

min_corr.to_csv("data/greedy_max_coverage_matrix/10_desc/band1.csv")

# plt.figure(figsize=(24, 12))
# sns.heatmap(
#     min_corr,
#     annot=True, fmt=".2f",
#     cmap='coolwarm', vmin=-1, vmax=1,
#     linewidths=0.5,
#     cbar_kws={'label': 'Spearman Correlation'}
# )
# plt.xticks(rotation=45, ha='right', fontsize=12)
# plt.yticks(fontsize=12)
# plt.tight_layout()

# plt.savefig("PLOTS/greedy-max-cov-correl-plots/10desc/band1_10desc", dpi=300)
# plt.show()