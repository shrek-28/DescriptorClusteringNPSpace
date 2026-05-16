library(readr)
library(ggplot2)

# Read pairwise correlation table
df <- read_csv("/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/complete_correlation_matrix/pairwise_correlations.csv")

# =========================================================
# CREATE HISTOGRAM BIN DATA
# =========================================================

hist_data <- ggplot_build(
  ggplot(df, aes(x = Correlation)) +
    geom_histogram(bins = 20)
)$data[[1]]

# Assign colors based on bin location
hist_data <- hist_data %>%
  mutate(
    FillGroup = ifelse(x < 0, "Negative", "Positive")
  )

# =========================================================
# PLOT
# =========================================================

p <- ggplot(hist_data,
            aes(x = x,
                y = count,
                fill = FillGroup)) +
  
  geom_col(
    width = hist_data$xmax - hist_data$xmin,
    color = "black"
  ) +
  
  # Annotate counts
  geom_text(
    aes(label = count),
    vjust = -0.35,
    size = 3
  ) +
  
  scale_fill_manual(
    values = c(
      "Negative" = "#F4A6A6",   # light red
      "Positive" = "#A9CFF5"    # light blue
    )
  ) +
  
  labs(
    title = "Distribution of Pairwise Correlation Coefficients",
    x = "Spearman Correlation Coefficient",
    y = "Frequency"
  ) +
  
  theme_minimal(base_size = 14) +
  
  theme(
    plot.title = element_text(
      face = "bold",
      hjust = 0.5
    ),
    
    axis.text.x = element_text(size = 11),
    axis.text.y = element_text(size = 11),
    
    legend.position = "top",
    legend.title = element_blank()
  ) +
  
  expand_limits(
    y = max(hist_data$count) * 1.1
  )

print(p)

ggsave("/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/complete_correl_matrix/correlation_freq_dist.pdf", plot=p, width=8, height=6)