cd /Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/review
python3 scripts/ANPDB_validation/2d_file_split.py --input data/ANPDB_validation/ANPDB_molecules.sdf --output data/ANPDB_validation/split_sdf_files

chmod +x scripts/ANPDB_validation/2d_to_3d_converter.sh
./scripts/ANPDB_validation/2d_to_3d_converter.sh data/ANPDB_validation/split_sdf_files data/ANPDB_validation/3d_converted_files

# energy minimization
python3 scripts/ANPDB_validation/energy_minimization.py --input data/ANPDB_validation/3d_converted_files --output data/ANPDB_validation/minimized_files --ff UFF

# descriptor generation
python3 scripts/ANPDB_validation/descriptor_generation.py --input data/ANPDB_validation/minimized_files --output data/ANPDB_validation/descriptor_data.csv

# umap-hdbscan grid search
python3 scripts/ANPDB_validation/umap_hdbscan_trials.py --input data/ANPDB_validation/descriptor_data.csv --output data/ANPDB_validation/umap_model/grid_search_results.csv

# umap model
mkdir data/ANPDB_validation/umap_model
python3 scripts/ANPDB_validation/umap_code.py --input data/ANPDB_validation/descriptor_data.csv --output data/ANPDB_validation/umap_model/umap_model

# hdbscan model
mkdir data/ANPDB_validation/hdbscan_model
python3 scripts/ANPDB_validation/hdbscan_script.py --input data/ANPDB_validation/descriptor_data.csv --umap data/ANPDB_validation/umap_model/umap_model.npy --output data/ANPDB_validation/hdbscan_model

# selection of random clusters and random and representative molecules for docking
mkdir data/ANPDB_validation/hdbscan_model/stratified_data 
python3 scripts/ANPDB_validation/hdbscan_stratification.py --cluster-sizes data/ANPDB_validation/hdbscan_model/cluster_sizes.csv --cluster-molecules data/ANPDB_validation/hdbscan_model/cluster_molecules_post.csv --representatives data/ANPDB_validation/hdbscan_model/cluster_representatives_7_per_cluster.csv --output data/ANPDB_validation/hdbscan_model/stratified_data

#molecule retrieval for docking
mkdir data/ANPDB_validation/docking_input
python3 scripts/ANPDB_validation/retrieval_for_docking.py --input data/ANPDB_validation/hdbscan_model/stratified_data/ALL_molecules_for_docking.txt --source data/ANPDB_validation/minimized_files --output data/ANPDB_validation/docking_input

# converting to PDBQT files for docking
mkdir data/ANPDB_validation/docking_input_pdbqt
for file in data/ANPDB_validation/docking_input/*.sdf; do
    mk_prepare_ligand.py -i "$file" -o "data/ANPDB_validation/docking_input_pdbqt/$(basename "${file%.sdf}").pdbqt"
done

mkdir data/ANPDB_validation/docking_COX2
mkdir data/ANPDB_validation/docking_EGFR
mkdir data/ANPDB_validation/docking_FFAR3

time python scripts/additional_docking/mol_docking.py \
    --protein data/additional_docking/COX2_docking/COX2_cleaned_protein_prepared.pdbqt \
    --config data/additional_docking/COX2_docking/COX2_gridbox.txt \
    --ligands data/ANPDB_validation/docking_input_pdbqt \
    --output data/ANPDB_validation/docking_COX2/docking_results \
    --exhaustiveness 16

time python scripts/additional_docking/mol_docking.py \
    --protein data/additional_docking/EGFR_docking/EGFR_cleaned_protein_prepared.pdbqt \
    --config data/additional_docking/EGFR_docking/EGFR_gridbox.txt \
    --ligands data/ANPDB_validation/docking_input_pdbqt \
    --output data/ANPDB_validation/docking_EGFR/docking_results \
    --exhaustiveness 16

time python scripts/additional_docking/mol_docking.py \
    --protein data/additional_docking/FFAR3_docking/FFAR3_cleaned_protein_prepared.pdbqt \
    --config data/additional_docking/FFAR3_docking/FFAR3_gridbox.txt \
    --ligands data/ANPDB_validation/docking_input_pdbqt \
    --output data/ANPDB_validation/docking_FFAR3/docking_results \
    --exhaustiveness 16 

cd Documents/GitHub/DescriptorClusteringNPSpace/review
time python scripts/additional_docking/mol_docking.py \
    --protein data/ANPDB_validation/docking_KEAP1/8XGK_clean.pdbqt \
    --config data/ANPDB_validation/docking_KEAP1/KEAP1_gridbox.txt \
    --ligands data/ANPDB_validation/docking_input_pdbqt \
    --output data/ANPDB_validation/docking_KEAP1/docking_results \
    --exhaustiveness 16

# all analyses - cluster characterization

cd Documents/GitHub/DescriptorClusteringNPSpace/review
mkdir data/ANPDB_validation/cluster_analysis_results

# core fraction noise
python scripts/ANPDB_validation/cluster_analysis/core_frac_noise.py --prob data/ANPDB_validation/hdbscan_model/hdbscan_core_assignments.csv --umap data/ANPDB_validation/hdbscan_model/umap_with_clusters.csv --output data/ANPDB_validation/cluster_analysis_results/core_frac_classification.csv
# compactness and geometry 
python scripts/ANPDB_validation/cluster_analysis/compactness_and_geometry.py --umap data/ANPDB_validation/hdbscan_model/umap_with_clusters.csv --centroids data/ANPDB_validation/hdbscan_model/cluster_centroids.csv --medoids data/ANPDB_validation/hdbscan_model/cluster_medoids.csv --core-mols data/ANPDB_validation/hdbscan_model/cluster_molecules_core.csv --post-mols data/ANPDB_validation/hdbscan_model/cluster_molecules_post.csv --output data/ANPDB_validation/cluster_analysis_results/cluster_structural_metrics_12D_full.csv
# mean and variance probability 
python scripts/ANPDB_validation/cluster_analysis/mean_variance_prob.py --input data/ANPDB_validation/hdbscan_model/hdbscan_core_assignments.csv --output data/ANPDB_validation/cluster_analysis_results/cluster_probability_stats.csv 
# id + SMILES CSV file generation 
python scripts/ANPDB_validation/cluster_analysis/sdf_to_smiles.py --input data/ANPDB_validation/split_sdf_files --output data/ANPDB_validation/cluster_analysis_results/ANPDB_smiles.csv
# id + SMILES + DESCRIPTORS 
python scripts/ANPDB_validation/cluster_analysis/descriptor_calculation.py --input data/ANPDB_validation/split_sdf_files --output data/ANPDB_validation/cluster_analysis_results/ANPDB_smiles_with_descriptors.csv
# diversity analytics 
python scripts/ANPDB_validation/cluster_analysis/diversity_analytics.py --clusters data/ANPDB_validation/hdbscan_model/cluster_molecules_post.csv --medoids data/ANPDB_validation/hdbscan_model/cluster_medoids.csv --smiles data/ANPDB_validation/cluster_analysis_results/ANPDB_smiles.csv --output data/ANPDB_validation/cluster_analysis_results/cluster_similarity_validation.csv 
# chemical characterization 
python scripts/ANPDB_validation/cluster_analysis/chemical_profiling.py --descriptors data/ANPDB_validation/cluster_analysis_results/ANPDB_smiles_with_descriptors.csv --clusters data/ANPDB_validation/hdbscan_model/cluster_molecules_post.csv --representatives data/ANPDB_validation/hdbscan_model/cluster_representatives_7_per_cluster.csv --output data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv