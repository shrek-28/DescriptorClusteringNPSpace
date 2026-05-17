# =========================
# Libraries
# =========================
library(readr)
library(dplyr)
library(ggplot2)

# =========================
# Function
# =========================

plot_purity_vs_noise <- function(
    
  input_file,
  output_file,
  
  # -------------------------
  # Column names
  # -------------------------
  
  x_col = "noise_fraction",
  y_col = "purity",
  
  # -------------------------
  # Labels
  # -------------------------
  
  plot_title = "Trend of Cluster Purity vs Noise Fraction",
  x_label = "Noise Fraction",
  y_label = "Cluster Purity",
  
  # -------------------------
  # Colors
  # -------------------------
  
  line_color = "darkblue",
  ribbon_color = "lightblue",
  
  # -------------------------
  # Line aesthetics
  # -------------------------
  
  line_width = 1,
  point_size = 2,
  
  # -------------------------
  # Confidence interval
  # -------------------------
  
  show_sd = TRUE,
  ribbon_alpha = 0.3,
  
  # -------------------------
  # Theme
  # -------------------------
  
  base_size = 14,
  grid_alpha = 0.3,
  
  # -------------------------
  # Figure size
  # -------------------------
  
  width = 8,
  height = 6
) {
  
  # =========================
  # Read data
  # =========================
  
  df <- read_csv(input_file)
  
  # =========================
  # Aggregate mean + SD
  # =========================
  
  summary_df <- df %>%
    group_by(.data[[x_col]]) %>%
    summarise(
      mean_value = mean(.data[[y_col]], na.rm = TRUE),
      sd_value = sd(.data[[y_col]], na.rm = TRUE),
      .groups = "drop"
    )
  
  # =========================
  # Plot
  # =========================
  
  p <- ggplot(
    summary_df,
    aes(
      x = .data[[x_col]],
      y = mean_value
    )
  )
  
  # -------------------------
  # Confidence interval ribbon
  # -------------------------
  
  if (show_sd) {
    
    p <- p +
      
      geom_ribbon(
        aes(
          ymin = mean_value - sd_value,
          ymax = mean_value + sd_value
        ),
        fill = ribbon_color,
        alpha = ribbon_alpha
      )
  }
  
  # -------------------------
  # Line
  # -------------------------
  
  p <- p +
    
    geom_line(
      color = line_color,
      linewidth = line_width
    ) +
    
    geom_point(
      color = line_color,
      size = point_size
    ) +
    
    labs(
      title = plot_title,
      x = x_label,
      y = y_label
    ) +
    
    theme_bw(base_size = base_size) +
    
    theme(
      plot.title = element_text(
        face = "bold",
        hjust = 0.5
      ),
      
      panel.grid.major = element_line(
        alpha = grid_alpha
      ),
      
      panel.grid.minor = element_blank(),
      
      axis.text = element_text(size = base_size - 2),
      
      axis.title = element_text(size = base_size)
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

plot_purity_vs_noise(
  input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/clustering_try_results/umap_hdbscan/results_db_umap_hdbscan.csv",
  
  output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/clustering_try_result_analysis/umap_hdbscan/cluster_purity_vs_noise_frac.pdf",
  
  line_color = "#0B3C5D",
  ribbon_color = "#A7C7E7",
  
  line_width = 1,
  point_size = 1.5,
  
  show_sd = TRUE
)