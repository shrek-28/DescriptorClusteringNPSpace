library(ggplot2)

# =========================================================
# Generic Scatter Plot Function
# =========================================================

plot_scatter_regression <- function(
    
  input_file,
  x_col,
  y_col,
  output_file,
  
  # -------------------------
  # Point aesthetics
  # -------------------------
  
  point_color = "pink",
  point_alpha = 0.7,
  point_size = 1,
  
  # -------------------------
  # Regression aesthetics
  # -------------------------
  
  regression_color = "#DD8452",
  regression_width = 1,
  show_confidence_interval = TRUE,
  
  # -------------------------
  # Labels
  # -------------------------
  
  plot_title = NULL,
  x_label = NULL,
  y_label = NULL,
  
  # -------------------------
  # Annotation settings
  # -------------------------
  
  annotation_size = 4,
  annotation_hjust = 1.1,
  annotation_vjust = -0.5,
  
  # -------------------------
  # Figure size
  # -------------------------
  
  width = 8,
  height = 6
) {
  
  # =======================================================
  # Read data
  # =======================================================
  
  df <- read.csv(
    input_file,
    stringsAsFactors = FALSE
  )
  
  # =======================================================
  # Validate columns
  # =======================================================
  
  if (!(x_col %in% colnames(df))) {
    stop(paste(x_col, "not found"))
  }
  
  if (!(y_col %in% colnames(df))) {
    stop(paste(y_col, "not found"))
  }
  
  # =======================================================
  # Extract columns
  # =======================================================
  
  x <- df[[x_col]]
  y <- df[[y_col]]
  
  # =======================================================
  # Remove invalid values
  # =======================================================
  
  valid <- is.finite(x) & is.finite(y)
  
  x <- x[valid]
  y <- y[valid]
  
  # =======================================================
  # Numeric validation
  # =======================================================
  
  if (!is.numeric(x) || !is.numeric(y)) {
    stop("Both columns must be numeric")
  }
  
  # =======================================================
  # Regression
  # =======================================================
  
  model <- lm(y ~ x)
  
  intercept <- coef(model)[1]
  slope     <- coef(model)[2]
  
  r2 <- summary(model)$r.squared
  r  <- cor(x, y)
  
  eq_label <- paste0(
    "y = ",
    round(slope, 3),
    "x + ",
    round(intercept, 3),
    "\nR² = ",
    round(r2, 3),
    "\nr = ",
    round(r, 3)
  )
  
  # =======================================================
  # Plot dataframe
  # =======================================================
  
  plot_df <- data.frame(
    x = x,
    y = y
  )
  
  # =======================================================
  # Default labels
  # =======================================================
  
  if (is.null(plot_title)) {
    plot_title <- paste(x_col, "vs", y_col)
  }
  
  if (is.null(x_label)) {
    x_label <- x_col
  }
  
  if (is.null(y_label)) {
    y_label <- y_col
  }
  
  # =======================================================
  # Plot
  # =======================================================
  
  p <- ggplot(
    plot_df,
    aes(
      x = x,
      y = y
    )
  ) +
    
    geom_point(
      color = point_color,
      alpha = point_alpha,
      size = point_size
    ) +
    
    geom_smooth(
      method = "lm",
      se = show_confidence_interval,
      color = regression_color,
      linewidth = regression_width
    ) +
    
    annotate(
      "text",
      x = Inf,
      y = -Inf,
      label = eq_label,
      hjust = annotation_hjust,
      vjust = annotation_vjust,
      size = annotation_size
    ) +
    
    labs(
      title = plot_title,
      x = x_label,
      y = y_label
    ) +
    
    theme_minimal(base_size = 14) +
    
    theme(
      plot.title = element_text(
        face = "bold",
        hjust = 0.5
      ),
      
      axis.title = element_text(
        face = "bold"
      ),
      
      panel.grid.minor = element_blank()
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

# core frac classification
plot_scatter_regression(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/core_frac_classification.csv", x_col ="post_noise_size", y_col ="core_size", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/core_vs_post_noise_size_scatterplot.pdf", point_color = "#FF69B4", regression_color ="#DD8452")

# structural metrics 12D full
plot_scatter_regression(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_structural_metrics_12D_full.csv", x_col ="std_distance_post", y_col ="mean_distance_post", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/mean_vs_std_dist_post_scatterplot.pdf", point_color = "#FF69B4", regression_color ="#DD8452")
plot_scatter_regression(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_structural_metrics_12D_full.csv", x_col ="mean_distance_post", y_col ="mean_distance_core", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/mean_dist_core_vs_mean_dist_post_scatterplot.pdf", point_color = "#FF69B4", regression_color ="#DD8452")
plot_scatter_regression(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_structural_metrics_12D_full.csv", x_col ="covariance_volume", y_col ="mean_distance_post", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/mean_dist_post_vs_cov_vol_scatterplot.pdf", point_color = "#FF69B4", regression_color ="#DD8452")
plot_scatter_regression(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_structural_metrics_12D_full.csv", x_col ="medoid_centroid_distance", y_col ="mean_distance_post", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/mean_dist_post_vs_medoid_centroid_dist_scatterplot.pdf", point_color = "#FF69B4", regression_color ="#DD8452")

# cluster similarity validation 
plot_scatter_regression(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_similarity_validation.csv", x_col ="mean_between_medoid_similarity", y_col ="mean_within_similarity", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/mean_wi_sim_vs_mean_bw_medoid_sim_scatterplot.pdf", point_color = "#FF69B4", regression_color ="#DD8452")
plot_scatter_regression(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_similarity_validation.csv", x_col ="mean_within_similarity", y_col ="separation_ratio", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/sep_ratio_vs_mean_wi_sim_scatterplot.pdf", point_color = "#FF69B4", regression_color ="#DD8452")

# cluster probability stats
plot_scatter_regression(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_probability_stats.csv", x_col ="mean_probability", y_col ="variance_probability", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/var_vs_mean_prob_scatterplot.pdf", point_color = "#FF69B4", regression_color ="#DD8452")
plot_scatter_regression(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_probability_stats.csv", x_col ="mean_probability", y_col ="IQR_probability", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/IQR_vs_mean_prob_scatterplot.pdf", point_color = "#FF69B4", regression_color ="#DD8452")

# chemical profile 
plot_scatter_regression(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", x_col ="LogP_mean", y_col ="TPSA_mean", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/TPSA_vs_LogP_mean_scatterplot.pdf", point_color = "#FF69B4", regression_color ="#DD8452")
plot_scatter_regression(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", x_col ="MolWt_mean", y_col ="LogP_mean", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/LogP_vs_MolWt_mean_scatterplot.pdf", point_color = "#FF69B4", regression_color ="#DD8452")
plot_scatter_regression(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", x_col ="FractionCSP3_mean", y_col ="LogP_mean", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/FracCSP3_vs_LogP_mean_scatterplot.pdf", point_color = "#FF69B4", regression_color ="#DD8452")

plot_scatter_regression(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", x_col ="MolWt_mean", y_col ="medoid_MolWt", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/Mean_vs_Medoid_MolWt_scatterplot.pdf", point_color = "#FF69B4", regression_color ="#DD8452")
plot_scatter_regression(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", x_col ="TPSA_mean", y_col ="medoid_TPSA", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/Mean_vs_Medoid_TPSA_scatterplot.pdf", point_color = "#FF69B4", regression_color ="#DD8452")
plot_scatter_regression(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", x_col ="LogP_mean", y_col ="medoid_LogP", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/Mean_vs_Medoid_LogP_scatterplot.pdf", point_color = "#FF69B4", regression_color ="#DD8452")
plot_scatter_regression(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", x_col ="AromaticRingCount_mean", y_col ="medoid_AromaticRingCount", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/Mean_vs_Medoid_AromaticRingCount_scatterplot.pdf", point_color = "#FF69B4", regression_color ="#DD8452")
plot_scatter_regression(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", x_col ="FractionCSP3_mean", y_col ="medoid_FractionCSP3", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/Mean_vs_Medoid_FCSP3_scatterplot.pdf", point_color = "#FF69B4", regression_color ="#DD8452")
plot_scatter_regression(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", x_col ="HBD_mean", y_col ="medoid_HBD", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/Mean_vs_Medoid_HBD_scatterplot.pdf", point_color = "#FF69B4", regression_color ="#DD8452")
plot_scatter_regression(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", x_col ="HBA_mean", y_col ="medoid_HBA", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/Mean_vs_Medoid_HBA_scatterplot.pdf", point_color = "#FF69B4", regression_color ="#DD8452")
plot_scatter_regression(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", x_col ="RotatableBonds_mean", y_col ="medoid_RotatableBonds", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/Mean_vs_Medoid_RotBonds_scatterplot.pdf", point_color = "#FF69B4", regression_color ="#DD8452")
