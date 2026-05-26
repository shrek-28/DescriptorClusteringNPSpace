# =========================================================
# Libraries
# =========================================================

library(readr)
library(dplyr)
library(ggplot2)

# =========================================================
# Base directory
# =========================================================

base_dir <- "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/bland_altman_plots"
dir.create(base_dir, showWarnings = FALSE, recursive = TRUE)

# =========================================================
# Bland-Altman Function (x vs y generic)
# =========================================================

plot_bland_altman <- function(
    input_file,
    x_column,
    y_column,
    output_file,
    
    plot_title = NULL,
    x_label = "Average of Two Values",
    y_label = "Absolute Difference Between Two Values",
    
    point_color = "#4C72B0",
    point_size = 1,
    point_alpha = 0.6,
    
    regression_color = "#DD8452",
    regression_width = 1,
    
    annotation_size = 4,
    annotation_hjust = 1.05,
    annotation_vjust = 1.1,
    
    width = 8,
    height = 6
) {
  
  df <- read_csv(input_file)
  
  if (!(x_column %in% colnames(df))) stop(paste(x_column, "not found"))
  if (!(y_column %in% colnames(df))) stop(paste(y_column, "not found"))
  
  x_values <- df[[x_column]]
  y_values <- df[[y_column]]
  
  valid <- is.finite(x_values) & is.finite(y_values)
  x_values <- x_values[valid]
  y_values <- y_values[valid]
  
  averages <- (x_values + y_values) / 2
  differences <- abs(x_values - y_values)
  
  model <- lm(differences ~ averages)
  slope <- coef(model)[2]
  intercept <- coef(model)[1]
  r2 <- summary(model)$r.squared
  r <- cor(averages, differences)
  
  eq_label <- paste0(
    "y = ", round(slope, 4), "x + ", round(intercept, 4),
    "\nR² = ", round(r2, 4),
    "\nr = ", round(r, 4)
  )
  
  plot_df <- data.frame(averages = averages, differences = differences)
  
  if (is.null(plot_title)) {
    plot_title <- paste("Bland-Altman:", x_column, "vs", y_column)
  }
  
  p <- ggplot(plot_df, aes(x = averages, y = differences)) +
    geom_point(color = point_color, size = point_size, alpha = point_alpha) +
    geom_smooth(method = "lm", se = TRUE, color = regression_color, linewidth = regression_width) +
    annotate("text", x = Inf, y = Inf, label = eq_label,
             hjust = annotation_hjust, vjust = annotation_vjust,
             size = annotation_size) +
    labs(title = plot_title, x = x_label, y = y_label) +
    theme_bw(base_size = 14) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
      axis.title = element_text(face = "bold", size = 13),
      axis.text = element_text(size = 11),
      panel.grid.minor = element_blank()
    )
  
  print(p)
  
  ggsave(filename = output_file, plot = p, width = width, height = height, dpi = 300)
}

# =========================================================
# Input file
# =========================================================

input_file <- "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv"

# =========================================================
# Descriptor list
# =========================================================

descriptors <- c(
  "MolWt",
  "TPSA",
  "LogP",
  "AromaticRingCount",
  "RotatableBonds",
  "FractionCSP3",
  "HBD",
  "HBA"
)

# =========================================================
# Helper: folder creator
# =========================================================

get_desc_dir <- function(desc) {
  path <- file.path(base_dir, desc)
  dir.create(path, showWarnings = FALSE, recursive = TRUE)
  return(path)
}

# =========================================================
# Helper: one-line wrapper
# =========================================================

run_plot <- function(x_col, y_col, desc, name) {
  plot_bland_altman(
    input_file = input_file,
    x_column = x_col,
    y_column = y_col,
    output_file = file.path(get_desc_dir(desc), paste0(name, ".pdf"))
  )
}

# =========================================================
# Mean vs Medoid
# =========================================================

run_plot("MolWt_mean","medoid_MolWt","MolWt","mean_vs_medoid")
run_plot("TPSA_mean","medoid_TPSA","TPSA","mean_vs_medoid")
run_plot("LogP_mean","medoid_LogP","LogP","mean_vs_medoid")
run_plot("AromaticRingCount_mean","medoid_AromaticRingCount","AromaticRingCount","mean_vs_medoid")
run_plot("FractionCSP3_mean","medoid_FractionCSP3","FractionCSP3","mean_vs_medoid")
run_plot("HBD_mean","medoid_HBD","HBD","mean_vs_medoid")
run_plot("HBA_mean","medoid_HBA","HBA","mean_vs_medoid")
run_plot("RotatableBonds_mean","medoid_RotatableBonds","RotatableBonds","mean_vs_medoid")


# =========================================================
# Mean vs Centroid Closest
# =========================================================

run_plot("MolWt_mean","centroid_closest_MolWt","MolWt","mean_vs_centroid")
run_plot("TPSA_mean","centroid_closest_TPSA","TPSA","mean_vs_centroid")
run_plot("LogP_mean","centroid_closest_LogP","LogP","mean_vs_centroid")
run_plot("AromaticRingCount_mean","centroid_closest_AromaticRingCount","AromaticRingCount","mean_vs_centroid")
run_plot("FractionCSP3_mean","centroid_closest_FractionCSP3","FractionCSP3","mean_vs_centroid")
run_plot("HBD_mean","centroid_closest_HBD","HBD","mean_vs_centroid")
run_plot("HBA_mean","centroid_closest_HBA","HBA","mean_vs_centroid")
run_plot("RotatableBonds_mean","centroid_closest_RotatableBonds","RotatableBonds","mean_vs_centroid")


# =========================================================
# Medoid vs Centroid Closest
# =========================================================

run_plot("medoid_MolWt","centroid_closest_MolWt","MolWt","medoid_vs_centroid")
run_plot("medoid_TPSA","centroid_closest_TPSA","TPSA","medoid_vs_centroid")
run_plot("medoid_LogP","centroid_closest_LogP","LogP","medoid_vs_centroid")
run_plot("medoid_AromaticRingCount","centroid_closest_AromaticRingCount","AromaticRingCount","medoid_vs_centroid")
run_plot("medoid_FractionCSP3","centroid_closest_FractionCSP3","FractionCSP3","medoid_vs_centroid")
run_plot("medoid_HBD","centroid_closest_HBD","HBD","medoid_vs_centroid")
run_plot("medoid_HBA","centroid_closest_HBA","HBA","medoid_vs_centroid")
run_plot("medoid_RotatableBonds","centroid_closest_RotatableBonds","RotatableBonds","medoid_vs_centroid")

# =========================================================
# Diverse 1 vs Medoid
# =========================================================

run_plot("diverse_1_MolWt","medoid_MolWt","MolWt","diverse1_vs_medoid")
run_plot("diverse_1_TPSA","medoid_TPSA","TPSA","diverse1_vs_medoid")
run_plot("diverse_1_LogP","medoid_LogP","LogP","diverse1_vs_medoid")
run_plot("diverse_1_AromaticRingCount","medoid_AromaticRingCount","AromaticRingCount","diverse1_vs_medoid")
run_plot("diverse_1_FractionCSP3","medoid_FractionCSP3","FractionCSP3","diverse1_vs_medoid")
run_plot("diverse_1_HBD","medoid_HBD","HBD","diverse1_vs_medoid")
run_plot("diverse_1_HBA","medoid_HBA","HBA","diverse1_vs_medoid")
run_plot("diverse_1_RotatableBonds","medoid_RotatableBonds","RotatableBonds","diverse1_vs_medoid")

# =========================================================
# Repeat for Diverse 2–5
# =========================================================

for (i in 2:5) {
  prefix <- paste0("diverse_", i, "_")
  
  run_plot(paste0(prefix,"MolWt"),"medoid_MolWt","MolWt",paste0("diverse",i,"_vs_medoid"))
  run_plot(paste0(prefix,"TPSA"),"medoid_TPSA","TPSA",paste0("diverse",i,"_vs_medoid"))
  run_plot(paste0(prefix,"LogP"),"medoid_LogP","LogP",paste0("diverse",i,"_vs_medoid"))
  run_plot(paste0(prefix,"AromaticRingCount"),"medoid_AromaticRingCount","AromaticRingCount",paste0("diverse",i,"_vs_medoid"))
  run_plot(paste0(prefix,"FractionCSP3"),"medoid_FractionCSP3","FractionCSP3",paste0("diverse",i,"_vs_medoid"))
  run_plot(paste0(prefix,"HBD"),"medoid_HBD","HBD",paste0("diverse",i,"_vs_medoid"))
  run_plot(paste0(prefix,"HBA"),"medoid_HBA","HBA",paste0("diverse",i,"_vs_medoid"))
  run_plot(paste0(prefix,"RotatableBonds"),"medoid_RotatableBonds","RotatableBonds",paste0("diverse",i,"_vs_medoid"))
  
}