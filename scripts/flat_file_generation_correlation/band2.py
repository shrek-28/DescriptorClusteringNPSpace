import pandas as pd 
import numpy as np 

df = pd.read_csv("DATA/final_complete_descriptor_matrix.csv")
df = df.drop(['ConformerCount', 'Unnamed: 0', 'Aromatic_ring_count'], axis=1)
df.set_index('identifier', inplace=True)

numeric_cols = df.select_dtypes(include=np.number).columns
sorted_numeric_cols = sorted(numeric_cols)
print(sorted_numeric_cols)

corr = df.corr(method='spearman').abs()

corr_long = corr.unstack().reset_index()
corr_long.columns = ['feature1', 'feature2', 'corr']

corr_long = corr_long[corr_long['feature1'] < corr_long['feature2']]

corr_long = corr_long[(corr_long['corr'] >= 0.35) & (corr_long['corr'] < 0.85)]

corr_long = corr_long.sort_values(by='corr', ascending=False).reset_index(drop=True)

corr_long.to_csv("DATA/flat_files/correlation_flat_band2_0.35_0.85.csv")
print(corr_long)
print(corr_long.shape)