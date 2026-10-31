import numpy as np
import umap
import time 
from sklearn.preprocessing import PowerTransformer
from sklearn.preprocessing import StandardScaler
import pandas as pd

df = pd.read_csv("DATA/20desc_training_matrix.csv")
df = df.drop('Unnamed: 0', axis=1)
df.set_index('identifier', inplace=True)

pt = PowerTransformer(method='yeo-johnson', standardize=True)
X_transformed = pt.fit_transform(df.values)

scaler = StandardScaler()
X_scaled = scaler.fit_transform(X_transformed)
s
umap_model = umap.UMAP(
    n_neighbors=30,     
    min_dist=0.30,      
    n_components=12,    
    metric="euclidean",
    low_memory=True,
    densmap=False,
    n_epochs=150,       
    verbose=True,
    random_state=42
)

X_umap = umap_model.fit_transform(X_scaled)

np.save("MODELS/X_umap_try2.npy", X_umap)