library(readr)
library(ggplot2)

# Read distribution table
df <- read_csv("/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/scaffold_decomposition/frequency_exact_1_10.csv")

# ---- Customization ----

bar_color <- "#06402B"
bar_width <- 0.8
text_size <- 4

# ---- Bar Plot ----

p <- ggplot(df, aes(x = factor(Frequency), y = Scaffold_Count)) +
  
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
  
  labs(
    title = "Scaffold Frequency Distribution: 1 to 10 Range",
    x = "Frequency",
    y = "Scaffold Count"
  ) +
  
  expand_limits(
    y = max(df$Scaffold_Count) * 1.1
  ) +
  
  theme_minimal(base_size = 14) +
  
  theme(
    plot.title = element_text(
      face = "bold",
      hjust = 0.5
    ),
    
    axis.text.x = element_text(size = 11),
    axis.text.y = element_text(size = 11)
  )

print(p)
ggsave("/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/scaffold_decomposition/scaffold_freq_distribution_1_to_10.pdf", plot=p, width=8, height=6)