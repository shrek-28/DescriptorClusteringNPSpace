library(readr)
library(ggplot2)
library(reshape2)

plot_correlation_matrix <- function(
    input_file,
    output_file,
    plot_title = "Correlation Matrix",
    low_color = "#053061",
    mid_color = "white",
    high_color = "#67001F",
    width = 12,
    height = 12
) {
  
  # Read correlation matrix
  cor_matrix <- read_csv(input_file)
  
  # Convert first column to row names
  cor_matrix <- as.data.frame(cor_matrix)
  rownames(cor_matrix) <- cor_matrix[,1]
  cor_matrix <- cor_matrix[,-1]
  
  # Convert to numeric matrix
  cor_matrix <- as.matrix(sapply(cor_matrix, as.numeric))
  
  # Preserve descriptor names
  descriptor_names <- colnames(cor_matrix)
  
  # Melt matrix
  cor_melt <- melt(cor_matrix)
  
  # ---- Plot ----
  
  p <- ggplot(
    cor_melt,
    aes(
      x = Var1,
      y = Var2,
      fill = value
    )
  ) +
    
    # Heatmap tiles
    geom_tile(color = "white") +
    
    # Correlation annotations
    geom_text(
      aes(label = sprintf("%.2f", value)),
      size = 2.0
    ) +
    
    # Color scale
    scale_fill_gradient2(
      low = low_color,
      mid = mid_color,
      high = high_color,
      midpoint = 0,
      limits = c(-1, 1),
      name = "Correlation"
    ) +
    
    # Force all descriptor labels
    scale_x_discrete(limits = descriptor_names) +
    scale_y_discrete(limits = rev(descriptor_names)) +
    
    coord_fixed() +
    
    labs(
      title = plot_title,
      x = "",
      y = ""
    ) +
    
    theme_minimal(base_size = 18) +
    
    theme(
      plot.title = element_text(
        face = "bold",
        hjust = 0.5,
        size = 18
      ),
      
      axis.text.x = element_text(
        angle = 90,
        vjust = 0.5,
        hjust = 1,
        size = 8
      ),
      
      axis.text.y = element_text(
        size = 8
      ),
      
      legend.position = "right",
      
      panel.grid = element_blank()
    )
  
  # Print plot
  print(p)
  
  # Save plot
  ggsave(
    output_file,
    plot = p,
    width = width,
    height = height
  )
}

plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/perturbation_data/rs_0/40_df_greedy_corr_matrix.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/perturbation_analysis/rs_0/40_df.pdf", plot_title = "Random Seed 0; 40% Data")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/perturbation_data/rs_0/60_df_greedy_corr_matrix.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/perturbation_analysis/rs_0/60_df.pdf", plot_title = "Random Seed 0; 60% Data")

plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/perturbation_data/rs_1/40_df_greedy_corr_matrix.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/perturbation_analysis/rs_1/40_df.pdf", plot_title = "Random Seed 1; 40% Data")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/perturbation_data/rs_1/60_df_greedy_corr_matrix.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/perturbation_analysis/rs_1/60_df.pdf", plot_title = "Random Seed 1; 60% Data")

plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/perturbation_data/rs_42/40_df_greedy_corr_matrix.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/perturbation_analysis/rs_42/40_df.pdf", plot_title = "Random Seed 42; 40% Data")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/perturbation_data/rs_42/60_df_greedy_corr_matrix.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/perturbation_analysis/rs_42/60_df.pdf", plot_title = "Random Seed 42; 60% Data")

plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/perturbation_data/rs_101/40_df_greedy_corr_matrix.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/perturbation_analysis/rs_101/40_df.pdf", plot_title = "Random Seed 101; 40% Data")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/perturbation_data/rs_101/60_df_greedy_corr_matrix.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/perturbation_analysis/rs_101/60_df.pdf", plot_title = "Random Seed 101; 60% Data")

plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/perturbation_data/rs_123/40_df_greedy_corr_matrix.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/perturbation_analysis/rs_123/40_df.pdf", plot_title = "Random Seed 123; 40% Data")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/perturbation_data/rs_123/60_df_greedy_corr_matrix.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/perturbation_analysis/rs_123/60_df.pdf", plot_title = "Random Seed 123; 60% Data")


