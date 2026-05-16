import pandas as pd 
import matplotlib.pyplot as plt 
import seaborn as sns

df = pd.read_csv("DATA/final_complete_descriptor_matrix.csv")

df = df.drop(['ConformerCount', 'Unnamed: 0', 'Aromatic_ring_count'], axis=1)
df.set_index('identifier', inplace=True)

print(df.shape)
corr = df.corr(method='spearman')

corr.to_csv("data/complete_correlation_matrix/correlation_matrix_spearman.csv")