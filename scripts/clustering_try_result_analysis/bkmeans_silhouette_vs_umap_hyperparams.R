# =========================
# Libraries
# =========================
library(readr)
library(dplyr)
library(ggplot2)
library(patchwork)

# =========================
# Generic Heatmap Function
# =========================

create_heatmap <- function(
    
  df,
  
  x_col,
  y_col,
  metric_col,
  
  plot_title,
  
  low_color = "white",
  high_color = "#440154",
  
  annotation_size = 3.5,
  title_size = 14,
  axis_size = 11
) {
  
  # -------------------------
  # Aggregate values
  # -------------------------
  
  heatmap_df <- df %>%
    group_by(
      .data[[y_col]],
      .data[[x_col]]
    ) %>%
    summarise(
      value = mean(.data[[metric_col]], na.rm = TRUE),
      .groups = "drop"
    )
  
  # -------------------------
  # Plot
  # -------------------------
  
  p <- ggplot(
    heatmap_df,
    aes(
      x = factor(.data[[x_col]]),
      y = factor(.data[[y_col]]),
      fill = value
    )
  ) +
    
    geom_tile(
      color = "gray",
      linewidth = 0.5
    ) +
    
    geom_text(
      aes(label = sprintf("%.3f", value)),
      size = annotation_size
    ) +
    
    scale_fill_gradient(
      low = low_color,
      high = high_color,
      name = metric_col
    ) +
    
    labs(
      title = plot_title,
      x = gsub("_", " ", x_col),
      y = gsub("_", " ", y_col)
    ) +
    
    theme_bw() +
    
    theme(
      plot.title = element_text(
        face = "bold",
        hjust = 0.5,
        size = title_size
      ),
      
      axis.title = element_text(
        size = axis_size
      ),
      
      axis.text = element_text(
        size = axis_size - 1
      )
    )
  
  return(p)
}

# =========================
# Main Wrapper Function
# =========================

plot_umap_hyperparameter_heatmaps <- function(
    
  input_file,
  output_file,
  
  metric_col = "silhouette",
  
  # -------------------------
  # Colors
  # -------------------------
  
  low_color = "white",
  high_color = "#440154",
  
  # -------------------------
  # Figure size
  # -------------------------
  
  width = 16,
  height = 12
) {
  
  # =========================
  # Read data
  # =========================
  
  df <- read_csv(input_file)
  
  # =====================================================
  # Heatmap 1
  # neighbors × components
  # =====================================================
  
  p1 <- create_heatmap(
    
    df = df,
    
    x_col = "UMAP_n_neighbors",
    y_col = "UMAP_n_components",
    
    metric_col = metric_col,
    
    plot_title =
      "n_neighbors × n_components",
    
    low_color = low_color,
    high_color = high_color
  )
  
  # =====================================================
  # Heatmap 2
  # neighbors × min_dist
  # =====================================================
  
  p2 <- create_heatmap(
    
    df = df,
    
    x_col = "UMAP_n_neighbors",
    y_col = "UMAP_min_dist",
    
    metric_col = metric_col,
    
    plot_title =
      "n_neighbors × min_dist",
    
    low_color = low_color,
    high_color = high_color
  )
  
  # =====================================================
  # Heatmap 3
  # components × min_dist
  # =====================================================
  
  p3 <- create_heatmap(
    
    df = df,
    
    x_col = "UMAP_n_components",
    y_col = "UMAP_min_dist",
    
    metric_col = metric_col,
    
    plot_title =
      "n_components × min_dist",
    
    low_color = low_color,
    high_color = high_color
  )
  
  # =====================================================
  # Heatmap 4
  # metric × neighbors
  # =====================================================
  
  p4 <- create_heatmap(
    
    df = df,
    
    x_col = "UMAP_n_neighbors",
    y_col = "UMAP_metric",
    
    metric_col = metric_col,
    
    plot_title =
      "metric × n_neighbors",
    
    low_color = low_color,
    high_color = high_color
  )
  
  # =====================================================
  # Combine plots
  # =====================================================
  
  combined_plot <-
    (p1 | p2) /
    (p3 | p4) +
    
    plot_annotation(
      title =
        "Silhouette Score Variation across UMAP Hyperparameters"
    )
  
  # =====================================================
  # Print
  # =====================================================
  
  print(combined_plot)
  
  # =====================================================
  # Save
  # =====================================================
  
  ggsave(
    filename = output_file,
    plot = combined_plot,
    width = width,
    height = height,
    dpi = 300
  )
}

# =========================
# Example Usage
# =========================

plot_umap_hyperparameter_heatmaps(
  
  input_file =
    "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/clustering_try_results/umap_bkmeans/umap_bisecting_results.csv",
  
  output_file =
    "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/clustering_try_result_analysis/umap_bkmeans/bkmeans_silhouette_vs_umap_hyperparams.pdf",
  
  metric_col = "silhouette",
  
  low_color = "white",
  high_color = "#06402B"
)