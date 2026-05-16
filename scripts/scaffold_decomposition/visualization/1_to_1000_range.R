library(readr)
library(ggplot2)

# Read binned frequency table
df <- read_csv("/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/scaffold_decomposition/frequency_bins_50.csv")

# ---- Customization ----

bar_color <- "#06402B"
bar_width <- 0.9
text_size <- 4

# ---- Histogram-style Plot ----

p <- ggplot(df, aes(x = Frequency_Bin, y = Scaffold_Count)) +
  
  geom_bar(
    stat = "identity",
    fill = bar_color,
    width = bar_width
  ) +
  
  # Annotate counts above bars
  geom_text(
    aes(label = Scaffold_Count),
    vjust = -0.4,
    size = text_size
  ) +
  
  # Log10 scale
  scale_y_log10() +
  
  labs(
    title = "Distribution of Scaffold Frequencies: Frequencies in the Range of 1-1000",
    x = "Frequency Bin",
    y = "Number of Scaffolds (log10 scale)"
  ) +
  
  theme_minimal(base_size = 14) +
  
  theme(
    plot.title = element_text(
      face = "bold",
      hjust = 0.5
    ),
    
    axis.text.x = element_text(
      angle = 45,
      hjust = 1,
      size = 11
    ),
    
    axis.text.y = element_text(size = 11)
  )

print(p)
ggsave("/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/scaffold_decomposition/scaffold_freq_distribution_1_to_1000.pdf", plot=p)