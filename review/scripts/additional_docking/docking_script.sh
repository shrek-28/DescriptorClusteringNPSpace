for file in review/data/additional_docking/random_molecules/*.sdf; do
    mk_prepare_ligand.py -i "$file" -o "review/data/additional_docking/random_molecules_pdbqt/$(basename "${file%.sdf}").pdbqt"
done

for file in review/data/additional_docking/representative_molecules/*.sdf; do
    mk_prepare_ligand.py -i "$file" -o "review/data/additional_docking/representative_molecules_pdbqt/$(basename "${file%.sdf}").pdbqt"
done

# run gridbox setting according to files here

obabel data/additional_docking/COX2_docking/COX2_cleaned_protein.pdb \
    -O data/additional_docking/COX2_docking/COX2_cleaned_protein_prepared.pdbqt -xr
obabel data/additional_docking/EGFR_docking/EGFR_cleaned_protein.pdb \
    -O data/additional_docking/EGFR_docking/EGFR_cleaned_protein_prepared.pdbqt -xr
obabel data/additional_docking/FFAR3_docking/FFAR3_cleaned_protein.pdb \
    -O data/additional_docking/FFAR3_docking/FFAR3_cleaned_protein_prepared.pdbqt -xr

time python scripts/additional_docking/mol_docking.py \
    --protein data/additional_docking/COX2_docking/COX2_cleaned_protein_prepared.pdbqt \
    --config data/additional_docking/COX2_docking/COX2_gridbox.txt \
    --ligands data/additional_docking/random_molecules_pdbqt \
    --output data/additional_docking/COX2_docking/random_docking_results \
    --exhaustiveness 16

time python scripts/additional_docking/mol_docking.py \
    --protein data/additional_docking/EGFR_docking/EGFR_cleaned_protein_prepared.pdbqt \
    --config data/additional_docking/EGFR_docking/EGFR_gridbox.txt \
    --ligands data/additional_docking/random_molecules_pdbqt \
    --output data/additional_docking/EGFR_docking/random_docking_results \
    --exhaustiveness 16

time python scripts/additional_docking/mol_docking.py \
    --protein data/additional_docking/FFAR3_docking/FFAR3_cleaned_protein_prepared.pdbqt \
    --config data/additional_docking/FFAR3_docking/FFAR3_gridbox.txt \
    --ligands data/additional_docking/random_molecules_pdbqt \
    --output data/additional_docking/FFAR3_docking/random_docking_results \
    --exhaustiveness 16

time python scripts/additional_docking/mol_docking.py \
    --protein data/additional_docking/COX2_docking/COX2_cleaned_protein_prepared.pdbqt \
    --config data/additional_docking/COX2_docking/COX2_gridbox.txt \
    --ligands data/additional_docking/representative_molecules_pdbqt \
    --output data/additional_docking/COX2_docking/representative_docking_results \
    --exhaustiveness 16

time python scripts/additional_docking/mol_docking.py \
    --protein data/additional_docking/EGFR_docking/EGFR_cleaned_protein_prepared.pdbqt \
    --config data/additional_docking/EGFR_docking/EGFR_gridbox.txt \
    --ligands data/additional_docking/representative_molecules_pdbqt \
    --output data/additional_docking/EGFR_docking/representative_docking_results \
    --exhaustiveness 16

time python scripts/additional_docking/mol_docking.py \
    --protein data/additional_docking/FFAR3_docking/FFAR3_cleaned_protein_prepared.pdbqt \
    --config data/additional_docking/FFAR3_docking/FFAR3_gridbox.txt \
    --ligands data/additional_docking/representative_molecules_pdbqt \
    --output data/additional_docking/FFAR3_docking/representative_docking_results \
    --exhaustiveness 16