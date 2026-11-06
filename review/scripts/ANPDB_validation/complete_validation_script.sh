cd /Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/review
python3 scripts/ANPDB_validation/2d_file_split.py --input data/ANPDB_validation/ANPDB_molecules.sdf --output data/ANPDB_validation/split_sdf_files

chmod +x scripts/ANPDB_validation/2d_to_3d_converter.sh
./scripts/ANPDB_validation/2d_to_3d_converter.sh data/ANPDB_validation/split_sdf_files data/ANPDB_validation/3d_converted_files

# energy minimization
python3 scripts/ANPDB_validation/energy_minimization.py --input data/ANPDB_validation/3d_converted_files --output data/ANPDB_validation/minimized_files --ff UFF