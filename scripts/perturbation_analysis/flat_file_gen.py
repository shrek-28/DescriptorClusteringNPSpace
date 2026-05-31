import pandas as pd
import numpy as np

def generate_corr_flatfile(df1, df2, output_path1, output_path2):

    drop_cols = ['ConformerCount', 'Unnamed: 0', 'Aromatic_ring_count']

    def process_dataframe(df, output_path):

        df = df.drop(columns=drop_cols, errors='ignore')

        numeric_cols = df.select_dtypes(include=np.number).columns
        sorted_numeric_cols = sorted(numeric_cols)

        corr = df.corr(method='spearman').abs()

        corr_long = corr.unstack().reset_index()
        corr_long.columns = ['feature1', 'feature2', 'corr']

        corr_long = corr_long[
            corr_long['feature1'] < corr_long['feature2']
        ]

        corr_long = corr_long[
            (corr_long['corr'] >= 0.35) &
            (corr_long['corr'] < 0.85)
        ]

        corr_long = corr_long.sort_values(
            by='corr',
            ascending=False
        ).reset_index(drop=True)

        corr_long.to_csv(output_path, index=False)

        print(f"Saved: {output_path}")
        print(f"Shape: {corr_long.shape}")

        return corr_long

    result1 = process_dataframe(df1, output_path1)
    result2 = process_dataframe(df2, output_path2)

    return result1, result2


random_seeds = [0, 1, 101, 42, 123]

for seed in random_seeds:

    df1 = pd.read_csv(f"DATA/perturbation_data/rs_{seed}/40_df.csv")
    df2 = pd.read_csv(f"DATA/perturbation_data/rs_{seed}/60_df.csv")

    generate_corr_flatfile(
        df1,
        df2,
        f"DATA/perturbation_data/rs_{seed}/40_df_flat_file.csv",
        f"DATA/perturbation_data/rs_{seed}/60_df_flat_file.csv"
    )

    print(f"Completed random seed {seed}\n")