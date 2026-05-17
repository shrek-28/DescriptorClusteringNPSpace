# =========================================================
# Libraries
# =========================================================

library(readr)
library(dplyr)
library(ggplot2)

# =========================================================
# Bland-Altman Plot Function
# =========================================================

plot_bland_altman <- function(
    
  input_file,
  
  descriptor,
  
  output_file,
  
  # -----------------------------------------------------
  # Column prefixes
  # -----------------------------------------------------
  
  mean_suffix = "_mean",
  medoid_prefix = "medoid_",
  
  # -----------------------------------------------------
  # Labels
  # -----------------------------------------------------
  
  plot_title = NULL,
  
  x_label =
    "Average of Mean and Medoid Values",
  
  y_label =
    "Absolute Difference Between Mean and Medoid",
  
  # -----------------------------------------------------
  # Point aesthetics
  # -----------------------------------------------------
  
  point_color = "#1F77B4",
  point_size = 1,
  point_alpha = 0.6,
  
  # -----------------------------------------------------
  # Regression aesthetics
  # -----------------------------------------------------
  
  regression_color = "#DD8452",
  regression_width = 1,
  
  # -----------------------------------------------------
  # Annotation aesthetics
  # -----------------------------------------------------
  
  annotation_size = 4,
  annotation_hjust = 1.05,
  annotation_vjust = 1.1,
  
  # -----------------------------------------------------
  # Figure size
  # -----------------------------------------------------
  
  width = 8,
  height = 6
) {
  
  # =======================================================
  # Read data
  # =======================================================
  
  df <- read_csv(input_file)
  
  # =======================================================
  # Construct column names
  # =======================================================
  
  mean_col <- paste0(descriptor, mean_suffix)
  
  medoid_col <- paste0(
    medoid_prefix,
    descriptor
  )
  
  # =======================================================
  # Validate columns
  # =======================================================
  
  if (!(mean_col %in% colnames(df))) {
    
    stop(
      paste(mean_col, "not found")
    )
  }
  
  if (!(medoid_col %in% colnames(df))) {
    
    stop(
      paste(medoid_col, "not found")
    )
  }
  
  # =======================================================
  # Extract values
  # =======================================================
  
  mean_values <- df[[mean_col]]
  
  medoid_values <- df[[medoid_col]]
  
  # =======================================================
  # Clean invalid values
  # =======================================================
  
  valid <-
    is.finite(mean_values) &
    is.finite(medoid_values)
  
  mean_values   <- mean_values[valid]
  medoid_values <- medoid_values[valid]
  
  # =======================================================
  # Bland-Altman calculations
  # =======================================================
  
  averages <-
    (mean_values + medoid_values) / 2
  
  differences <-
    abs(mean_values - medoid_values)
  
  # =======================================================
  # Mean + LOA
  # =======================================================
  
  mean_diff <- mean(differences)
  
  sd_diff <- sd(differences)
  
  upper_loa <- mean_diff + 1.96 * sd_diff
  
  lower_loa <- mean_diff - 1.96 * sd_diff
  
  # =======================================================
  # Regression
  # =======================================================
  
  model <- lm(differences ~ averages)
  
  intercept <- coef(model)[1]
  
  slope <- coef(model)[2]
  
  r2 <- summary(model)$r.squared
  
  r <- cor(
    averages,
    differences
  )
  
  # =======================================================
  # Regression annotation
  # =======================================================
  
  eq_label <- paste0(
    
    "y = ",
    round(slope, 4),
    "x + ",
    round(intercept, 4),
    
    "\nR² = ",
    round(r2, 4),
    
    "\nr = ",
    round(r, 4)
  )
  
  # =======================================================
  # Plot dataframe
  # =======================================================
  
  plot_df <- data.frame(
    
    averages = averages,
    
    differences = differences
  )
  
  # =======================================================
  # Default title
  # =======================================================
  
  if (is.null(plot_title)) {
    
    plot_title <- paste(
      "Bland-Altman Plot:",
      descriptor
    )
  }
  
  # =======================================================
  # Plot
  # =======================================================
  
  p <- ggplot(
    plot_df,
    aes(
      x = averages,
      y = differences
    )
  ) +
    
    # -----------------------------------------------------
  # Scatter points
  # -----------------------------------------------------
  
  geom_point(
    color = point_color,
    size = point_size,
    alpha = point_alpha
  ) +
    
    # -----------------------------------------------------
  # Regression line
  # -----------------------------------------------------
  
  geom_smooth(
    method = "lm",
    se = TRUE,
    color = regression_color,
    linewidth = regression_width
  ) +

    # -----------------------------------------------------
  # Annotation
  # -----------------------------------------------------
  
  annotate(
    "text",
    x = Inf,
    y = Inf,
    label = eq_label,
    hjust = annotation_hjust,
    vjust = annotation_vjust,
    size = annotation_size
  ) +
    
    # -----------------------------------------------------
  # Labels
  # -----------------------------------------------------
  
  labs(
    title = plot_title,
    x = x_label,
    y = y_label
  ) +
    
    # -----------------------------------------------------
  # Theme
  # -----------------------------------------------------
  
  theme_bw(base_size = 14) +
    
    theme(
      
      plot.title = element_text(
        face = "bold",
        hjust = 0.5,
        size = 16
      ),
      
      axis.title = element_text(
        face = "bold",
        size = 13
      ),
      
      axis.text = element_text(
        size = 11
      ),
      
      panel.grid.minor =
        element_blank()
    )
  
  # =======================================================
  # Print
  # =======================================================
  
  print(p)
  
  # =======================================================
  # Save
  # =======================================================
  
  ggsave(
    filename = output_file,
    plot = p,
    width = width,
    height = height,
    dpi = 300
  )
}

# =========================================================
# Example Usage
# =========================================================

plot_bland_altman(input_file ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", descriptor ="MolWt", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/bland_altman_plots/molwt.pdf", point_color = "#4C72B0")
plot_bland_altman(input_file ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", descriptor ="TPSA", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/bland_altman_plots/TPSA.pdf", point_color = "#4C72B0")
plot_bland_altman(input_file ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", descriptor ="LogP", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/bland_altman_plots/LogP.pdf", point_color = "#4C72B0")
plot_bland_altman(input_file ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", descriptor ="AromaticRingCount", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/bland_altman_plots/AromaticRingCount.pdf", point_color = "#4C72B0")
plot_bland_altman(input_file ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", descriptor ="FractionCSP3", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/bland_altman_plots/FCsp3.pdf", point_color = "#4C72B0")
plot_bland_altman(input_file ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", descriptor ="HBD", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/bland_altman_plots/HBD.pdf", point_color = "#4C72B0")
plot_bland_altman(input_file ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", descriptor ="HBA", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/bland_altman_plots/HBA.pdf", point_color = "#4C72B0")
plot_bland_altman(input_file ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", descriptor ="RotatableBonds", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/bland_altman_plots/RotBonds.pdf", point_color = "#4C72B0")
