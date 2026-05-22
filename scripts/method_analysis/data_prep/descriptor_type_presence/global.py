import pandas as pd 

descriptors = {
    "physicochemical": ["MolWt", "HeavyAtomCount", "TotalAtomCount", "RotatableBonds", "RingCount",  "FractionCSP3", "HBD", "HBA", "TPSA", "FormalCharge", "LogP", "MolarRefractivity", "HeteroatomCount", "StereocenterCount", "DoubleBondCount", "TripleBondCount", "BridgeheadAtomCount"],
    "3D": ["RadiusOfGyration", "Eccentricity", "Asphericity", "SpherocityIndex", "InertialShapeFactor", "PMI1", "PMI2", "PMI3", "PMI_Ratio1", "PMIRatio_2", "BoundingBoxVolume", "CovalentRadiusSum", "ConformerCount", "ShapeIndex"],
    "EState": ["Max_EState", "Min_EState", "Avg_EState"], 
    "partial_charge": ["partial_charge_max", "partial_charge_min", "total_partial_charge"],
    "pharmacophoric": ["Hydroxyl", "Carbonyl", "Amine", "Halogen", "Sulfonyl", "Ester", "Ether", "Thiol", "Phenol", "Carboxylic_Acid", "Imine", "Alkyne", "Nitrile", "Aldehyde", "Ketone", "Lactone", "Lactam", "Halogenated_Aromatics", "Quarternary_Carbons"], 
    "ring": ["SSSR_Count", "Largest_ring_size", "Macrocycle_count", "Fraction_aromatic_rings", "AromaticRingCount", "Fused_ring_count", "Bridged_ring_count", "Spiro_atom_count"],
    "graph_and_topo": ["WienerIndex", "ZagrebIndex", "BalabanIndex", "BertzCTIndex", "Chi0", "Chi1", "Chi2", "Chi3", "Chi4", "AtomInformationContent", "BondInformationContent", "TopologicalDiameter", "TopologicalRadius", "TotalPathCount", "FragmentComplexityScore", "PathComplexityScore", "GraphDistanceDistributionEntropy"],
}

def summarize_descriptor_types(input_file, summary_csv, descriptors_dict=descriptors):
    df = pd.read_csv(input_file)

    descriptor_to_type = {
        descriptor:dtype
        for dtype, dlist in descriptors_dict.items()
        for descriptor in dlist
    }
    
    df["descriptor_type"] = df["descriptor"].map(descriptor_to_type)


    summary = (
        df.groupby("descriptor_type")["count"]
        .sum()
        .reset_index(name="total_occurrence")
    )

    # Total descriptors available in each category
    category_sizes = {
        dtype: len(dlist)
        for dtype, dlist in descriptors_dict.items()
    }

    summary["num_descriptors_in_category"] = (
        summary["descriptor_type"]
        .map(category_sizes)
    )

    # Normalized occurrence score
    summary["normalized_occurrence"] = round((
        summary["total_occurrence"] /
        summary["num_descriptors_in_category"]
    ), 2)

    # Sort by normalized enrichment
    summary = summary.sort_values(
        by="normalized_occurrence",
        ascending=False
    )

    # Save
    summary.to_csv(summary_csv, index=False)

summarize_descriptor_types(input_file="data/method_analysis/descriptor_occurrence_analysis.csv", summary_csv="data/method_analysis/descriptor_type_presence/global_summary.csv")

summarize_descriptor_types(input_file="data/method_analysis/method_wise_desc_presence/greedy_max_coverage_descriptor_occurrence.csv", summary_csv="data/method_analysis/descriptor_type_presence/methods/greedy_max_coverage_summary.csv")
summarize_descriptor_types(input_file="data/method_analysis/method_wise_desc_presence/hierarchical_max_avg_descriptor_occurrence.csv", summary_csv="data/method_analysis/descriptor_type_presence/methods/hierarchical_max_avg_summary.csv")
summarize_descriptor_types(input_file="data/method_analysis/method_wise_desc_presence/hierarchical_min_avg_descriptor_occurrence.csv", summary_csv="data/method_analysis/descriptor_type_presence/methods/hierarchical_min_avg_summary.csv")

summarize_descriptor_types(input_file="data/method_analysis/desc_method_wise/band1_descriptor_occurrence.csv", summary_csv="data/method_analysis/descriptor_type_presence/bands/band1_summary.csv")
summarize_descriptor_types(input_file="data/method_analysis/desc_method_wise/band2_descriptor_occurrence.csv", summary_csv="data/method_analysis/descriptor_type_presence/bands/band2_summary.csv")
summarize_descriptor_types(input_file="data/method_analysis/desc_method_wise/band3_descriptor_occurrence.csv", summary_csv="data/method_analysis/descriptor_type_presence/bands/band3_summary.csv")
summarize_descriptor_types(input_file="data/method_analysis/desc_method_wise/band4_descriptor_occurrence.csv", summary_csv="data/method_analysis/descriptor_type_presence/bands/band4_summary.csv")

summarize_descriptor_types(input_file="data/method_analysis/band_wise_analysis/10_descriptor_occurrence.csv", summary_csv="data/method_analysis/descriptor_type_presence/desc_counts/10_summary.csv")
summarize_descriptor_types(input_file="data/method_analysis/band_wise_analysis/15_descriptor_occurrence.csv", summary_csv="data/method_analysis/descriptor_type_presence/desc_counts/15_summary.csv")
summarize_descriptor_types(input_file="data/method_analysis/band_wise_analysis/20_descriptor_occurrence.csv", summary_csv="data/method_analysis/descriptor_type_presence/desc_counts/20_summary.csv")
summarize_descriptor_types(input_file="data/method_analysis/band_wise_analysis/25_descriptor_occurrence.csv", summary_csv="data/method_analysis/descriptor_type_presence/desc_counts/25_summary.csv")
