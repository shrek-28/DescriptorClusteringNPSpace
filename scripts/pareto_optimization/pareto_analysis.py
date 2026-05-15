import numpy as np
import pandas as pd 

bands = {
    "10": {
        "band1": ["BertzCTIndex", "Ether", "GraphDistanceDistributionEntropy", "Avg_EState", "HeteroatomCount", "PMI2", "Min_EState", "HBD", "PathComplexityIndex", "Carbonyl"],
        "band2": ["BertzCTIndex", "Carbonyl", "GraphDistanceDistributionEntropy", "PMI2", "PathComplexityIndex", "AromaticRingCount", "Avg_EState", "SpherocityIndex", "Asphericity", "Eccentricity"], 
        "band3": ["BertzCTIndex", "GraphDistanceDistributionEntropy", "Avg_EState", "PMI2", "FractionCSP3", "BridgeheadAtomCount", "Asphericity", "Eccentricity", "ShapeIndex", "StereocenterCount"], 
        "band4": ["BertzCTIndex", "Chi4", "Chi3", "Chi2", "Chi1", "TPSA", "Chi0", "AtomInformationContent", "BoundingBoxVolume", "HeteroatomCount"]
    }, 
    "15":{
        "band1": ["BertzCTIndex", "Ether", "GraphDistanceDistributionEntropy", "Avg_EState", "PMI2", "HeteroatomCount", "TPSA", "Bridged_ring_count", "ShapeIndex", "Carbonyl", "PathComplexityIndex", "AromaticRingCount", "StereocenterCount", "Fused_ring_count", "AtomInformationContent"], 
        "band2": ["BertzCTIndex", "Carbonyl", "GraphDistanceDistributionEntropy", "PMI2", "PathComplexityIndex", "AromaticRingCount", "Avg_EState", "Eccentricity", "SpherocityIndex", "Asphericity", "TPSA", "Largest_ring_size", "BridgeheadAtomCount", "HeteroatomCount", "TopologicalDiameter"], 
        "band3": ["BertzCTIndex", "GraphDistanceDistributionEntropy", "Avg_EState", "PMI2", "FractionCSP3", "BridgeheadAtomCount", "Eccentricity", "Asphericity", "ShapeIndex", "StereocenterCount", "SpherocityIndex", "TPSA", "Max_EState", "Phenol", "InertialShapeFactor"], 
        "band4": ["Chi3", "BertzCTIndex", "Chi4", "Chi2", "TPSA", "Chi0", "Chi1", "AtomInformationContent", "BoundingBoxVolume", "CovalentRadiusSum", "HeteroatomCount", "RingCount", "SSSR_count", "StereocenterCount", "BalabanIndex"]
    }, 
    "20": {
        "band1": ["BertzCTIndex", "Ether", "GraphDistanceDistributionEntropy", "Avg_EState", "PMI2", "HeteroatomCount", "Min_EState", "HBD", "Carbonyl", "Bridged_ring_count", "ShapeIndex", "PathComplexityIndex", "FractionCSP3", "Fused_ring_count", "HBA", "PMI_Ratio2", "AtomInformationContent", "InertialShapeFactor", "StereocenterCount", "Quaternary_Carbons"], 
        "band2": ["BertzCTIndex", "Carbonyl", "GraphDistanceDistributionEntropy", "PMI2", "PathComplexityIndex", "AromaticRingCount", "Avg_EState", "Asphericity", "Eccentricity", "SpherocityIndex", "TPSA", "BridgeheadAtomCount", "Largest_ring_size", "TopologicalDiameter", "ShapeIndex", "HeteroatomCount", "HBA", "InertialShapeFactor", "Max_EState", "RadiusOfGyration"], 
        "band3": ["BertzCTIndex", "GraphDistanceDistributionEntropy", "Avg_EState", "FractionCSP3", "PMI2", "BridgeheadAtomCount", "Asphericity", "Eccentricity", "StereocenterCount", "ShapeIndex", "SpherocityIndex", "InertialShapeFactor", "Phenol", "Max_EState", "TPSA", "AromaticRingCount", "Largest_ring_size", "RingCount", "Chi4", "partial_charge_max"], 
        "band4": ["Chi4", "Chi3", "BertzCTIndex", "Chi2", "Chi0", "Chi1", "TPSA", "HeteroatomCount", "BoundingBoxVolume", "BalabanIndex", "AtomInformationContent", "CovalentRadiusSum", "RingCount", "SSSR_count", "StereocenterCount", "HBA", "Max_EState", "RotatableBonds", "Min_EState", "Ether"]
    }, 
    "25": {
        "band1": ["BertzCTIndex", "Ether", "GraphDistanceDistributionEntropy", "Avg_EState", "PMI2", "HeteroatomCount", "Min_EState", "HBD", "SSSR_count", "Carbonyl", "ShapeIndex", "RingCount", "SpherocityIndex", "AromaticRingCount", "StereocenterCount", "AtomInformationContent", "HBA", "PMI_Ratio2", "Quaternary_Carbons", "InertialShapeFactor", "Max_EState", "Chi4", "LogP", "Fraction_aromatic_rings", "PMI3"], 
        "band2": ["BertzCTIndex", "Carbonyl", "GraphDistanceDistributionEntropy", "PMI2", "PathComplexityIndex", "AromaticRingCount", "Avg_EState", "Eccentricity", "SpherocityIndex", "Asphericity", "BridgeheadAtomCount", "Largest_ring_size", "TPSA", "ShapeIndex", "TopologicalDiameter", "HeteroatomCount", "RadiusOfGyration", "HBA", "Min_EState", "Max_EState", "InertialShapeFactor", "Spiro_atom_count", "HBD", "Chi2", "Quaternary_Carbons"], 
        "band3": ["BertzCTIndex", "GraphDistanceDistributionEntropy", "Avg_EState", "PMI2", "FractionCSP3", "BridgeheadAtomCount", "Eccentricity", "Asphericity", "ShapeIndex", "StereocenterCount", "SpherocityIndex", "Max_EState", "InertialShapeFactor", "Phenol", "TPSA", "AromaticRingCount", "RadiusOfGyration", "PathComplexityIndex", "HBA", "SSSR_count", "PMI3", "Macrocycle_count", "TopologicalRadius", "Chi3", "TopologicalDiameter"], 
        "band4": ["Chi3", "Chi4", "BertzCTIndex", "Chi2", "Chi1", "TPSA", "Chi0", "HeteroatomCount", "CovalentRadiusSum", "AtomInformationContent", "BalabanIndex", "BoundingBoxVolume", "SSSR_count", "RingCount", "HBA", "StereocenterCount", "Min_EState", "RotatableBonds", "Max_EState", "Avg_EState", "Ether", "HeavyAtomCount", "TopologicalDiameter", "DoubleBondCount", "RadiusOfGyration"]
    }
}

df_desc = pd.read_csv("data/final_complete_descriptor_matrix.csv")
df_desc = df_desc.drop('Unnamed: 0', axis=1)
df_desc.set_index('identifier', inplace=True)

# drop completely constant descriptors if any
df_desc = df_desc.loc[:, df_desc.std() != 0]

# remove non-numeric columns if they slipped in
df_desc = df_desc.select_dtypes(include=[np.number])

# Z-Score standardization
df_std = (df_desc - df_desc.mean()) / df_desc.std()
df_std = df_std.fillna(0.0)

# total variance baseline 
cov_full = df_std.cov()
V_full = np.trace(cov_full.values)

# pareto and redundancy analysis
results = []

for k, band_dict in bands.items():
    k = int(k)

    for band_name, descriptor_list in band_dict.items():

        df_k = df_std[descriptor_list]

        # variance captured
        cov_k = df_k.cov()
        V_k = np.trace(cov_k.values)
        variance_fraction = V_k / V_full

        # correlation redundancy
        corr = df_k.corr().abs()
        upper = corr.where(
            np.triu(np.ones(corr.shape), k=1).astype(bool)
        )

        mean_abs_corr = upper.stack().mean()
        max_abs_corr = upper.stack().max()

        results.append({
            "k": k,
            "band": band_name,
            "n_descriptors": len(descriptor_list),
            "variance_fraction": variance_fraction,
            "mean_abs_corr": mean_abs_corr,
            "max_abs_corr": max_abs_corr
        })

## dataframe save
pareto_df = (
    pd.DataFrame(results)
    .sort_values(["k", "band"])
    .reset_index(drop=True)
)

pareto_df.to_csv("data/pareto_optimization/pareto_df.csv")