import pandas as pd 

physicochemical_df = pd.read_csv("Step_2_Feature_Generation/Final_Compiled_Descriptor_Sets/Resulting_Data/physicochemical_compiled.csv")
physicochemical_df = physicochemical_df.drop('Unnamed: 0', axis=1)

d3_df = pd.read_csv("Step_2_Feature_Generation/Final_Compiled_Descriptor_Sets/Resulting_Data/3d_final_compiled.csv")
d3_df = d3_df.drop('Unnamed: 0', axis=1)
d3_df.rename(columns={'Molecule_ID': 'identifier'}, inplace=True)

estate_df = pd.read_csv("Step_2_Feature_Generation/Final_Compiled_Descriptor_Sets/Resulting_Data/estate_compiled.csv")
estate_df = estate_df.drop('Unnamed: 0', axis=1)

partial_charge_df = pd.read_csv("Step_2_Feature_Generation/Final_Compiled_Descriptor_Sets/Resulting_Data/partial_charge_compiled.csv")
partial_charge_df = partial_charge_df.drop('Unnamed: 0', axis=1)

pharmacophoric_df = pd.read_csv("Step_2_Feature_Generation/Final_Compiled_Descriptor_Sets/Resulting_Data/pharmacophoric_compiled.csv")
pharmacophoric_df = pharmacophoric_df.drop('Unnamed: 0', axis=1)

ring_df = pd.read_csv("Step_2_Feature_Generation/Final_Compiled_Descriptor_Sets/Resulting_Data/ring_compiled.csv")
ring_df = ring_df.drop('Unnamed: 0', axis=1)

graph_topo_df = pd.read_csv("Step_2_Feature_Generation/Final_Compiled_Descriptor_Sets/Resulting_Data/graph_and_topo_compiled.csv")
graph_topo_df = graph_topo_df.drop('Unnamed: 0', axis=1)

inter_merge_1 = pd.merge(physicochemical_df, d3_df, on="identifier", how="inner")
inter_merge_2 = pd.merge(inter_merge_1, estate_df, on="identifier", how="inner")
inter_merge_3 = pd.merge(inter_merge_2, partial_charge_df, on="identifier", how="inner")
inter_merge_4 = pd.merge(inter_merge_3, pharmacophoric_df, on="identifier", how="inner")
inter_merge_5 = pd.merge(inter_merge_4, ring_df, on="identifier", how="inner")
final_merge = pd.merge(inter_merge_5, graph_topo_df, on="identifier", how="inner")

final_merge = final_merge.drop('canonical_smiles', axis=1)

final_merge.to_csv("DATA/final_complete_descriptor_matrix.csv")