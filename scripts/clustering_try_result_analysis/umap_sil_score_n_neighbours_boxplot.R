# =========================
# Libraries
# =========================
library(readr)
library(dplyr)
library(ggplot2)
library(RColorBrewer)

# =========================
# Function
# =========================

plot_metric_distribution <- function(
    
  input_file,
  output_file,
  
  # -------------------------
  # Variables
  # -------------------------
  
  x_col = "umap_n_neighbors",
  y_col = "silhouette",
  
  # -------------------------
  # Labels
  # -------------------------
  
  plot_title =
    "Distribution of Silhouette Scores Across UMAP n_neighbors",
  
  x_label = "UMAP n_neighbors",
  y_label = "Silhouette Score",
  
  # -------------------------
  # Colors
  # -------------------------
  
  palette_name = "Spectral",
  strip_color = "darkblue",
  median_color = "darkred",
  mean_fill = "gold",
  mean_border = "black",
  
  # -------------------------
  # Boxplot aesthetics
  # -------------------------
  
  box_alpha = 0.7,
  strip_size = 2.5,
  strip_alpha = 0.7,
  
  # -------------------------
  # Annotation settings
  # -------------------------
  
  annotation_size = 3,
  annotation_spacing = 0.04,
  annotation_padding = 0.05,
  
  # -------------------------
  # Figure size
  # -------------------------
  
  width = 12,
  height = 8
) {
  
  # =========================
  # Read data
  # =========================
  
  df <- read_csv(input_file)
  
  # =========================
  # Generate palette
  # =========================
  
  n_groups <- length(unique(df[[x_col]]))
  
  palette_colors <- colorRampPalette(
    brewer.pal(11, palette_name)
  )(n_groups)
  
  # =========================
  # Compute statistics
  # =========================
  
  stats_df <- df %>%
    group_by(.data[[x_col]]) %>%
    summarise(
      Mean   = mean(.data[[y_col]], na.rm = TRUE),
      Q1     = quantile(.data[[y_col]], 0.25, na.rm = TRUE),
      Median = median(.data[[y_col]], na.rm = TRUE),
      Q3     = quantile(.data[[y_col]], 0.75, na.rm = TRUE),
      Max    = max(.data[[y_col]], na.rm = TRUE),
      .groups = "drop"
    )
  
  # =========================
  # Convert stats to long format
  # =========================
  
  stats_long <- stats_df %>%
    pivot_longer(
      cols = c(Mean, Q1, Median, Q3, Max),
      names_to = "Statistic",
      values_to = "Value"
    ) %>%
    group_by(.data[[x_col]]) %>%
    mutate(
      y_position =
        max(df[[y_col]], na.rm = TRUE) +
        annotation_padding +
        (row_number() - 1) * annotation_spacing
    )
  
  # =========================
  # Plot
  # =========================
  
  p <- ggplot(
    df,
    aes(
      x = factor(.data[[x_col]]),
      y = .data[[y_col]],
      fill = factor(.data[[x_col]])
    )
  ) +
    
    # -------------------------
  # Boxplot
  # -------------------------
  
  geom_boxplot(
    alpha = box_alpha,
    outlier.shape = NA,
    
    median.colour = median_color,
    
    whisker.colour = "gray",
    whisker.linewidth = 0.8,
    
    staple.colour = "gray",
    staple.linewidth = 0.8
  ) +
    
    # -------------------------
  # Mean points
  # -------------------------
  
  stat_summary(
    fun = mean,
    geom = "point",
    shape = 21,
    size = 3,
    fill = mean_fill,
    color = mean_border
  ) +
    
    # -------------------------
  # Stripplot
  # -------------------------
  
  geom_jitter(
    color = strip_color,
    size = strip_size,
    alpha = strip_alpha,
    width = 0.15
  ) +
    
    # -------------------------
  # Statistical annotations
  # -------------------------
  
  geom_text(
    data = stats_long,
    aes(
      x = factor(.data[[x_col]]),
      y = y_position,
      label = paste0(
        Statistic,
        ": ",
        sprintf("%.3f", Value)
      )
    ),
    inherit.aes = FALSE,
    size = annotation_size,
    fontface = "italic"
  ) +
    
    # -------------------------
  # Colors
  # -------------------------
  
  scale_fill_manual(
    values = palette_colors
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
  
  theme_bw(base_size = 14) +
    
    theme(
      plot.title = element_text(
        face = "bold",
        hjust = 0.5,
        size = 18
      ),
      
      axis.title = element_text(
        size = 14
      ),
      
      axis.text = element_text(
        size = 12
      ),
      
      legend.position = "none"
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

plot_metric_distribution(
  
  input_file =
    "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/clustering_try_results/umap_hdbscan/results_db_umap_hdbscan.csv",
  
  output_file =
    "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/clustering_try_result_analysis/umap_hdbscan/umap_sil_score_dist_vs_umap_neighbours.pdf",
  
  x_col = "umap_n_neighbors",
  y_col = "silhouette",
  
  strip_color = "#08306B",
  median_color = "#8B0000",
  
  palette_name = "Spectral"
)