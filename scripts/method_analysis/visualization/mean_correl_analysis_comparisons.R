library(tidyverse)

# Read data
df <- read.csv("/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/correlation_analysis/heatmap_3way.csv")

# Convert to long format
df_long <- df %>%
  pivot_longer(
    cols = starts_with("X"),
    names_to = "descriptor_count",
    values_to = "mean_correlation"
  )

# Clean labels
df_long$descriptor_count <- gsub("X", "", df_long$descriptor_count)

# Ordering
df_long$descriptor_count <- factor(
  df_long$descriptor_count,
  levels = c("10", "15", "20", "25")
)

df_long$band <- factor(
  df_long$band,
  levels = c("band1", "band2", "band3", "band4")
)

# Wide-oriented heatmap
p <- ggplot(df_long, aes(
  x = descriptor_count,
  y = band,
  fill = mean_correlation
)) +
  
  geom_tile(color = "white", linewidth = 0.8) +
  
  geom_text(
    aes(label = round(mean_correlation, 2)),
    size = 4
  ) +
  
  facet_grid(. ~ method) +
  
  scale_fill_gradient(
    low = "white",
    high = "darkred"
  ) +
  
  labs(
    title = "Mean Correlation Analysis Comparisons",
    x = "Descriptor Count",
    y = "Band",
    fill = "Correlation"
  ) +
  
  theme_minimal(base_size = 14) +
  
  theme(
    panel.grid = element_blank(),
    
    strip.text = element_text(
      face = "bold",
      size = 13
    ),
    
    axis.text.x = element_text(
      face = "bold",
      size = 11
    ),
    
    axis.text.y = element_text(
      size = 11
    ),
    
    plot.title = element_text(
      face = "bold",
      hjust = 0.5
    ),
    
    panel.spacing.x = unit(1.5, "cm")
  )

# Display
print(p)

ggsave("/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/method_comparison/correlation_comparison.pdf", plot=p, width=10, height=4)