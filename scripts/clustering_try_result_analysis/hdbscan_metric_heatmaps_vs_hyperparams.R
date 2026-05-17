# =========================
# Libraries
# =========================
library(readr)
library(dplyr)
library(ggplot2)
library(patchwork)

# =========================
# Function
# =========================

plot_metric_heatmaps <- function(
    
  input_file,
  output_file,
  
  # -------------------------
  # Hyperparameter axes
  # -------------------------
  
  x_param = "hdbscan_min_cluster_size",
  y_param = "umap_n_neighbors",
  
  # -------------------------
  # Metrics
  # -------------------------
  
  metrics = c(
    "silhouette",
    "dbi",
    "purity",
    "dunn"
  ),
  
  metric_titles = c(
    "Silhouette Score",
    "Davies-Bouldin Index",
    "Purity Score",
    "Dunn Index"
  ),
  
  # -------------------------
  # Color palettes
  # -------------------------
  
  fill_colors = c(
    "#440154",
    "#31688E",
    "#35B779",
    "#FDE725"
  ),
  
  low_color = "white",
  
  # -------------------------
  # Text sizes
  # -------------------------
  
  title_size = 14,
  axis_size = 11,
  annotation_size = 3.5,
  
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
  
  # =========================
  # Store plots
  # =========================
  
  plot_list <- list()
  
  # =========================
  # Generate heatmaps
  # =========================
  
  for (i in seq_along(metrics)) {
    
    metric <- metrics[i]
    metric_title <- metric_titles[i]
    high_color <- fill_colors[i]
    
    # -------------------------
    # Aggregate values
    # -------------------------
    
    heatmap_df <- df %>%
      group_by(
        .data[[y_param]],
        .data[[x_param]]
      ) %>%
      summarise(
        value = mean(.data[[metric]], na.rm = TRUE),
        .groups = "drop"
      )
    
    # -------------------------
    # Plot
    # -------------------------
    
    p <- ggplot(
      heatmap_df,
      aes(
        x = factor(.data[[x_param]]),
        y = factor(.data[[y_param]]),
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
        name = metric
      ) +
      
      labs(
        title = metric_title,
        x = gsub("_", " ", tools::toTitleCase(x_param)),
        y = gsub("_", " ", tools::toTitleCase(y_param))
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
        ),
        
        legend.position = "right"
      )
    
    plot_list[[i]] <- p
  }
  
  # =========================
  # Combine plots
  # =========================
  
  combined_plot <-
    (plot_list[[1]] | plot_list[[2]]) /
    (plot_list[[3]] | plot_list[[4]]) +
    
    plot_annotation(
      title = "Metric Heatmaps Across Hyperparameter Combinations"
    )
  
  # =========================
  # Print
  # =========================
  
  print(combined_plot)
  
  # =========================
  # Save
  # =========================
  
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

plot_metric_heatmaps(
  
  input_file =
    "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/clustering_try_results/umap_hdbscan/results_db_umap_hdbscan.csv",
  
  output_file =
    "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/clustering_try_result_analysis/umap_hdbscan/metric_heatmaps_vs_hyperparams.pdf",
  
  fill_colors = c(
    "#440154",
    "#B12A90",
    "#1F968B",
    "#FDE725"
  )
)