library(tidyverse)

df <- read_csv("/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/pareto_optimization/pareto_df.csv")

df$band <- as.factor(df$band)

band_labels <- c(
  "band1" = "0.5-0.85",
  "band2" = "0.35-0.85",
  "band3" = "0.25-0.85",
  "band4" = "0.35-0.75"
)

band_colors <- c(
  "band1" = "#D55E00",
  "band2" = "#0072B2",
  "band3" = "#009E73",
  "band4" = "#CC79A7"
)

p <- ggplot(df, aes(x = k,
                    y = mean_abs_corr,
                    color = band,
                    group = band)) +
  geom_line(size = 0.75) +
  geom_point(size = 1.5) +
  scale_x_continuous(breaks = c(10, 15, 20, 25)) +
  scale_color_manual(
    values = band_colors,
    labels = band_labels,
    name = "Correlation Band Values"
  ) +
  labs(
    title = "Mean Absolute Correlation Across Correlation Limitations",
    x = "Number of Clusters (k)",
    y = "Mean Absolute Correlation"
  ) +
  theme_bw() +
  theme(
    legend.position = "top",
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.title = element_text(size = 10),
    axis.text = element_text(size = 8)
  )

print(p)
ggsave("/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/pareto_optimization/mean_abs_corr_desc_bands.pdf", width=6, height=4, dpi=300)
