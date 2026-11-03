
import argparse
import subprocess
import csv
import re
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("--protein", required=True)
parser.add_argument("--config", required=True)
parser.add_argument("--ligands", required=True)
parser.add_argument("--output", required=True)
parser.add_argument("--exhaustiveness", type=int, default=16)
parser.add_argument("--num_modes", type=int, default=9)
parser.add_argument("--vina", default="vina")
parser.add_argument("--max_rotatable_bonds", type=int, default=50)
parser.add_argument("--timeout", type=int, default=600)
args = parser.parse_args()

protein = Path(args.protein)
config = Path(args.config)
ligand_dir = Path(args.ligands)
output = Path(args.output)

logs_dir = output / "logs"
docked_dir = output / "docked"

logs_dir.mkdir(parents=True, exist_ok=True)
docked_dir.mkdir(parents=True, exist_ok=True)

scores_file = output / "docking_scores.csv"

# Load all previously recorded molecules, regardless of status.
processed = set()

if scores_file.exists() and scores_file.stat().st_size > 0:
    with open(scores_file, "r", newline="") as f:
        for row in csv.DictReader(f):
            if row.get("molecule"):
                processed.add(row["molecule"])

ligands = sorted(ligand_dir.glob("*.pdbqt"))
pending = [ligand for ligand in ligands if ligand.stem not in processed]

total = len(ligands)
failed = []

print(f"Total ligands: {total}")
print(f"Already in CSV: {total - len(pending)}")
print(f"New molecules to process: {len(pending)}")

write_header = not scores_file.exists() or scores_file.stat().st_size == 0

with open(scores_file, "a", newline="") as csvfile:
    writer = csv.DictWriter(
        csvfile,
        fieldnames=[
            "molecule",
            "rotatable_bonds",
            "best_score_kcal_mol",
            "status"
        ]
    )

    if write_header:
        writer.writeheader()
        csvfile.flush()

    for i, ligand in enumerate(pending, start=1):
        name = ligand.stem
        log_file = logs_dir / f"{name}.log"
        docked_file = docked_dir / f"{name}_docked.pdbqt"

        print(f"\n[{i}/{len(pending)}] Processing: {name}", flush=True)

        # Count rotatable bonds from the PDBQT torsion tree.
        try:
            with open(ligand, "r") as f:
                rotatable_bonds = sum(
                    1 for line in f
                    if line.strip().startswith("BRANCH ")
                )
        except OSError as e:
            status = "ligand_read_error"
            failed.append(name)

            print(f"FAILED: Cannot read ligand: {e}")

            writer.writerow({
                "molecule": name,
                "rotatable_bonds": "",
                "best_score_kcal_mol": "",
                "status": status
            })
            csvfile.flush()
            continue

        print(f"Rotatable bonds: {rotatable_bonds}")

        if rotatable_bonds > args.max_rotatable_bonds:
            status = "skipped_too_many_rotatable_bonds"
            failed.append(name)

            print(
                f"SKIPPED: {rotatable_bonds} rotatable bonds "
                f"(limit: {args.max_rotatable_bonds})"
            )

            writer.writerow({
                "molecule": name,
                "rotatable_bonds": rotatable_bonds,
                "best_score_kcal_mol": "",
                "status": status
            })
            csvfile.flush()
            continue

        command = [
            args.vina,
            "--receptor", str(protein),
            "--ligand", str(ligand),
            "--config", str(config),
            "--exhaustiveness", str(args.exhaustiveness),
            "--num_modes", str(args.num_modes),
            "--out", str(docked_file)
        ]

        print(
            f"Docking: {name} "
            f"(timeout: {args.timeout // 60} minutes)",
            flush=True
        )

        best_score = None

        try:
            process = subprocess.Popen(
                command,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True
            )

            try:
                log_text, _ = process.communicate(
                    timeout=args.timeout
                )

            except subprocess.TimeoutExpired:
                process.kill()
                log_text, _ = process.communicate()

                log_file.write_text(
                    (log_text or "")
                    + f"\nTIMEOUT: Docking exceeded "
                    f"{args.timeout} seconds.\n"
                )

                if docked_file.exists():
                    docked_file.unlink()

                status = "timed_out"
                failed.append(name)

                print(
                    f"TIMEOUT: {name} exceeded "
                    f"{args.timeout} seconds. Moving on.",
                    flush=True
                )

                writer.writerow({
                    "molecule": name,
                    "rotatable_bonds": rotatable_bonds,
                    "best_score_kcal_mol": "",
                    "status": status
                })
                csvfile.flush()
                continue

            log_file.write_text(log_text)

            # Print the completed docking log.
            print(log_text, end="", flush=True)

            if process.returncode == 0:
                match = re.search(
                    r"^\s*\*?1\s+(-?\d+(?:\.\d+)?)",
                    log_text,
                    re.MULTILINE
                )

                if match:
                    best_score = float(match.group(1))
                    status = "success"
                    print(f"Best score: {best_score} kcal/mol")
                else:
                    status = "score_not_found"
                    failed.append(name)
                    print(f"WARNING: Score not found. Check {log_file}")

            else:
                status = "failed"
                failed.append(name)
                print(f"FAILED: {name}. Check {log_file}")

        except OSError as e:
            status = "execution_error"
            failed.append(name)

            log_file.write_text(str(e) + "\n")
            print(f"FAILED to execute Vina: {e}")

        writer.writerow({
            "molecule": name,
            "rotatable_bonds": rotatable_bonds,
            "best_score_kcal_mol": best_score,
            "status": status
        })
        csvfile.flush()

        print(
            f"Progress: {i}/{len(pending)} new molecules processed "
            f"({i / len(pending) * 100:.1f}%)",
            flush=True
        )

print("\nDocking run completed.")
print(f"Total ligands: {total}")
print(f"Previously recorded in CSV: {total - len(pending)}")
print(f"New molecules attempted: {len(pending)}")
print(f"Failed/skipped/timed out this run: {len(failed)}")
print(f"Scores CSV: {scores_file}")
print(f"Log files: {logs_dir}")
print(f"Docked structures: {docked_dir}")

if failed:
    failed_file = output / "failed_ligands.txt"
    failed_file.write_text("\n".join(failed) + "\n")
    print(f"Failed/skipped ligand list: {failed_file}")
