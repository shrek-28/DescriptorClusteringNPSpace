library(tidyverse)

# ==========================================
# LOAD DATA
# ==========================================

df <- read_csv("/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/perturbation_data/descriptor_stability_results.csv")

plot_df <- df %>%
  select(
    seed,
    similarity_40_60,
    presence_40_final20,
    presence_60_final20
  ) %>%
  pivot_longer(
    cols = -seed,
    names_to = "metric",
    values_to = "percentage"
  )

plot_df$metric <- factor(
  plot_df$metric,
  levels = c(
    "similarity_40_60",
    "presence_40_final20",
    "presence_60_final20"
  ),
  labels = c(
    "40_df vs 60_df",
    "40_df vs Final 20",
    "60_df vs Final 20"
  )
)

custom_colors <- c(
  "40_df vs 60_df" = "#8B0000",   # dark red
  "40_df vs Final 20" = "#003366", # dark blue
  "60_df vs Final 20" = "#006400"  # dark green
)

p <- ggplot(
  plot_df,
  aes(
    x = factor(seed),
    y = percentage,
    fill = metric
  )
) +
  
  geom_bar(
    stat = "identity",
    position = position_dodge(width = 0.8),
    width = 0.7
  ) +
  
  geom_text(
    aes(label = round(percentage, 1)),
    position = position_dodge(width = 0.8),
    vjust = -0.3,
    size = 4
  ) +
  
  scale_fill_manual(
    values = custom_colors
  ) +
  
  labs(
    title = "Descriptor Stability Across Random Seeds",
    x = "Random Seed",
    y = "Percentage (%)",
    fill = "Comparison"
  ) +
  
  ylim(0, 110) +
  
  theme_minimal(base_size = 14) +
  
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    ),
    
    axis.title = element_text(
      face = "bold"
    ),
    
    legend.title = element_text(
      face = "bold"
    ),
    
    legend.position = "top",
    
    panel.grid.minor = element_blank()
  )

# ==========================================
# SAVE
# ==========================================
ggsave(
  filename = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/perturbation_analysis/desc_stability_plot.pdf",
  plot = p,
  width = 10,
  height = 6,
  dpi = 300
)


print(p)