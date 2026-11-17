
import argparse
import os
import pandas as pd
from rdkit import Chem


def main():
    parser = argparse.ArgumentParser(
        description="Generate SMILES from a folder of SDF files."
    )

    parser.add_argument("--input", required=True, help="Folder containing SDF files")
    parser.add_argument("--output", required=True, help="Output CSV path")

    args = parser.parse_args()

    results = []
    sdf_files = [
        f for f in os.listdir(args.input)
        if f.lower().endswith(".sdf")
    ]

    print(f"Total SDF files found: {len(sdf_files)}")

    valid = 0
    invalid = 0

    for idx, filename in enumerate(sdf_files, 1):
        filepath = os.path.join(args.input, filename)
        print(f"[{idx}/{len(sdf_files)}] Processing {filename}")

        supplier = Chem.SDMolSupplier(
            filepath,
            removeHs=True,
            sanitize=True
        )

        for mol in supplier:
            if mol is None:
                invalid += 1
                continue

            smiles = Chem.MolToSmiles(
                mol,
                canonical=True,
                isomericSmiles=True
            )

            identifier = (
                mol.GetProp("_Name")
                if mol.HasProp("_Name")
                else os.path.splitext(filename)[0]
            )

            results.append({
                "identifier": identifier,
                "SMILES": smiles
            })

            valid += 1

    pd.DataFrame(results).to_csv(args.output, index=False)

    print(f"\nValid molecules: {valid}")
    print(f"Invalid molecules: {invalid}")
    print(f"Results saved to: {args.output}")


if __name__ == "__main__":
    main()
