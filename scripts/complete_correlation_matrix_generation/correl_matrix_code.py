import pandas as pd 
import matplotlib.pyplot as plt 
import seaborn as sns

df = pd.read_csv("DATA/final_complete_descriptor_matrix.csv")

df = df.drop(['ConformerCount', 'Unnamed: 0'], axis=1)
df.set_index('identifier', inplace=True)

corr = df.corr(method='spearman')

corr.to_csv("data/complete_correlation_matrix/correlation_matrix_spearman.csv")

# plt.figure(figsize=(120, 100))
# sns.heatmap(
#     corr,
#     annot=True, fmt=".2f",
#     cmap='coolwarm', vmin=-1, vmax=1,
#     linewidths=0.5,
#     cbar_kws={'label': 'Spearman Correlation'}
# )
# plt.xticks(rotation=45, ha='right', fontsize=12)
# plt.yticks(fontsize=12)
# plt.tight_layout()

# plt.savefig("Step_2_Feature_Generation/Correlation_Matrix_Code/plots/correl_matrix_full.png", dpi=300)
