# =========================
# Libraries
# =========================
library(readr)
library(ggplot2)

# =========================
# Generic Plot Function
# =========================

plot_metric_vs_trial <- function(
    
  input_file,
  output_file,
  
  # -------------------------
  # Columns
  # -------------------------
  
  x_col = "trial",
  y_col,
  
  # -------------------------
  # Labels
  # -------------------------
  
  plot_title,
  x_label = "Trial Number",
  y_label,
  
  # -------------------------
  # Aesthetics
  # -------------------------
  
  line_color = "magenta",
  line_width = 1,
  point_size = 2.5,
  point_shape = 16,
  
  # -------------------------
  # Theme
  # -------------------------
  
  base_size = 14,
  
  # -------------------------
  # Figure size
  # -------------------------
  
  width = 10,
  height = 6
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
      y = .data[[y_col]]
    )
  ) +
    
    geom_line(
      color = line_color,
      linewidth = line_width
    ) +
    
    geom_point(
      color = line_color,
      size = point_size,
      shape = point_shape
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
        hjust = 0.5,
        size = 16
      ),
      
      axis.title = element_text(
        size = 10
      ),
      
      axis.text = element_text(
        size = 9
      ),
      
      panel.grid.minor = element_blank()
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

# =========================================================
# Wrapper Function
# Generates CH, DBI, and Silhouette plots
# =========================================================

generate_trial_metric_plots <- function(
    
  input_file,
  output_dir,
  
  # -------------------------
  # Colors
  # -------------------------
  
  ch_color = "magenta",
  dbi_color = "darkorange",
  silhouette_color = "darkblue"
) {
  
  # -------------------------
  # CH Index
  # -------------------------
  
  plot_metric_vs_trial(
    
    input_file = input_file,
    
    output_file = paste0(
      output_dir,
      "/ch_index_vs_trial.pdf"
    ),
    
    y_col = "calinski_harabasz",
    
    plot_title =
      "Calinski-Harabasz Index vs Trial",
    
    y_label =
      "Calinski-Harabasz Index",
    
    line_color = ch_color
  )
  
  # -------------------------
  # DBI
  # -------------------------
  
  plot_metric_vs_trial(
    
    input_file = input_file,
    
    output_file = paste0(
      output_dir,
      "/dbi_vs_trial.pdf"
    ),
    
    y_col = "dbi",
    
    plot_title =
      "Davies-Bouldin Index vs Trial",
    
    y_label =
      "Davies-Bouldin Index",
    
    line_color = dbi_color
  )
  
  # -------------------------
  # Silhouette
  # -------------------------
  
  plot_metric_vs_trial(
    
    input_file = input_file,
    
    output_file = paste0(
      output_dir,
      "/silhouette_vs_trial.pdf"
    ),
    
    y_col = "silhouette",
    
    plot_title =
      "Silhouette Score vs Trial",
    
    y_label =
      "Silhouette Score",
    
    line_color = silhouette_color
  )
}

# =========================
# Example Usage
# =========================

generate_trial_metric_plots(
  
  input_file =
    "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/clustering_try_results/umap_bkmeans/umap_bisecting_results.csv",
  
  output_dir =
    "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/clustering_try_result_analysis/umap_bkmeans",
  
  ch_color = "#C71585",
  dbi_color = "#C71585",
  silhouette_color = "#C71585"
)