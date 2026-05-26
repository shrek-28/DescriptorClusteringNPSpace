library(tidyverse)

# =========================
# INPUT FILE
# =========================
input_file <- "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/representative_analytics/size_stratified_best_rep.csv"

# =========================
# LOAD DATA
# =========================
df <- read_csv(input_file, show_col_types = FALSE)

# =========================
# LONG FORMAT
# =========================
plot_df <- df %>%
  pivot_longer(
    cols = -size_bin,
    names_to = "representative",
    values_to = "count"
  )

# =========================
# BARPLOT
# =========================
p <- ggplot(
  plot_df,
  aes(x = size_bin, y = count, fill = representative)
) +
  
  geom_bar(
    stat = "identity",
    position = position_dodge(width = 0.8),
    width = 0.7,
    linewidth = 0.3
  ) +
  
  geom_text(
    aes(label = count),
    position = position_dodge(width = 0.8),
    vjust = -0.5,
    size = 3
  ) +
  scale_fill_brewer(palette = "Pastel1") +
  labs(
    title = "Best Representative Counts Across Size Strata",
    x = "Cluster Size Stratum",
    y = "Count",
    fill = "Representative Type"
  ) +
  
  theme_bw() +
  
  theme(
    legend.position="top",
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.text.x = element_text(face = "bold")
  )

# =========================
# DISPLAY
# =========================
ggsave(filename="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/representative_analyses/best_rep_count.pdf", plot=p, width=8, height=6)