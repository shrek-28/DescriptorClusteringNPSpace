import numpy as np 
import pandas as pd

df = pd.read_csv("data/final_complete_descriptor_matrix.csv")
df = df.drop('Unnamed: 0', axis=1)
df.set_index('identifier', inplace=True)

RANDOM_STATE = 42
df_60 = df.sample(frac=0.6, random_state=RANDOM_STATE)
df_40 = df.drop(index=df_60.index)

df_60 = df_60.reset_index(drop=True)
df_40 = df_40.reset_index(drop=True)

df_60.to_csv("data/perturbation_data/rs_42/60_df.csv")
df_40.to_csv("data/perturbation_data/rs_42/40_df.csv")