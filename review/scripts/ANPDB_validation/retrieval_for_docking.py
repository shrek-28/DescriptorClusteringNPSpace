
import argparse
import shutil
from pathlib import Path


def main():
    parser = argparse.ArgumentParser()

    parser.add_argument("-i", "--input", required=True, help="Input TXT file containing molecule IDs")
    parser.add_argument("-s", "--source", required=True, help="Source directory containing SDF files")
    parser.add_argument("-o", "--output", required=True, help="Output directory")

    args = parser.parse_args()

    source_dir = Path(args.source)
    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)

    with open(args.input, "r") as file:
        identifiers = list(dict.fromkeys(
            line.strip() for line in file if line.strip()
        ))

    copied = 0
    missing = []

    for identifier in identifiers:
        sdf_file = source_dir / f"{identifier}.sdf"

        if sdf_file.is_file():
            shutil.copy2(sdf_file, output_dir / sdf_file.name)
            copied += 1
        else:
            missing.append(identifier)

    print(f"Total unique identifiers: {len(identifiers)}")
    print(f"Copied: {copied}")
    print(f"Missing: {len(missing)}")

    if missing:
        print("Missing identifiers:")
        for identifier in missing:
            print(identifier)


if __name__ == "__main__":
    main()
