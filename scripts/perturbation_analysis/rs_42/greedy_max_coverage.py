import pandas as pd
from collections import defaultdict


def generate_greedy_correlation_matrices(
    flatfile_csv1,
    flatfile_csv2,
    original_csv1,
    original_csv2,
    target_count=25,
    corr_threshold=0.75
):

    def process_dataset(flatfile_csv, original_csv):

        # Read flat correlation file
        df = pd.read_csv(flatfile_csv)

        if 'Unnamed: 0' in df.columns:
            df = df.drop('Unnamed: 0', axis=1)

        grouped_feature_ls = []
        correlated_groups = []

        for feature in df.feature1.unique():

            if feature not in grouped_feature_ls:

                correlated_block = df[df.feature1 == feature]

                grouped_feature_ls += (
                    list(correlated_block.feature2.unique()) + [feature]
                )

                correlated_groups.append(correlated_block)

        print(f'found {len(correlated_groups)} correlated groups')

        df_grouped = pd.concat(
            [correlated_groups[i] for i in range(len(correlated_groups))],
            axis=0
        )

        # GREEDY MAXIMUM COVERAGE
        def method1_greedy_max_coverage(
            df_input,
            target_count=25,
            corr_threshold=0.75
        ):

            all_features = (
                set(df_input['feature1'].unique()) |
                set(df_input['feature2'].unique())
            )

            correlations = defaultdict(list)

            for _, row in df_input.iterrows():

                correlations[row['feature1']].append(
                    (row['feature2'], row['corr'])
                )

                correlations[row['feature2']].append(
                    (row['feature1'], row['corr'])
                )

            selected = []
            remaining = all_features.copy()

            feature_importance = {
                f: len(correlations[f])
                for f in all_features
            }

            while len(selected) < target_count and remaining:

                best_feature = None
                best_score = -1

                for feature in remaining:

                    score = feature_importance[feature]

                    for sel_feature in selected:

                        for corr_feature, corr_val in correlations[feature]:

                            if (
                                corr_feature == sel_feature and
                                corr_val > corr_threshold
                            ):

                                score -= corr_val * 10

                    if score > best_score:

                        best_score = score
                        best_feature = feature

                if best_feature:

                    selected.append(best_feature)
                    remaining.remove(best_feature)

            return selected

        selected_features = method1_greedy_max_coverage(
            df_grouped,
            target_count=target_count,
            corr_threshold=corr_threshold
        )

        print(f"Selected {len(selected_features)} features")
        print(selected_features[:10], "...")

        # Read original descriptor dataframe
        final_df = pd.read_csv(original_csv)

        # Keep only selected features
        final_df = final_df[selected_features]

        # Generate correlation matrix only
        corr_matrix = final_df.corr(method='spearman')

        return corr_matrix, selected_features

    corr_matrix1, selected1 = process_dataset(
        flatfile_csv1,
        original_csv1
    )

    corr_matrix2, selected2 = process_dataset(
        flatfile_csv2,
        original_csv2
    )

    return (
        corr_matrix1,
        selected1,
        corr_matrix2,
        selected2
    )

corr1, features1, corr2, features2 = generate_greedy_correlation_matrices(
    flatfile_csv1="DATA/perturbation_data/rs_42/40_df_flat_file.csv",
    flatfile_csv2="DATA/perturbation_data/rs_42/60_df_flat_file.csv",
    original_csv1="DATA/perturbation_data/rs_42/40_df.csv",
    original_csv2="DATA/perturbation_data/rs_42/60_df.csv",
    target_count=25
)

corr1.to_csv("DATA/perturbation_data/rs_42/40_df_greedy_corr_matrix.csv")
corr2.to_csv("DATA/perturbation_data/rs_42/60_df_greedy_corr_matrix.csv")