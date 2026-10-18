library(readr)
library(ggplot2)
library(reshape2)

# Read precomputed correlation matrix
cor_matrix <- read_csv("/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/complete_correlation_matrix/correlation_matrix_spearman.csv")

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

p <- ggplot(cor_melt,
            aes(x = Var1,
                y = Var2,
                fill = value)) +
  
  # Heatmap tiles
  geom_tile(color = "white") +
  
  # Correlation annotations
  geom_text(
    aes(label = sprintf("%.2f", value)),
    size = 4.5
  ) +
  
  # Color scale
  scale_fill_gradient2(
    low = "#053061",
    mid = "white",
    high = "#67001F",
    midpoint = 0,
    limits = c(-1, 1),
    name = "Correlation"
  ) +
  
  # Force all descriptor labels to appear
  scale_x_discrete(limits = descriptor_names) +
  scale_y_discrete(limits = rev(descriptor_names)) +
  
  coord_fixed() +
  
  labs(
    title = "Correlation Matrix of Complete Descriptor Set",
    x = "",
    y = ""
  ) +
  
  theme_minimal(base_size = 18) +
  
  theme(
    plot.title = element_text(
      face = "bold",
      hjust = 0.5,
      size = 24
    ),
    
    axis.text.x = element_text(
      angle = 90,
      vjust = 0.5,
      hjust = 1,
      size = 16
    ),
    axis.text.y = element_text(
      size = 16
    ),
    
    panel.grid = element_blank()
  )

print(p)

ggsave("/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/complete_correl_matrix/complete_spearman_matrix.pdf", plot=p, width=48, height=48)