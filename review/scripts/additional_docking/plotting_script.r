library(tidyverse)
library(RColorBrewer)

# =========================
# ARGUMENTS
# =========================

args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 3) {
  stop(
    "Usage: Rscript plot_docking_affinity.R <input.csv> <output.pdf> <protein_name>"
  )
}

input_file <- args[1]
output_file <- args[2]
protein_name <- args[3]

# =========================
# LOAD DATA
# =========================

df <- read_csv(input_file, show_col_types = FALSE)

# =========================
# SELECT FIVE CLUSTERS PER SIZE STRATUM
# =========================

representative_methods <- c(
  "medoid",
  "centroid_closest",
  "diverse_1",
  "diverse_2",
  "diverse_3",
  "diverse_4",
  "diverse_5"
)

df <- df %>%
  mutate(
    n_representatives = rowSums(
      !is.na(
        as.matrix(select(., all_of(representative_methods)))
      )
    )
  ) %>%
  group_by(size_bin) %>%
  arrange(
    desc(n_representatives),
    cluster,
    .by_group = TRUE
  ) %>%
  slice_head(n = 5) %>%
  ungroup()

# Display selected clusters

print(
  df %>%
    select(cluster, size_bin, n_representatives)
)

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
    title = paste(
      "Docking Affinity Across Clusters by Size Stratum -",
      protein_name
    ),
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

    legend.position = "top"
  )

# =========================
# DISPLAY
# =========================

print(p)

# =========================
# SAVE PLOT
# =========================

ggsave(
  filename = output_file,
  plot = p,
  width = 15,
  height = 6
)

# =========================
# SAVE SELECTED CLUSTERS
# =========================

write_csv(
  df %>%
    select(cluster, size_bin, n_representatives),
  str_replace(output_file, "\\.pdf$", "_selected_clusters.csv")
)