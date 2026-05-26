library(tidyverse)

files <- list(
  centroid_closest = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/representative_docking_results_files/centroid_closest_results.csv",
  diverse_1 = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/representative_docking_results_files/diverse_1_results.csv",
  diverse_2 = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/representative_docking_results_files/diverse_2_results.csv",
  diverse_3 = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/representative_docking_results_files/diverse_3_results.csv",
  diverse_4 = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/representative_docking_results_files/diverse_4_results.csv",
  diverse_5 = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/representative_docking_results_files/diverse_5_results.csv",
  medoid = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/representative_docking_results_files/medoid_results.csv"
)

df <- bind_rows(lapply(names(files), function(nm) {
  read_csv(files[[nm]]) %>%
    transmute(type = nm,
              affinity = `Affinity (kcal/mol)`)
}))

df$type <- factor(df$type, levels = names(files))

stats <- df %>%
  group_by(type) %>%
  summarise(
    mean = mean(affinity),
    median = median(affinity),
    min = min(affinity),
    max = max(affinity),
    q1 = quantile(affinity, 0.25),
    q3 = quantile(affinity, 0.75),
    n = n(),
    .groups = "drop"
  ) %>%
  mutate(x = as.numeric(type))

w <- 0.25
h <- w

ggplot() +
  
  # =========================
# BOX (Q1-Q3)
# =========================
geom_rect(
  data = stats,
  aes(xmin = x - h, xmax = x + h, ymin = q1, ymax = q3, fill = type),
  color = "black",
  linewidth = 0.3
) +
  
  # =========================
# WHISKERS (FIXED: OUTSIDE BOX)
# left edge + right edge
# =========================
  
  geom_segment(
    data = stats,
    aes(x = x, xend = x, y = min, yend = q1),
    linewidth = 0.3,
    color = "black"
  ) +
  
  geom_segment(
    data = stats,
    aes(x = x, xend = x, y = q3, yend = max),
    linewidth = 0.3,
    color = "black"
  ) +
  
  # =========================
# CAPS
# =========================
geom_segment(
  data = stats,
  aes(x = x - h, xend = x + h, y = min, yend = min),
  color = "red",
  linewidth = 0.7
) +
  geom_segment(
    data = stats,
    aes(x = x - h, xend = x + h, y = max, yend = max),
    color = "red",
    linewidth = 0.7
  ) +
  
  # =========================
# MEDIAN (inside box)
# =========================
geom_segment(
  data = stats,
  aes(x = x - h, xend = x + h, y = median, yend = median),
  color = "darkgreen",
  linetype = "dotted",
  linewidth = 0.6
) +
  
  # =========================
# MEAN (inside box)
# =========================
geom_segment(
  data = stats,
  aes(x = x - h, xend = x + h, y = mean, yend = mean),
  color = "blue",
  linewidth = 0.6
) +
  
  geom_text(
    data = stats,
    aes(x = x, y = mean,
        label = round(mean, 2)),
    color = "blue",
    vjust = -1.75,
    size = 3
  ) +
  
  # Median
  geom_text(
    data = stats,
    aes(x = x, y = median,
        label = round(median, 2)),
    color = "darkgreen",
    vjust = 1.75,
    size = 3
  ) +
  
  # Min
  geom_text(
    data = stats,
    aes(x = x, y = min,
        label = round(min, 2)),
    color = "red",
    vjust = 1.5,
    size = 3
  ) +
  
  # Max
  geom_text(
    data = stats,
    aes(x = x, y = max,
        label = round(max, 2)),
    color = "red",
    vjust = -1,
    size = 3
  )+
  scale_x_continuous(
    breaks = stats$x,
    labels = stats$type
  ) +
  
  labs(
    title = "Docking Affinity Distribution Across Representative Types",
    x = "Representative Type",
    y = "Affinity (kcal/mol)"
  ) +
  
  scale_fill_brewer(palette = "Pastel2") +
  
  theme_bw() +
  theme(
    legend.position = "top",
    axis.text.x = element_text(angle = 30, hjust = 1)
  )

ggsave(filename="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/representative_analyses/docking_score_representatives.pdf", width=12, height=8)

