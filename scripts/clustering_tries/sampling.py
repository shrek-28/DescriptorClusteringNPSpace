import pandas as pd 

df = pd.read_csv("data/final_complete_descriptor_matrix.csv")

print(df.columns)

df = df[['identifier', 'AromaticRingCount', 'BridgeheadAtomCount', 'HeteroatomCount', 'StereocenterCount', 'TripleBondCount', 
         'PMI1', 'PMI2', 'SpherocityIndex', 'InertialShapeFactor', 
         'Max_EState',  'Min_EState', 'Avg_EState', 
         'Carbonyl', 
         'Largest_ring_size', 
         'BertzCTIndex', 'AtomInformationContent', 'TPSA', 'GraphDistanceDistributionEntropy', 'PathComplexityIndex', 'ShapeIndex']]

sample_df = df.sample(n=50000, random_state=42)

sample_df.to_csv("DATA/sample_df.csv")