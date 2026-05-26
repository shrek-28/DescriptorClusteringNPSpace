library(tidyverse)
library(RColorBrewer)

# =========================
# INPUT FILE
# =========================
input_file <- "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/representative_analytics/best_rep_counts.csv"

# =========================
# LOAD DATA
# =========================
df <- read_csv(input_file, show_col_types = FALSE)

# =========================
# ORDER BARS
# =========================
df <- df %>%
  arrange(desc(num_clusters_best)) %>%
  mutate(
    rep_type = factor(rep_type, levels = rep_type)
  )

# =========================
# BARPLOT
# =========================
p <- ggplot(
  df,
  aes(x = rep_type, y = num_clusters_best, fill = rep_type)
) +
  
  geom_bar(
    stat = "identity",
    width = 0.7,
    linewidth = 0.3
  ) +
  
  geom_text(
    aes(label = num_clusters_best),
    vjust = -0.5,
    size = 4
  ) +
  
  scale_fill_brewer(palette = "Pastel1") +
  
  labs(
    title = "Best Performing Cluster Representatives",
    x = "Representative Type",
    y = "Number of Clusters"
  ) +
  
  theme_bw() +
  
  theme(
    legend.position = "top",
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.text.x = element_text(
      angle = 45,
      hjust = 1
    )
  )

# =========================
# DISPLAY
# =========================
ggsave(filename="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/representative_analyses/best_rep_count_global.pdf", plot=p, width=8, height=6)

