import pandas as pd 
from pathlib import Path

base_path = Path("data/perturbation_data")
final_20 = {"AromaticRingCount", "BridgeheadAtomCount", "PMI1", "PMI2", "SpherocityIndex", "InertialShapeFactor", "Carbonyl", "Largest_ring_size", "AtomInformationContent", "TPSA", "GraphDistanceDistributionEntropy", "PathComplexityIndex", "ShapeIndex", "Avg_EState", "Min_EState", "Max_EState"}
seeds = [0, 1, 42, 101, 123]

results = []

for seed in seeds:

    file_40 = base_path / f"rs_{seed}" / "40_df_greedy_corr_matrix.csv"
    file_60 = base_path / f"rs_{seed}" / "60_df_greedy_corr_matrix.csv"

    cols_40 = set(pd.read_csv(file_40, nrows=0).columns)
    cols_60 = set(pd.read_csv(file_60, nrows=0).columns)

    inter_40_60 = cols_40 & cols_60
    union_40_60 = cols_40 | cols_60

    similarity_40_60 = (
        len(inter_40_60) / len(union_40_60)
    ) * 100

    inter_40_20 = cols_40 & final_20

    presence_40_20 = (
        len(inter_40_20) / len(final_20)
    ) * 100

    similarity_40_20 = (
        len(inter_40_20) / len(cols_40 | final_20)
    ) * 100


    inter_60_20 = cols_60 & final_20

    presence_60_20 = (
        len(inter_60_20) / len(final_20)
    ) * 100

    similarity_60_20 = (
        len(inter_60_20) / len(cols_60 | final_20)
    ) * 100

    results.append({

        "seed": seed,

        # 40 vs 60
        "shared_40_60": len(inter_40_60),
        "similarity_40_60": round(similarity_40_60, 2),

        # 40 vs final20
        "shared_40_final20": len(inter_40_20),
        "presence_40_final20": round(presence_40_20, 2),
        "similarity_40_final20": round(similarity_40_20, 2),

        # 60 vs final20
        "shared_60_final20": len(inter_60_20),
        "presence_60_final20": round(presence_60_20, 2),
        "similarity_60_final20": round(similarity_60_20, 2)
    })

results_df = pd.DataFrame(results)

print(results_df)

# # ==========================================
# # SAVE
# # ==========================================

results_df.to_csv(
    "data/perturbation_data/descriptor_stability_results.csv",
    index=False
)