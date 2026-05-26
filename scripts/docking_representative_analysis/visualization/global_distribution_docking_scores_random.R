library(tidyverse)

# =========================
# INPUT FOLDER
# =========================
input_folder <- "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/random_molecule_docking_results"

# =========================
# OUTPUT FILE
# =========================
output_plot <- "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/representative_analyses/random_docking_scores.pdf"

# =========================
# GET ALL CSV FILES
# =========================
files <- list.files(
  path = input_folder,
  pattern = "_results\\.csv$",
  full.names = TRUE
)

# =========================
# LOAD ALL CLUSTER FILES
# =========================
df <- bind_rows(lapply(files, function(f) {
  
  cluster_id <- basename(f) %>%
    str_remove("_results\\.csv")
  
  read_csv(f, show_col_types = FALSE) %>%
    transmute(
      cluster = cluster_id,
      affinity = `Affinity (kcal/mol)`
    )
  
}))

# preserve cluster order
cluster_order <- unique(df$cluster)

df$cluster <- factor(df$cluster, levels = cluster_order)

# =========================
# SUMMARY STATS
# =========================
stats <- df %>%
  group_by(cluster) %>%
  summarise(
    mean   = mean(affinity, na.rm = TRUE),
    median = median(affinity, na.rm = TRUE),
    min    = min(affinity, na.rm = TRUE),
    max    = max(affinity, na.rm = TRUE),
    q1     = quantile(affinity, 0.25, na.rm = TRUE),
    q3     = quantile(affinity, 0.75, na.rm = TRUE),
    count  = n(),
    .groups = "drop"
  ) %>%
  mutate(x = seq_len(n()))

# =========================
# LINE WIDTH CONTROLS
# =========================
whisker_lwd <- 0.3
cap_lwd     <- 0.4
mean_lwd    <- 0.5
median_lwd  <- 0.5

# box half-width
h <- 0.2

# =========================
# PLOT
# =========================
p <- ggplot() +
  
  # BOX
  geom_rect(
    data = stats,
    aes(
      xmin = x - h,
      xmax = x + h,
      ymin = q1,
      ymax = q3,
      fill = cluster
    ),
    color = "black",
    linewidth = 0.3
  ) +
  
  # UPPER WHISKER
  geom_segment(
    data = stats,
    aes(x = x, xend = x, y = q3, yend = max),
    linewidth = whisker_lwd,
    color = "black"
  ) +
  
  # LOWER WHISKER
  geom_segment(
    data = stats,
    aes(x = x, xend = x, y = q1, yend = min),
    linewidth = whisker_lwd,
    color = "black"
  ) +
  
  # MIN CAP
  geom_segment(
    data = stats,
    aes(x = x - h, xend = x + h, y = min, yend = min),
    color = "red",
    linewidth = cap_lwd
  ) +
  
  # MAX CAP
  geom_segment(
    data = stats,
    aes(x = x - h, xend = x + h, y = max, yend = max),
    color = "red",
    linewidth = cap_lwd
  ) +
  
  # MEDIAN
  geom_segment(
    data = stats,
    aes(x = x - h, xend = x + h, y = median, yend = median),
    color = "darkgreen",
    linetype = "dotted",
    linewidth = median_lwd
  ) +
  
  # MEAN
  geom_segment(
    data = stats,
    aes(x = x - h, xend = x + h, y = mean, yend = mean),
    color = "blue",
    linewidth = mean_lwd
  ) +
  
  # =========================
# ANNOTATIONS
# =========================

# Mean
geom_text(
  data = stats,
  aes(x = x, y = mean,
      label = round(mean, 2)),
  color = "blue",
  vjust = -1,
  size = 2.5
) +
  
  # Median
  geom_text(
    data = stats,
    aes(x = x, y = median,
        label = round(median, 2)),
    color = "darkgreen",
    vjust = 1.5,
    size = 2.5
  ) +
  
  # Min
  geom_text(
    data = stats,
    aes(x = x, y = min,
        label = round(min, 2)),
    color = "red",
    vjust = 1.5,
    size = 2.5
  ) +
  
  # Max
  geom_text(
    data = stats,
    aes(x = x, y = max,
        label = round(max, 2)),
    color = "red",
    vjust = -1,
    size = 2.5
  ) +
  
  
  # =========================
# AXES
# =========================
scale_x_continuous(
  breaks = stats$x,
  labels = stats$cluster
) +
  
  labs(
    title = "Docking Affinity Distribution Across Clusters",
    x = "Cluster",
    y = "Affinity (kcal/mol)"
  ) +
  
  theme_bw() +
  
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
    plot.title = element_text(hjust = 0.5, face = "bold")
  )

# =========================
# DISPLAY
# =========================
print(p)

# =========================
# EXPORT
# =========================
ggsave(
  filename = output_plot,
  plot = p,
  width = max(14, nrow(stats) * 0.35),
  height = 7,
  dpi = 600
)