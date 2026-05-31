import os
import pandas as pd

def generate_perturbation_splits(
    input_file,
    output_dir="data/perturbation_data",
    random_seeds=(0, 1, 101, 42, 123),
    sample_fraction=0.6
):
    df = pd.read_csv(input_file)

    if 'Unnamed: 0' in df.columns:
        df = df.drop(columns=['Unnamed: 0'])

    df.set_index('identifier', inplace=True)

    for seed in random_seeds:
        df_60 = df.sample(frac=sample_fraction, random_state=seed)
        df_40 = df.drop(index=df_60.index)

        df_60 = df_60.reset_index(drop=True)
        df_40 = df_40.reset_index(drop=True)

        save_dir = os.path.join(output_dir, f"rs_{seed}")
        os.makedirs(save_dir, exist_ok=True)

        df_60.to_csv(os.path.join(save_dir, "60_df.csv"), index=False)
        df_40.to_csv(os.path.join(save_dir, "40_df.csv"), index=False)

        print(f"Completed split for random seed {seed}")


# Usage
generate_perturbation_splits(
    input_file="data/final_complete_descriptor_matrix.csv",
    random_seeds=[0, 1, 101, 42, 123]
)