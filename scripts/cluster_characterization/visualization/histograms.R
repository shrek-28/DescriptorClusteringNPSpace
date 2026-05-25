library(ggplot2)

# =========================================================
# Generic Histogram Function
# =========================================================

plot_histogram_distribution <- function(
    
  input_file,
  column_name,
  output_file,
  
  # -------------------------
  # Binning
  # -------------------------
  
  binwidth = NA,
  
  # -------------------------
  # Histogram aesthetics
  # -------------------------
  
  fill_color = "#4C72B0",
  border_color = "white",
  fill_alpha = 0.9,
  
  # -------------------------
  # Mean / Median lines
  # -------------------------
  
  mean_line_color = "black",
  median_line_color = "black",
  
  mean_linetype = "dashed",
  median_linetype = "dotted",
  
  line_width = 0.9,
  
  # -------------------------
  # Annotation aesthetics
  # -------------------------
  
  count_text_size = 3,
  stats_text_size = 4,
  
  # -------------------------
  # Labels
  # -------------------------
  
  plot_title = NULL,
  x_label = NULL,
  y_label = "Count",
  
  # -------------------------
  # Figure size
  # -------------------------
  
  width = 10,
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
  # Validate column
  # =======================================================
  
  if (!(column_name %in% colnames(df))) {
    
    stop(
      paste(
        "Column",
        column_name,
        "not found"
      )
    )
  }
  
  # =======================================================
  # Extract numeric vector
  # =======================================================
  
  x <- df[[column_name]]
  
  x <- x[is.finite(x)]
  
  if (!is.numeric(x)) {
    stop("Selected column must be numeric")
  }
  
  n <- length(x)
  
  # =======================================================
  # Statistics
  # =======================================================
  
  mean_x   <- mean(x)
  median_x <- median(x)
  sd_x     <- sd(x)
  var_x    <- var(x)
  
  skewness_x <-
    sum((x - mean_x)^3) /
    (n * sd_x^3)
  
  kurtosis_x <-
    sum((x - mean_x)^4) /
    (n * sd_x^4) - 3
  
  label_text <- paste0(
    "Mean = ", round(mean_x, 3), "\n",
    "Median = ", round(median_x, 3), "\n",
    "SD = ", round(sd_x, 3), "\n",
    "Var = ", round(var_x, 3), "\n",
    "Skew = ", round(skewness_x, 3), "\n",
    "Kurtosis = ", round(kurtosis_x, 3)
  )
  
  # =======================================================
  # Automatic binning
  # =======================================================
  
  xmin <- min(x)
  xmax <- max(x)
  
  if (is.na(binwidth)) {
    
    raw_bw <- (xmax - xmin) / 20
    
    scale_val <- 10^floor(log10(raw_bw))
    
    candidates <- c(1, 2, 5, 10) * scale_val
    
    binwidth <-
      candidates[
        which.min(abs(candidates - raw_bw))
      ]
  }
  
  xmin_clean <-
    floor(xmin / binwidth) * binwidth
  
  xmax_clean <-
    ceiling(xmax / binwidth) * binwidth
  
  bin_edges <-
    seq(
      xmin_clean,
      xmax_clean,
      by = binwidth
    )
  
  # =======================================================
  # Histogram counts
  # =======================================================
  
  counts <- hist(
    x,
    breaks = bin_edges,
    plot = FALSE
  )
  
  count_df <- data.frame(
    mids = counts$mids,
    counts = counts$counts
  )
  
  # =======================================================
  # Save bin table
  # =======================================================
  
  table_file <-
    sub(
      "\\.(png|pdf|jpg|jpeg)$",
      "_bin_table.csv",
      output_file
    )
  
  write.csv(
    
    data.frame(
      lower  = bin_edges[-length(bin_edges)],
      upper  = bin_edges[-1],
      counts = counts$counts
    ),
    
    table_file,
    row.names = FALSE
  )
  
  # =======================================================
  # Default labels
  # =======================================================
  
  if (is.null(plot_title)) {
    
    plot_title <-
      paste(
        "Distribution of",
        column_name
      )
  }
  
  if (is.null(x_label)) {
    x_label <- column_name
  }
  
  # =======================================================
  # Plot
  # =======================================================
  
  p <- ggplot(
    data.frame(x = x),
    aes(x = x)
  ) +
    
    geom_histogram(
      
      aes(y = after_stat(count)),
      
      breaks = bin_edges,
      
      fill = fill_color,
      color = border_color,
      alpha = fill_alpha
    ) +
    
    # -------------------------
  # Mean line
  # -------------------------
  
  geom_vline(
    aes(
      xintercept = mean_x,
      linetype = "Mean"
    ),
    color = mean_line_color,
    linewidth = line_width
  ) +
    
    # -------------------------
  # Median line
  # -------------------------
  
  geom_vline(
    aes(
      xintercept = median_x,
      linetype = "Median"
    ),
    color = median_line_color,
    linewidth = line_width
  ) +
    
    # -------------------------
  # Linetype legend
  # -------------------------
  
  scale_linetype_manual(
    name = "Statistics",
    values = c(
      "Mean" = mean_linetype,
      "Median" = median_linetype
    )
  ) +
    
    # -------------------------
  # Count labels
  # -------------------------
  
  geom_text(
    data = count_df,
    
    aes(
      x = mids,
      y = counts,
      label = counts
    ),
    
    vjust = -0.3,
    size = count_text_size
  ) +
    
    # -------------------------
  # Statistics textbox
  # -------------------------
  
  annotate(
    "text",
    
    x = Inf,
    y = Inf,
    
    label = label_text,
    
    hjust = 1.1,
    vjust = 1.1,
    
    size = stats_text_size
  ) +
    
    # -------------------------
  # Labels
  # -------------------------
  
  labs(
    title = plot_title,
    x = x_label,
    y = y_label
  ) +
    
    coord_cartesian(
      clip = "off"
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
      
      panel.grid.minor = element_blank(),
      
      legend.position = "top"
    )
  
  # =======================================================
  # Print
  # =======================================================
  
  print(p)
  
  # =======================================================
  # Save plot
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
plot_histogram_distribution(input_file ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/core_frac_classification.csv", column_name="core_size", output_file ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/histograms/core_size_histogram.pdf", binwidth = 25, fill_color = "#06402B", mean_line_color = "darkred", median_line_color = "black")
plot_histogram_distribution(input_file ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/core_frac_classification.csv", column_name="post_noise_size", output_file ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/histograms/post_noise_size_histogram.pdf", binwidth = 100, fill_color = "#06402B", mean_line_color = "darkred", median_line_color = "black")
plot_histogram_distribution(input_file ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/core_frac_classification.csv", column_name="core_fraction", output_file ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/histograms/core_fraction_histogram.pdf", binwidth = 0.05, fill_color = "#06402B", mean_line_color = "darkred", median_line_color = "black")
plot_histogram_distribution(input_file ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/core_frac_classification.csv", column_name="prob_IQR", output_file ="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/histograms/prob_IQR_histogram.pdf", binwidth = 0.05, fill_color = "#06402B", mean_line_color = "darkred", median_line_color = "black")

# cluster structural metrics
plot_histogram_distribution(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_structural_metrics_12D_full.csv", column_name="density_gradient", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/histograms/density_gradient_histogram.pdf", binwidth = 0.05, fill_color = "#06402B", mean_line_color = "darkred", median_line_color = "black")

# cluster similarity validation 
plot_histogram_distribution(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_similarity_validation.csv", column_name="separation_ratio", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/histograms/separation_ratio_histogram.pdf", binwidth = 0.5, fill_color = "#06402B", mean_line_color = "darkred", median_line_color = "black")

# cluster probability stats
plot_histogram_distribution(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_probability_stats.csv", column_name="mean_probability", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/histograms/mean_probability_histogram.pdf", binwidth = 0.05, fill_color = "#06402B", mean_line_color = "darkred", median_line_color = "black")
plot_histogram_distribution(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_probability_stats.csv", column_name="variance_probability", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/histograms/variance_probability_histogram.pdf", binwidth = 0.01, fill_color = "#06402B", mean_line_color = "darkred", median_line_color = "black")

# chemical profile 
plot_histogram_distribution(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", column_name="dominant_scaffold_fraction", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/histograms/dom_scaf_frac_histogram.pdf", binwidth = 0.05, fill_color = "#06402B", mean_line_color = "darkred", median_line_color = "black")

## descriptor means 
plot_histogram_distribution(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", column_name="MolWt_mean", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/histograms/molwt_mean_histogram.pdf", binwidth = 100, fill_color = "#06402B", mean_line_color = "darkred", median_line_color = "black")
plot_histogram_distribution(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", column_name="LogP_mean", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/histograms/logp_mean_histogram.pdf", binwidth = 2, fill_color = "#06402B", mean_line_color = "darkred", median_line_color = "black")
plot_histogram_distribution(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", column_name="AromaticRingCount_mean", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/histograms/aromaticringcount_mean_histogram.pdf", binwidth = 1, fill_color = "#06402B", mean_line_color = "darkred", median_line_color = "black")
plot_histogram_distribution(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", column_name="FractionCSP3_mean", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/histograms/fcsp3_mean_histogram.pdf", binwidth = 0.05, fill_color = "#06402B", mean_line_color = "darkred", median_line_color = "black")
plot_histogram_distribution(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", column_name="TPSA_mean", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/histograms/tpsa_mean_histogram.pdf", binwidth = 100, fill_color = "#06402B", mean_line_color = "darkred", median_line_color = "black")
plot_histogram_distribution(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", column_name="HBD_mean", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/histograms/hbd_mean_histogram.pdf", binwidth = 2, fill_color = "#06402B", mean_line_color = "darkred", median_line_color = "black")
plot_histogram_distribution(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", column_name="HBA_mean", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/histograms/hba_mean_histogram.pdf", binwidth = 2, fill_color = "#06402B", mean_line_color = "darkred", median_line_color = "black")
plot_histogram_distribution(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/cluster_profiling/cluster_full_chemical_profile.csv", column_name="RotatableBonds_mean", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/cluster_profile_analysis/histograms/rot_bonds_mean_histogram.pdf", binwidth = 5, fill_color = "#06402B", mean_line_color = "darkred", median_line_color = "black")
