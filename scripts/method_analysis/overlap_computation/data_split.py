import pandas as pd
import os


def split_csv_by_columns(
    input_file,
    output_folder,
    col1,
    col2
):

    # -----------------------------------------------------
    # CREATE OUTPUT FOLDER
    # -----------------------------------------------------

    os.makedirs(output_folder, exist_ok=True)

    # -----------------------------------------------------
    # LOAD CSV
    # -----------------------------------------------------

    df = pd.read_csv(input_file)

    # -----------------------------------------------------
    # GROUP DATA
    # -----------------------------------------------------

    grouped = df.groupby([col1, col2])

    # -----------------------------------------------------
    # EXPORT EACH GROUP
    # -----------------------------------------------------

    for (value1, value2), group in grouped:

        # File name
        filename = f"{value1}_{value2}.csv"

        # Full output path
        output_path = os.path.join(
            output_folder,
            filename
        )

        # Export
        group.to_csv(
            output_path,
            index=False
        )

        print(f"Saved: {output_path}")

    print("\nAll files exported successfully.")

# =========================================================
# EXAMPLE USAGE
# =========================================================

split_csv_by_columns(input_file="data/method_analysis/across_bands.csv", output_folder="data/method_analysis/bands_counts", col1="desc_count", col2="method")
split_csv_by_columns(input_file="data/method_analysis/across_methods.csv", output_folder="data/method_analysis/methods_results", col1="desc_count", col2="band")
split_csv_by_columns(input_file="data/method_analysis/across_descriptor_counts.csv", output_folder="data/method_analysis/desc_counts_results", col1="method", col2="band")