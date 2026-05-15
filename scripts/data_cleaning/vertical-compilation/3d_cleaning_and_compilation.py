import pandas as pd 

df1 = pd.read_csv("Step_2_Feature_Generation/3D_Raw_Data/combine.csv")
df2 = pd.read_csv("Step_2_Feature_Generation/3D_Raw_Data/missing3d.csv")

df = pd.concat([df1, df2])

## CREATING A CSV OF PROBLEM MOLECULES 

#-------------------------------------------------------------------------------
cols_to_check = ['RadiusOfGyration', 'Asphericity', 'Eccentricity',
                 'SpherocityIndex', 'InertialShapeFactor', 'PMI1',
                 'PMI2', 'PMI3', 'PMI_Ratio1', 'PMI_Ratio2']

df_nulls = df[df[cols_to_check].isnull().any(axis=1)]

df_nulls.to_csv("DATA/problem_molecules.csv")
#--------------------------------------------------------------------------------

df = df[~df[cols_to_check].isnull().any(axis=1)]

df = df.drop(['MeanConformerEnergy', 'LowestConformerEnergy', 'Error'], axis=1)
df = df.drop(['3D_Volume', '3D_SurfaceArea', 'NormalizedPMI1', 'NormalizedPMI2', 'InertiaRatio', 'DihedralAngleRange'], axis=1)
df = df.drop('APolarSurfaceArea', axis=1)

df.to_csv("Step_2_Feature_Generation/Final_Compiled_Descriptor_Sets/Resulting_Data/3d_final_compiled.csv")