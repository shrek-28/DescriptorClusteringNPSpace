for file in review/data/additional_docking/random_molecules/*.sdf; do
    mk_prepare_ligand.py -i "$file" -o "review/data/additional_docking/random_molecules_pdbqt/$(basename "${file%.sdf}").pdbqt"
done

for file in review/data/additional_docking/representative_molecules/*.sdf; do
    mk_prepare_ligand.py -i "$file" -o "review/data/additional_docking/representative_molecules_pdbqt/$(basename "${file%.sdf}").pdbqt"
done