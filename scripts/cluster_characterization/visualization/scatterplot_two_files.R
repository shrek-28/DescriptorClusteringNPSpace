library(ggplot2)

# =========================================================
# Generic Scatter Regression Function
# For Two Separate Files
# =========================================================

plot_merged_scatter_regression <- function(
    
  file1,
  file2,
  
  x_col,
  y_col,
  
  index1,
  index2,
  
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
  # Read files
  # =======================================================
  
  df1 <- read.csv(
    file1,
    stringsAsFactors = FALSE
  )
  
  df2 <- read.csv(
    file2,
    stringsAsFactors = FALSE
  )
  
  # =======================================================
  # Validate columns
  # =======================================================
  
  if (!(x_col %in% colnames(df1))) {
    stop(paste(x_col, "not found in file1"))
  }
  
  if (!(y_col %in% colnames(df2))) {
    stop(paste(y_col, "not found in file2"))
  }
  
  if (!(index1 %in% colnames(df1))) {
    stop(paste(index1, "not found in file1"))
  }
  
  if (!(index2 %in% colnames(df2))) {
    stop(paste(index2, "not found in file2"))
  }
  
  # =======================================================
  # Merge datasets
  # =======================================================
  
  merged <- merge(
    df1,
    df2,
    by.x = index1,
    by.y = index2
  )
  
  # =======================================================
  # Extract variables
  # =======================================================
  
  x <- merged[[x_col]]
  y <- merged[[y_col]]
  
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

# mean prob vs core frac
plot_merged_scatter_regression(file1 ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_probability_stats.csv",file2 ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/core_frac_classification.csv", x_col ="mean_probability", y_col ="core_fraction", index1 = "cluster_core", index2 ="cluster_core", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/two_file_plots/mean_prob_vs_core_frac.pdf", point_color = "#FF69B4", regression_color = "#DD8452")

# density gradient vs core frac
plot_merged_scatter_regression(file1 ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_structural_metrics_12D_full.csv",file2 ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/core_frac_classification.csv", x_col ="density_gradient", y_col ="core_fraction", index1 = "cluster_id", index2 ="cluster_core", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/two_file_plots/density_grad_vs_mean_prob.pdf", point_color = "#FF69B4", regression_color = "#DD8452")

# dominant scaffold fraction plots
plot_merged_scatter_regression(file1 ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv",file2 ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_similarity_validation.csv", x_col ="dominant_scaffold_fraction", y_col ="separation_ratio", index1 = "cluster_id", index2 ="cluster_id", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/two_file_plots/dom_scaf_frac_vs_sep_ratio.pdf", point_color = "#FF69B4", regression_color = "#DD8452")
plot_merged_scatter_regression(file1 ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv",file2 ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_probability_stats.csv", x_col ="dominant_scaffold_fraction", y_col ="variance_probability", index1 = "cluster_id", index2 ="cluster_core", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/two_file_plots/dom_scaf_frac_vs_var_prob.pdf", point_color = "#FF69B4", regression_color = "#DD8452")
plot_merged_scatter_regression(file1 ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv",file2 ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_probability_stats.csv", x_col ="dominant_scaffold_fraction", y_col ="mean_probability", index1 = "cluster_id", index2 ="cluster_core", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/scatterplots/two_file_plots/dom_scaf_frac_vs_mean_prob.pdf", point_color = "#FF69B4", regression_color = "#DD8452")


