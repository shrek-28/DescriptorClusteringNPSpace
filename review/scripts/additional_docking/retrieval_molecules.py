import argparse
import shutil
import pandas as pd
from pathlib import Path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", required=True, help="Input CSV file")
    parser.add_argument("-s", "--source", required=True, help="Source directory containing SDF files")
    parser.add_argument("-o", "--output", required=True, help="Output directory")
    args = parser.parse_args()

    source_dir = Path(args.source)
    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)

    identifiers = pd.read_csv(args.input)["identifier"].astype(str).str.strip()

    copied = 0
    missing = []

    for identifier in identifiers:
        sdf_file = source_dir / f"minimized_{identifier}.sdf"

        if sdf_file.is_file():
            shutil.copy2(sdf_file, output_dir / sdf_file.name)
            copied += 1
        else:
            missing.append(identifier)

    print(f"Copied: {copied}")
    print(f"Missing: {len(missing)}")

    if missing:
        print("Missing identifiers:", missing)


if __name__ == "__main__":
    main()

# to run: 
# python3 review/scripts/additional_docking/retrieval_molecules.py --input review/data/additional_docking/random_molecules_for_docking.csv --source /Users/shreyasree/Downloads/minimized_outputr/minimized_output --output review/data/additional_docking/random_molecules 
# python3 review/scripts/additional_docking/retrieval_molecules.py --input review/data/additional_docking/representative_molecules_for_docking.csv --source /Users/shreyasree/Downloads/minimized_outputr/minimized_output --output review/data/additional_docking/representative_molecules 