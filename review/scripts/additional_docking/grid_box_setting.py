import argparse
import numpy as np
from Bio.PDB import PDBParser

parser = argparse.ArgumentParser()
parser.add_argument("--protein", required=True, help="Input protein PDB file")
parser.add_argument("--output", required=True, help="Output Vina config file")
parser.add_argument("--padding", type=float, default=10.0)
args = parser.parse_args()

structure = PDBParser(QUIET=True).get_structure("protein", args.protein)

coords = np.array([
    atom.coord for atom in structure.get_atoms()
    if atom.element not in ["H", "D"]
])

minimum = coords.min(axis=0)
maximum = coords.max(axis=0)

center = (minimum + maximum) / 2
size = maximum - minimum + 2 * args.padding

with open(args.output, "w") as f:
    for axis, value in zip(["x", "y", "z"], center):
        f.write(f"center_{axis} = {value:.3f}\n")
    for axis, value in zip(["x", "y", "z"], size):
        f.write(f"size_{axis} = {value:.3f}\n")

print(f"Configuration saved to {args.output}")

# running:
# python3 scripts/additional_docking/grid_box_setting.py --protein data/additional_docking/COX2_docking/COX2_cleaned_protein.pdb --output data/additional_docking/COX2_docking/COX2_gridbox.txt
# python3 scripts/additional_docking/grid_box_setting.py --protein data/additional_docking/EGFR_docking/EGFR_cleaned_protein.pdb --output data/additional_docking/EGFR_docking/EGFR_gridbox.txt
# python3 scripts/additional_docking/grid_box_setting.py --protein data/additional_docking/FFAR3_docking/FFAR3_cleaned_protein.pdb --output data/additional_docking/FFAR3_docking/FFAR3_gridbox.txt