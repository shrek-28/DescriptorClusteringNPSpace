library(tidyverse)
library(RColorBrewer)

# =========================
# INPUT FILE
# =========================
input_file <- "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/representative_analytics/random_vs_rep.csv"

# =========================
# LOAD DATA
# =========================
df <- read_csv(input_file, show_col_types = FALSE)

# =========================
# LONG FORMAT
# =========================
plot_df <- df %>%
  pivot_longer(
    cols = c(
      avg_random,
      medoid,
      centroid_closest,
      diverse_1,
      diverse_2,
      diverse_3,
      diverse_4,
      diverse_5
    ),
    names_to = "method",
    values_to = "affinity"
  )

# =========================
# PRESERVE CLUSTER ORDER
# =========================
plot_df <- plot_df %>%
  group_by(size_bin) %>%
  mutate(
    cluster = factor(cluster, levels = unique(cluster))
  ) %>%
  ungroup()

# =========================
# FACETED LINEPLOT
# =========================
p <- ggplot(
  plot_df,
  aes(
    x = cluster,
    y = affinity,
    color = method,
    group = method
  )
) +
  
  geom_line(
    linewidth = 0.8,
    na.rm = TRUE
  ) +
  
  geom_point(
    size = 2,
    na.rm = TRUE
  ) +
  
  facet_wrap(
    ~ size_bin,
    scales = "free_x",
    nrow = 1
  ) +
  
  scale_color_brewer(palette = "Set2") +
  
  labs(
    title = "Docking Affinity Across Clusters by Size Stratum - KEAP1",
    x = "Cluster",
    y = "Affinity (kcal/mol)",
    color = "Method"
  ) +
  
  theme_bw() +
  
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    ),
    
    axis.text.x = element_text(
      angle = 90,
      vjust = 0.5,
      hjust = 1
    ),
    
    strip.text = element_text(
      face = "bold"
    ),
    
    legend.position="top"
  )

# =========================
# DISPLAY
# =========================
print(p)
ggsave(filename="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/representative_analyses/stratified_docking_affinity.pdf", plot=p, width=15, height=6)

