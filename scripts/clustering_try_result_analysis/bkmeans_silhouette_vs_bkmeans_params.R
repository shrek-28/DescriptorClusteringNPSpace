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

plot_bkmeans_heatmaps <- function(
    
  input_file,
  output_file,
  
  # -------------------------
  # Metrics
  # -------------------------
  
  silhouette_metric = "silhouette",
  dbi_metric = "dbi",
  
  # -------------------------
  # Titles
  # -------------------------
  
  overall_title =
    "Silhouette Score Variation across Bisecting KMeans Hyperparameters",
  
  # -------------------------
  # Color palettes
  # -------------------------
  
  cmap1_low = "white",
  cmap1_high = "#B63679",
  
  cmap2_low = "white",
  cmap2_high = "#8C2981",
  
  cmap3_low = "white",
  cmap3_high = "#F1605D",
  
  cmap4_low = "white",
  cmap4_high = "#FCFFA4",
  
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
  
  # =====================================================
  # Heatmap 1
  # Silhouette: n_clusters × max_iter
  # =====================================================
  
  hm1_df <- df %>%
    group_by(
      BKMeans_max_iter,
      BKMeans_n_clusters
    ) %>%
    summarise(
      value = mean(.data[[silhouette_metric]], na.rm = TRUE),
      .groups = "drop"
    )
  
  p1 <- ggplot(
    hm1_df,
    aes(
      x = factor(BKMeans_n_clusters),
      y = factor(BKMeans_max_iter),
      fill = value
    )
  ) +
    
    geom_tile(color = "gray") +
    
    geom_text(
      aes(label = sprintf("%.3f", value)),
      size = annotation_size
    ) +
    
    scale_fill_gradient(
      low = cmap1_low,
      high = cmap1_high,
      name = silhouette_metric
    ) +
    
    labs(
      title = "Silhouette: n_clusters × max_iter",
      x = "BKMeans n_clusters",
      y = "BKMeans max_iter"
    ) +
    
    theme_bw() +
    
    theme(
      plot.title = element_text(
        face = "bold",
        hjust = 0.5,
        size = title_size
      ),
      
      axis.title = element_text(size = axis_size),
      
      axis.text = element_text(size = axis_size - 1)
    )
  
  # =====================================================
  # Heatmap 2
  # Silhouette: n_clusters × init
  # =====================================================
  
  hm2_df <- df %>%
    group_by(
      BKMeans_init,
      BKMeans_n_clusters
    ) %>%
    summarise(
      value = mean(.data[[silhouette_metric]], na.rm = TRUE),
      .groups = "drop"
    )
  
  p2 <- ggplot(
    hm2_df,
    aes(
      x = factor(BKMeans_n_clusters),
      y = factor(BKMeans_init),
      fill = value
    )
  ) +
    
    geom_tile(color = "gray") +
    
    geom_text(
      aes(label = sprintf("%.3f", value)),
      size = annotation_size
    ) +
    
    scale_fill_gradient(
      low = cmap2_low,
      high = cmap2_high,
      name = silhouette_metric
    ) +
    
    labs(
      title = "Silhouette: n_clusters × init",
      x = "BKMeans n_clusters",
      y = "BKMeans init"
    ) +
    
    theme_bw() +
    
    theme(
      plot.title = element_text(
        face = "bold",
        hjust = 0.5,
        size = title_size
      ),
      
      axis.title = element_text(size = axis_size),
      
      axis.text = element_text(size = axis_size - 1)
    )
  
  # =====================================================
  # Heatmap 3
  # DBI: n_clusters × bisecting_strategy
  # =====================================================
  
  hm3_df <- df %>%
    group_by(
      BKMeans_bisecting_strategy,
      BKMeans_n_clusters
    ) %>%
    summarise(
      value = mean(.data[[dbi_metric]], na.rm = TRUE),
      .groups = "drop"
    )
  
  p3 <- ggplot(
    hm3_df,
    aes(
      x = factor(BKMeans_n_clusters),
      y = factor(BKMeans_bisecting_strategy),
      fill = value
    )
  ) +
    
    geom_tile(color = "gray") +
    
    geom_text(
      aes(label = sprintf("%.3f", value)),
      size = annotation_size
    ) +
    
    scale_fill_gradient(
      low = cmap3_low,
      high = cmap3_high,
      name = dbi_metric
    ) +
    
    labs(
      title = "DBI: n_clusters × bisecting_strategy",
      x = "BKMeans n_clusters",
      y = "Bisecting Strategy"
    ) +
    
    theme_bw() +
    
    theme(
      plot.title = element_text(
        face = "bold",
        hjust = 0.5,
        size = title_size
      ),
      
      axis.title = element_text(size = axis_size),
      
      axis.text = element_text(size = axis_size - 1)
    )
  
  # =====================================================
  # Heatmap 4
  # Silhouette: init × bisecting_strategy
  # =====================================================
  
  hm4_df <- df %>%
    group_by(
      BKMeans_bisecting_strategy,
      BKMeans_init
    ) %>%
    summarise(
      value = mean(.data[[silhouette_metric]], na.rm = TRUE),
      .groups = "drop"
    )
  
  p4 <- ggplot(
    hm4_df,
    aes(
      x = factor(BKMeans_init),
      y = factor(BKMeans_bisecting_strategy),
      fill = value
    )
  ) +
    
    geom_tile(color = "gray") +
    
    geom_text(
      aes(label = sprintf("%.3f", value)),
      size = annotation_size
    ) +
    
    scale_fill_gradient(
      low = cmap4_low,
      high = cmap4_high,
      name = silhouette_metric
    ) +
    
    labs(
      title = "Silhouette: init × bisecting_strategy",
      x = "BKMeans init",
      y = "Bisecting Strategy"
    ) +
    
    theme_bw() +
    
    theme(
      plot.title = element_text(
        face = "bold",
        hjust = 0.5,
        size = title_size
      ),
      
      axis.title = element_text(size = axis_size),
      
      axis.text = element_text(size = axis_size - 1)
    )
  
  # =====================================================
  # Combine plots
  # =====================================================
  
  combined_plot <-
    (p1 | p2) /
    (p3 | p4) +
    
    plot_annotation(
      title = overall_title
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

plot_bkmeans_heatmaps(
  
  input_file =
    "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/clustering_try_results/umap_bkmeans/umap_bisecting_results.csv",
  
  output_file =
    "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/clustering_try_result_analysis/umap_bkmeans/bkmeans_silhouette_vs_bkmeans_params.pdf"
)