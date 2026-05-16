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

plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/10_desc/band1.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/max_avg/10_desc/band1.pdf", plot_title = "Band 1: 0.5 - 0.85")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/10_desc/band2.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/max_avg/10_desc/band2.pdf", plot_title = "Band 2: 0.35 - 0.85")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/10_desc/band3.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/max_avg/10_desc/band3.pdf", plot_title = "Band 3: 0.5 - 0.85")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/10_desc/band4.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/max_avg/10_desc/band4.pdf", plot_title = "Band 4: 0.35 - 0.75")

plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/15_desc/band1.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/max_avg/15_desc/band1.pdf", plot_title = "Band 1: 0.5 - 0.85")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/15_desc/band2.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/max_avg/15_desc/band2.pdf", plot_title = "Band 2: 0.35 - 0.85")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/15_desc/band3.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/max_avg/15_desc/band3.pdf", plot_title = "Band 3: 0.5 - 0.85")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/15_desc/band4.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/max_avg/15_desc/band4.pdf", plot_title = "Band 4: 0.35 - 0.75")

plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/20_desc/band1.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/max_avg/20_desc/band1.pdf", plot_title = "Band 1: 0.5 - 0.85")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/20_desc/band2.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/max_avg/20_desc/band2.pdf", plot_title = "Band 2: 0.35 - 0.85")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/20_desc/band3.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/max_avg/20_desc/band3.pdf", plot_title = "Band 3: 0.5 - 0.85")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/20_desc/band4.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/max_avg/20_desc/band4.pdf", plot_title = "Band 4: 0.35 - 0.75")

plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/25_desc/band1.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/max_avg/25_desc/band1.pdf", plot_title = "Band 1: 0.5 - 0.85")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/25_desc/band2.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/max_avg/25_desc/band2.pdf", plot_title = "Band 2: 0.35 - 0.85")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/25_desc/band3.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/max_avg/25_desc/band3.pdf", plot_title = "Band 3: 0.5 - 0.85")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/25_desc/band4.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/max_avg/25_desc/band4.pdf", plot_title = "Band 4: 0.35 - 0.75")

plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/min_avg/10_desc/band1.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/min_avg/10_desc/band1.pdf", plot_title = "Band 1: 0.5 - 0.85")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/min_avg/10_desc/band2.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/min_avg/10_desc/band2.pdf", plot_title = "Band 2: 0.35 - 0.85")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/min_avg/10_desc/band3.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/min_avg/10_desc/band3.pdf", plot_title = "Band 3: 0.5 - 0.85")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/min_avg/10_desc/band4.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/min_avg/10_desc/band4.pdf", plot_title = "Band 4: 0.35 - 0.75")

plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/min_avg/15_desc/band1.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/min_avg/15_desc/band1.pdf", plot_title = "Band 1: 0.5 - 0.85")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/min_avg/15_desc/band2.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/min_avg/15_desc/band2.pdf", plot_title = "Band 2: 0.35 - 0.85")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/min_avg/15_desc/band3.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/min_avg/15_desc/band3.pdf", plot_title = "Band 3: 0.5 - 0.85")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/min_avg/15_desc/band4.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/min_avg/15_desc/band4.pdf", plot_title = "Band 4: 0.35 - 0.75")

plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/min_avg/20_desc/band1.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/min_avg/20_desc/band1.pdf", plot_title = "Band 1: 0.5 - 0.85")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/min_avg/20_desc/band2.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/min_avg/20_desc/band2.pdf", plot_title = "Band 2: 0.35 - 0.85")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/min_avg/20_desc/band3.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/min_avg/20_desc/band3.pdf", plot_title = "Band 3: 0.5 - 0.85")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/min_avg/20_desc/band4.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/min_avg/20_desc/band4.pdf", plot_title = "Band 4: 0.35 - 0.75")

plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/min_avg/25_desc/band1.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/min_avg/25_desc/band1.pdf", plot_title = "Band 1: 0.5 - 0.85")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/min_avg/25_desc/band2.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/min_avg/25_desc/band2.pdf", plot_title = "Band 2: 0.35 - 0.85")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/min_avg/25_desc/band3.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/min_avg/25_desc/band3.pdf", plot_title = "Band 3: 0.5 - 0.85")
plot_correlation_matrix(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/min_avg/25_desc/band4.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering/min_avg/25_desc/band4.pdf", plot_title = "Band 4: 0.35 - 0.75")