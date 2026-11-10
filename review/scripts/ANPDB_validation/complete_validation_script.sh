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