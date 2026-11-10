
import os
import argparse
import numpy as np
import pandas as pd
import umap

from sklearn.preprocessing import PowerTransformer, StandardScaler
from joblib import dump


def main():
    parser = argparse.ArgumentParser(
        description="CPU-based UMAP dimensionality reduction"
    )

    parser.add_argument(
        "--input",
        default="DATA/20desc_training_matrix.csv"
    )
    parser.add_argument(
        "--output",
        default="DATA/20desc_umap.npy"
    )
    parser.add_argument(
        "--threads",
        type=int,
        default=-1,
        help="Number of CPU threads (-1 uses all available threads)"
    )

    args = parser.parse_args()

    os.makedirs(os.path.dirname(args.output) or ".", exist_ok=True)

    print("Loading descriptor matrix...")
    df = pd.read_csv(args.input)

    # df = df.drop(columns=["Unnamed: 0"], errors="ignore")
    df.set_index("identifier", inplace=True)

    identifiers = df.index.to_numpy()

    print(f"Loaded {len(df)} molecules with {df.shape[1]} descriptors.")

    print("Applying Yeo-Johnson transformation...")
    pt = PowerTransformer(
        method="yeo-johnson",
        standardize=True
    )

    X_transformed = pt.fit_transform(df.values)

    print("Applying standard scaling...")
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X_transformed)

    print("Running CPU-based UMAP...")

    umap_model = umap.UMAP(
        n_neighbors=15,
        min_dist=0.10,
        n_components=12,
        metric="euclidean",
        low_memory=True,
        densmap=False,
        n_epochs=150,
        n_jobs=args.threads,
        verbose=True,
        random_state=42
    )

    X_umap = umap_model.fit_transform(X_scaled)

    print("Saving UMAP coordinates...")
    np.save(args.output, X_umap)

    identifier_output = os.path.splitext(args.output)[0] + "_identifiers.csv"
    pd.DataFrame({
        "identifier": identifiers
    }).to_csv(identifier_output, index=False)

    model_output = os.path.splitext(args.output)[0] + "_model.joblib"
    dump(umap_model, model_output)

    print("\nUMAP completed successfully.")
    print(f"Input shape: {X_scaled.shape}")
    print(f"Output shape: {X_umap.shape}")
    print(f"Coordinates: {args.output}")
    print(f"Identifiers: {identifier_output}")
    print(f"UMAP model: {model_output}")


if __name__ == "__main__":
    main()
