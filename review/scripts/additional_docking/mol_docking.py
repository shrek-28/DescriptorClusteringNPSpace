
import argparse
import subprocess
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("--protein", required=True)
parser.add_argument("--config", required=True)
parser.add_argument("--ligands", required=True)
parser.add_argument("--output", required=True)
parser.add_argument("--exhaustiveness", type=int, default=16)
parser.add_argument("--num_modes", type=int, default=9)
parser.add_argument("--vina", default="vina")
args = parser.parse_args()

protein = Path(args.protein)
config = Path(args.config)
ligand_dir = Path(args.ligands)
output = Path(args.output)

output.mkdir(parents=True, exist_ok=True)

ligands = sorted(ligand_dir.glob("*.pdbqt"))
failed = []

for ligand in ligands:
    name = ligand.stem

    command = [
        args.vina,
        "--receptor", str(protein),
        "--ligand", str(ligand),
        "--config", str(config),
        "--exhaustiveness", str(args.exhaustiveness),
        "--num_modes", str(args.num_modes),
        "--out", str(output / f"{name}_docked.pdbqt")
    ]

    log_file = output / f"{name}.log"

    print(f"\nDocking: {name}")

    with open(log_file, "w") as log:
        result = subprocess.run(
            command,
            stdout=log,
            stderr=subprocess.STDOUT,
            text=True
        )

    if result.returncode != 0:
        print(f"FAILED: {name}")
        failed.append(name)

        with open(log_file) as log:
            print(log.read())

    else:
        print(f"Completed: {name}")

print("\nDocking completed.")
print(f"Total ligands: {len(ligands)}")
print(f"Successful: {len(ligands) - len(failed)}")
print(f"Failed: {len(failed)}")

if failed:
    failed_file = output / "failed_ligands.txt"
    failed_file.write_text("\n".join(failed) + "\n")
    print(f"Failed ligand list: {failed_file}")
