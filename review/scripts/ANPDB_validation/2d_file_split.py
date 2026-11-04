
import argparse
from pathlib import Path


parser = argparse.ArgumentParser(
    description="Split a multi-molecule SDF into individual files."
)

parser.add_argument("--input", required=True)
parser.add_argument("--output", required=True)

args = parser.parse_args()

input_file = Path(args.input)
output_dir = Path(args.output)

output_dir.mkdir(parents=True, exist_ok=True)

total = 0
seen = set()
record = []


def save_record(lines):
    global total

    if not lines:
        return

    mol_id = None

    for i, line in enumerate(lines):
        if "<MoleculeID>" in line:
            for value in lines[i + 1:]:
                value = value.strip()
                if value:
                    mol_id = value
                    break
            break

    if not mol_id:
        raise ValueError(
            f"Missing MoleculeID in record {total + 1}"
        )

    if not all(c.isalnum() or c in "_.-" for c in mol_id):
        raise ValueError(f"Invalid MoleculeID: {mol_id}")

    if mol_id in seen:
        raise ValueError(f"Duplicate MoleculeID: {mol_id}")

    seen.add(mol_id)

    output_file = output_dir / f"{mol_id}.sdf"

    with open(output_file, "w") as f:
        f.writelines(lines)
        f.write("$$$$\n")

    total += 1

    if total % 1000 == 0:
        print(f"Processed: {total}")


with open(input_file, "r") as f:

    for line in f:

        if line.strip() == "$$$$":
            save_record(record)
            record = []

        else:
            record.append(line)

# Handle final record if delimiter is missing
if record:
    save_record(record)


print("\n================================")
print("SDF splitting completed")
print(f"Total molecules: {total}")
print(f"Output directory: {output_dir}")
print("================================")
