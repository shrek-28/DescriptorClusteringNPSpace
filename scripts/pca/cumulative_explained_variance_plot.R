# =========================
# Libraries
# =========================
library(ggplot2)
library(dplyr)
library(readr)

# =========================
# Read PCA data
# =========================
pca_all <- read_csv(
  "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/pca_data/pca_all_82_descriptors.csv"
) %>%
  mutate(descriptor_set = "all")

pca_20 <- read_csv(
  "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/pca_data/pca_20_descriptors.csv"
) %>%
  mutate(descriptor_set = "selected")

pca_combined <- bind_rows(pca_all, pca_20)

# =========================
# Customization block
# =========================

descriptor_labels <- c(
  all      = "All 82 descriptors",
  selected = "Selected 20 descriptors"
)

descriptor_colors <- c(
  all      = "pink",   # cleaner blue
  selected = "magenta"    # clean muted red
)

max_pc <- 20
x_breaks <- 1:max_pc
y_limits <- c(0, 1.1)
y_breaks <- seq(0, 1, by = 0.1)
y_minor_breaks <- seq(0, 1, by = 0.05)

plot_title <- "PCA Cumulative Explained Variance"
x_label <- "Principal Component"
y_label <- "Cumulative Explained Variance"
legend_title <- "Descriptor Count"

line_width <- 0.75
point_size <- 1.5

# =========================
# Plot
# =========================
p <- pca_combined %>%
  filter(PC <= max_pc) %>%
  ggplot(aes(
    x = PC,
    y = cumulative_variance,
    color = descriptor_set,
    group = descriptor_set
  )) +
  geom_line(
    linewidth = line_width,
    lineend = "round"
  ) +
  geom_point(
    size = point_size,
    alpha = 0.9
  ) +
  scale_color_manual(
    values = descriptor_colors,
    labels = descriptor_labels,
    name = legend_title
  ) +
  scale_x_continuous(
    breaks = x_breaks,
    expand = expansion(mult = c(0.01, 0.02))
  ) +
  scale_y_continuous(
    limits = y_limits,
    breaks = y_breaks,
    minor_breaks = y_minor_breaks,
    expand = c(0, 0)
  ) +
  labs(
    title = plot_title,
    x = x_label,
    y = y_label
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold",
      size = 16,
      margin = margin(b = 10)
    ),
    legend.position = "top",
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 11),
    axis.text.x = element_text(
      hjust = 1,
      vjust = 1
    ),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.minor.y = element_line(color = "grey90"),
    panel.grid.major.y = element_line(color = "grey85"),
    axis.title = element_text(size = 9)
  )

ggsave("/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/pca/explained_variance_plot.pdf", plot=p, width=6, height=4, dpi=300)
