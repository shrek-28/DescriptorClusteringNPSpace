# =========================
# Libraries
# =========================
library(readr)
library(ggplot2)

# =========================
# Function
# =========================

plot_silhouette_vs_clusters <- function(
    
  input_file,
  output_file,
  
  # -------------------------
  # Column names
  # -------------------------
  
  x_col = "clusters",
  y_col = "silhouette",
  color_col = "purity",
  
  # -------------------------
  # Labels
  # -------------------------
  
  plot_title =
    "Silhouette Score vs Number of Clusters",
  
  x_label = "Number of Clusters",
  y_label = "Silhouette Score",
  color_label = "Cluster Purity",
  
  # -------------------------
  # Point aesthetics
  # -------------------------
  
  point_size = 2,
  point_alpha = 0.8,
  point_shape = 21,
  border_color = "black",
  border_width = 0.3,
  
  # -------------------------
  # Color gradient
  # -------------------------
  
  low_color = "#440154",
  high_color = "#FDE725",
  
  # -------------------------
  # Theme
  # -------------------------
  
  base_size = 14,
  
  # -------------------------
  # Figure size
  # -------------------------
  
  width = 7,
  height = 5
) {
  
  # =========================
  # Read data
  # =========================
  
  df <- read_csv(input_file)
  
  # =========================
  # Plot
  # =========================
  
  p <- ggplot(
    df,
    aes(
      x = .data[[x_col]],
      y = .data[[y_col]],
      fill = .data[[color_col]]
    )
  ) +
    
    # -------------------------
  # Scatter points
  # -------------------------
  
  geom_point(
    shape = point_shape,
    size = point_size,
    alpha = point_alpha,
    color = border_color,
    stroke = border_width
  ) +
    
    # -------------------------
  # Color gradient
  # -------------------------
  
  scale_fill_gradient(
    low = low_color,
    high = high_color,
    name = color_label
  ) +
    
    # -------------------------
  # Labels
  # -------------------------
  
  labs(
    title = plot_title,
    x = x_label,
    y = y_label
  ) +
    
    # -------------------------
  # Theme
  # -------------------------
  
  theme_bw(base_size = base_size) +
    
    theme(
      plot.title = element_text(
        face = "bold",
        hjust = 0.5,
        size = 16
      ),
      
      axis.title = element_text(
        size = 14
      ),
      
      axis.text = element_text(
        size = 12
      ),
      
      legend.position = "right"
    )
  
  # =========================
  # Print
  # =========================
  
  print(p)
  
  # =========================
  # Save
  # =========================
  
  ggsave(
    filename = output_file,
    plot = p,
    width = width,
    height = height,
    dpi = 300
  )
}

# =========================
# Example Usage
# =========================

plot_silhouette_vs_clusters(
  
  input_file =
    "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/clustering_try_results/umap_hdbscan/results_db_umap_hdbscan.csv",
  
  output_file =
    "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/clustering_try_result_analysis/umap_hdbscan/sil_scores_vs_no_of_clusters.pdf",
  
  low_color = "#440154",
  high_color = "#21908C"
)