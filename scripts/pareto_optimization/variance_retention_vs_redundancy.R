# =========================
# Libraries
# =========================
library(dplyr)
library(tidyr)
library(ggplot2)
library(readr)

# =========================
# Function
# =========================

plot_pareto_metrics <- function(
    input_file,
    band_name,
    output_file
) {
  
  # -------------------------
  # Read data
  # -------------------------
  
  df <- read_csv(input_file)
  
  # -------------------------
  # Filter selected band
  # -------------------------
  
  df_band <- df %>%
    filter(band == band_name) %>%
    select(k, variance_fraction, mean_abs_corr)
  
  # -------------------------
  # Reshape
  # -------------------------
  
  df_long <- df_band %>%
    pivot_longer(
      cols = c(
        variance_fraction,
        mean_abs_corr
      ),
      names_to = "metric",
      values_to = "value"
    )
  
  # -------------------------
  # Customization
  # -------------------------
  
  metric_labels <- c(
    variance_fraction = "Variance Retained",
    mean_abs_corr     = "Mean Absolute Correlation"
  )
  
  metric_colors <- c(
    variance_fraction = "#FF69B4",
    mean_abs_corr     = "#C71585"
  )
  
  metric_linetypes <- c(
    variance_fraction = "solid",
    mean_abs_corr     = "dashed"
  )
  
  metric_shapes <- c(
    variance_fraction = 16,
    mean_abs_corr     = 2
  )
  
  # -------------------------
  # Plot
  # -------------------------
  
  p <- ggplot(
    df_long,
    aes(
      x = k,
      y = value,
      color = metric,
      linetype = metric,
      shape = metric,
      group = metric
    )
  ) +
    
    geom_line(size = 0.75) +
    
    geom_point(size = 2) +
    
    scale_x_continuous(
      breaks = c(10, 15, 20, 25)
    ) +
    
    scale_color_manual(
      values = metric_colors,
      labels = metric_labels,
      name = "Metric"
    ) +
    
    scale_linetype_manual(
      values = metric_linetypes,
      labels = metric_labels,
      name = "Metric"
    ) +
    
    scale_shape_manual(
      values = metric_shapes,
      labels = metric_labels,
      name = "Metric"
    ) +
    
    labs(
      title = paste0(
        toupper(band_name),
        ": Variance Retention vs Redundancy"
      ),
      x = "Number of Descriptors (k)",
      y = "Metric Value"
    ) +
    
    theme_bw() +
    
    theme(
      legend.position = "top",
      
      plot.title = element_text(
        hjust = 0.5,
        face = "bold",
        size = 16
      ),
      
      axis.title = element_text(
        size = 10
      ),
      
      axis.text = element_text(
        size = 8
      )
    )
  
  # -------------------------
  # Print
  # -------------------------
  
  print(p)
  
  # -------------------------
  # Save
  # -------------------------
  
  ggsave(
    filename = output_file,
    plot = p,
    width = 6,
    height = 4,
    dpi = 300
  )
}

plot_pareto_metrics(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/pareto_optimization/pareto_df.csv", band_name="band1", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/pareto_optimization/variance_retention_vs_redundancy_band1.pdf")
plot_pareto_metrics(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/pareto_optimization/pareto_df.csv", band_name="band2", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/pareto_optimization/variance_retention_vs_redundancy_band2.pdf")
plot_pareto_metrics(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/pareto_optimization/pareto_df.csv", band_name="band3", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/pareto_optimization/variance_retention_vs_redundancy_band3.pdf")
plot_pareto_metrics(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/pareto_optimization/pareto_df.csv", band_name="band4", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/pareto_optimization/variance_retention_vs_redundancy_band4.pdf")

