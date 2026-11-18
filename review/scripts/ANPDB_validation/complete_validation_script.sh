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

mkdir data/ANPDB_validation/cluster_analysis_results/cluster_rep_analysis 
# representative difference analysis 
python scripts/ANPDB_validation/cluster_analysis/rep_difference_analysis.py --input data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --stats-output data/ANPDB_validation/cluster_analysis_results/cluster_rep_analysis/representative_analysis.csv --difference-output data/ANPDB_validation/cluster_analysis_results/cluster_rep_analysis/representative_difference_analysis.csv
# bivariate representative analysis 
python scripts/ANPDB_validation/cluster_analysis/bivariate_rep_analysis.py --input data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --output data/ANPDB_validation/cluster_analysis_results/cluster_rep_analysis/descriptor_regression_statistics.csv
# bland-altman analysis 
python scripts/ANPDB_validation/cluster_analysis/bland_altman_analysis.py --input data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --output data/ANPDB_validation/cluster_analysis_results/cluster_rep_analysis/bland_altman_statistics.csv

# visualizations - histograms
mkdir plots/ANPDB_validation/dsf
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --column dominant_scaffold_fraction --output plots/ANPDB_validation/dsf/dominant_scaffold_fraction_histogram.png

mkdir plots/ANPDB_validation/desc_means
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --column MolWt_mean --output plots/ANPDB_validation/desc_means/MolWt_mean_histogram.png
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --column LogP_mean --output plots/ANPDB_validation/desc_means/LogP_mean_histogram.png
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --column AromaticRingCount_mean --output plots/ANPDB_validation/desc_means/AromaticRingCount_mean_histogram.png --binwidth 1
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --column FractionCSP3_mean --output plots/ANPDB_validation/desc_means/FractionCSP3_mean_histogram.png
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --column TPSA_mean --output plots/ANPDB_validation/desc_means/TPSA_mean_histogram.png
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --column HBA_mean --output plots/ANPDB_validation/desc_means/HBA_mean_histogram.png --binwidth 1
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --column HBD_mean --output plots/ANPDB_validation/desc_means/HBD_mean_histogram.png --binwidth 1
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --column RotatableBonds_mean --output plots/ANPDB_validation/desc_means/RotatableBonds_mean_histogram.png --binwidth 1

mkdir plots/ANPDB_validation/desc_medians 
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --column MolWt_median --output plots/ANPDB_validation/desc_medians/MolWt_median_histogram.png
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --column LogP_median --output plots/ANPDB_validation/desc_medians/LogP_median_histogram.png
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --column AromaticRingCount_median --output plots/ANPDB_validation/desc_medians/AromaticRingCount_median_histogram.png --binwidth 1
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --column FractionCSP3_median --output plots/ANPDB_validation/desc_medians/FractionCSP3_median_histogram.png
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --column TPSA_median --output plots/ANPDB_validation/desc_medians/TPSA_median_histogram.png
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --column HBA_median --output plots/ANPDB_validation/desc_medians/HBA_median_histogram.png --binwidth 1
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --column HBD_median --output plots/ANPDB_validation/desc_medians/HBD_median_histogram.png --binwidth 1
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --column RotatableBonds_median --output plots/ANPDB_validation/desc_medians/RotatableBonds_median_histogram.png --binwidth 1

mkdir plots/ANPDB_validation/cluster_physical_chars
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/core_frac_classification.csv --column core_fraction --output plots/ANPDB_validation/cluster_physical_chars/core_fraction_histogram.png
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/core_frac_classification.csv --column core_size --output plots/ANPDB_validation/cluster_physical_chars/core_size_histogram.png
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/core_frac_classification.csv --column post_noise_size --output plots/ANPDB_validation/cluster_physical_chars/post_noise_size_histogram.png
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/core_frac_classification.csv --column prob_IQR --output plots/ANPDB_validation/cluster_physical_chars/prob_IQR_histogram.png

Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/cluster_structural_metrics_12D_full.csv --column mean_distance_core --output plots/ANPDB_validation/cluster_physical_chars/mean_distance_core_histogram.png
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/cluster_structural_metrics_12D_full.csv --column mean_distance_post --output plots/ANPDB_validation/cluster_physical_chars/mean_distance_post_histogram.png
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/cluster_structural_metrics_12D_full.csv --column density_gradient --output plots/ANPDB_validation/cluster_physical_chars/density_gradient_histogram.png
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/cluster_structural_metrics_12D_full.csv --column medoid_centroid_distance --output plots/ANPDB_validation/cluster_physical_chars/medoid_centroid_distance_histogram.png

Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/cluster_probability_stats.csv --column mean_probability --output plots/ANPDB_validation/cluster_physical_chars/mean_probability_histogram.png

Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/cluster_similarity_validation.csv --column mean_within_similarity --output plots/ANPDB_validation/cluster_physical_chars/within_cluster_similarity_histogram.png --binwidth 0.05
Rscript scripts/ANPDB_validation/visualization/histogram_code.R --input data/ANPDB_validation/cluster_analysis_results/cluster_similarity_validation.csv --column separation_ratio --output plots/ANPDB_validation/cluster_physical_chars/separation_ratio_histogram.png --binwidth 0.5

# visualizations - scatterplots 
mkdir plots/ANPDB_validation/scatterplots
Rscript scripts/ANPDB_validation/visualization/scatterplot_single_file.R --input data/ANPDB_validation/cluster_analysis_results/core_frac_classification.csv --x-col core_size --y-col post_noise_size --output plots/ANPDB_validation/scatterplots/core_vs_post_noise_size_scatterplot.pdf 

Rscript scripts/ANPDB_validation/visualization/scatterplot_single_file.R --input data/ANPDB_validation/cluster_analysis_results/cluster_structural_metrics_12D_full.csv --x-col std_distance_post --y-col mean_distance_post --output plots/ANPDB_validation/scatterplots/mean_vs_std_dist_post_scatterplot.pdf 
Rscript scripts/ANPDB_validation/visualization/scatterplot_single_file.R --input data/ANPDB_validation/cluster_analysis_results/cluster_structural_metrics_12D_full.csv --x-col mean_distance_post --y-col mean_distance_core --output plots/ANPDB_validation/scatterplots/mean_dist_core_vs_mean_dist_post_scatterplot.pdf 
Rscript scripts/ANPDB_validation/visualization/scatterplot_single_file.R --input data/ANPDB_validation/cluster_analysis_results/cluster_structural_metrics_12D_full.csv --x-col covariance_volume --y-col mean_distance_post --output plots/ANPDB_validation/scatterplots/mean_dist_post_vs_cov_vol_scatterplot.pdf 
Rscript scripts/ANPDB_validation/visualization/scatterplot_single_file.R --input data/ANPDB_validation/cluster_analysis_results/cluster_structural_metrics_12D_full.csv --x-col medoid_centroid_distance --y-col mean_distance_post --output plots/ANPDB_validation/scatterplots/mean_dist_post_vs_medoid_centroid_dist_scatterplot.pdf 

Rscript scripts/ANPDB_validation/visualization/scatterplot_single_file.R --input data/ANPDB_validation/cluster_analysis_results/cluster_similarity_validation.csv --x-col mean_between_medoid_similarity --y-col mean_within_similarity --output plots/ANPDB_validation/scatterplots/mean_wi_sim_vs_mean_bw_medoid_sim_scatterplot.pdf 
Rscript scripts/ANPDB_validation/visualization/scatterplot_single_file.R --input data/ANPDB_validation/cluster_analysis_results/cluster_similarity_validation.csv --x-col mean_within_similarity --y-col separation_ratio --output plots/ANPDB_validation/scatterplots/sep_ratio_vs_mean_wi_sim_scatterplot.pdf 

Rscript scripts/ANPDB_validation/visualization/scatterplot_single_file.R --input data/ANPDB_validation/cluster_analysis_results/cluster_probability_stats.csv --x-col mean_probability --y-col variance_probability --output plots/ANPDB_validation/scatterplots/var_vs_mean_prob_scatterplot.pdf 
Rscript scripts/ANPDB_validation/visualization/scatterplot_single_file.R --input data/ANPDB_validation/cluster_analysis_results/cluster_probability_stats.csv --x-col mean_probability --y-col IQR_probability --output plots/ANPDB_validation/scatterplots/IQR_vs_mean_prob_scatterplot.pdf 

Rscript scripts/ANPDB_validation/visualization/scatterplot_single_file.R --input data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --x-col LogP_mean --y-col TPSA_mean --output plots/ANPDB_validation/scatterplots/TPSA_vs_LogP_mean_scatterplot.pdf 
Rscript scripts/ANPDB_validation/visualization/scatterplot_single_file.R --input data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --x-col MolWt_mean --y-col LogP_mean --output plots/ANPDB_validation/scatterplots/LogP_vs_MolWt_mean_scatterplot.pdf 
Rscript scripts/ANPDB_validation/visualization/scatterplot_single_file.R --input data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --x-col FractionCSP3_mean --y-col LogP_mean --output plots/ANPDB_validation/scatterplots/FracCSP3_vs_LogP_mean_scatterplot.pdf 
Rscript scripts/ANPDB_validation/visualization/scatterplot_single_file.R --input data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --x-col FractionCSP3_mean --y-col TPSA_mean --output plots/ANPDB_validation/scatterplots/FracCSP3_vs_TPSA_mean_scatterplot.pdf 

# 2 file scatterplots 
mkdir -p plots/ANPDB_validation/scatterplots/two_file_plots
Rscript scripts/ANPDB_validation/visualization/scatterplot_two_files.R --file1 data/ANPDB_validation/cluster_analysis_results/cluster_probability_stats.csv --file2 data/ANPDB_validation/cluster_analysis_results/core_frac_classification.csv --x-col mean_probability --y-col core_fraction --index1 cluster_core --index2 cluster_core --output-file plots/ANPDB_validation/scatterplots/two_file_plots/mean_prob_vs_core_frac.pdf 
Rscript scripts/ANPDB_validation/visualization/scatterplot_two_files.R --file1 data/ANPDB_validation/cluster_analysis_results/cluster_structural_metrics_12D_full.csv --file2 data/ANPDB_validation/cluster_analysis_results/core_frac_classification.csv --x-col density_gradient --y-col core_fraction --index1 cluster_id --index2 cluster_core --output-file plots/ANPDB_validation/scatterplots/two_file_plots/density_grad_vs_mean_prob.pdf 
# 3. Separation ratio vs core fraction
Rscript scripts/ANPDB_validation/visualization/scatterplot_two_files.R --file1 data/ANPDB_validation/cluster_analysis_results/cluster_similarity_validation.csv --file2 data/ANPDB_validation/cluster_analysis_results/core_frac_classification.csv --x-col separation_ratio --y-col core_fraction --index1 cluster_id --index2 cluster_core --output-file plots/ANPDB_validation/scatterplots/two_file_plots/sep_ratio_vs_mean_prob.pdf 
# 4. Dominant scaffold fraction vs separation ratio
Rscript scripts/ANPDB_validation/visualization/scatterplot_two_files.R --file1 data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --file2 data/ANPDB_validation/cluster_analysis_results/cluster_similarity_validation.csv --x-col dominant_scaffold_fraction --y-col separation_ratio --index1 cluster_id --index2 cluster_id --output-file plots/ANPDB_validation/scatterplots/two_file_plots/dom_scaf_frac_vs_sep_ratio.pdf 
# 5. Dominant scaffold fraction vs variance probability
Rscript scripts/ANPDB_validation/visualization/scatterplot_two_files.R --file1 data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --file2 data/ANPDB_validation/cluster_analysis_results/cluster_probability_stats.csv --x-col dominant_scaffold_fraction --y-col variance_probability --index1 cluster_id --index2 cluster_core --output-file plots/ANPDB_validation/scatterplots/two_file_plots/dom_scaf_frac_vs_var_prob.pdf 
# 6. Dominant scaffold fraction vs mean probability
Rscript scripts/ANPDB_validation/visualization/scatterplot_two_files.R --file1 data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --file2 data/ANPDB_validation/cluster_analysis_results/cluster_probability_stats.csv --x-col dominant_scaffold_fraction --y-col mean_probability --index1 cluster_id --index2 cluster_core --output-file plots/ANPDB_validation/scatterplots/two_file_plots/dom_scaf_frac_vs_mean_prob.pdf 
# 7. Dominant scaffold fraction vs core fraction
Rscript scripts/ANPDB_validation/visualization/scatterplot_two_files.R --file1 data/ANPDB_validation/cluster_analysis_results/cluster_full_chemical_profile.csv --file2 data/ANPDB_validation/cluster_analysis_results/core_frac_classification.csv --x-col dominant_scaffold_fraction --y-col core_fraction --index1 cluster_id --index2 cluster_core --output-file plots/ANPDB_validation/scatterplots/two_file_plots/dom_scaf_frac_vs_core_frac.pdf 