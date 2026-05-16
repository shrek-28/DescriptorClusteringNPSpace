library(ggplot2)
library(readr)
library(dplyr)

# Read dataset
df <- read_csv("/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/scaffold_decomposition/top_20_bemis_murcko_scaffolds.csv")

# Add rank labels: 1, 2, 3 ...
df <- df %>%
  mutate(Rank = factor(1:n()))

# ---- Customization Parameters ----

bar_color <- "#06402B"   # Bar color
bar_width <- 0.85        # Bar breadth (smaller = more spacing)
text_size <- 3.5         # Frequency annotation size

# ---- Plot ----

p <- ggplot(df, aes(x = Rank, y = frequency, fill = "Frequency")) +
  
  # Bars  
  geom_bar(
    stat = "identity",
    width = bar_width
  ) +
  
  # Frequency labels above bars
  geom_text(
    aes(label = frequency),
    vjust = -0.4,
    size = text_size
  ) +
  
  # Legend customization
  scale_fill_manual(
    values = c("Frequency" = bar_color),
    name = "Legend"
  ) +
  
  # Labels
  labs(
    title = "Top 20 Most Frequent Scaffolds",
    x = "Scaffold Rank",
    y = "Frequency"
  ) +
  
  # Extra space above bars for annotations
  expand_limits(y = max(df$frequency) * 1.1) +
  
  # Theme
  theme_minimal(base_size = 14) +
  
  theme(
    legend.position = "top",
    
    plot.title = element_text(
      face = "bold",
      hjust = 0.5
    ),
    
    axis.text.x = element_text(size = 11),
    axis.text.y = element_text(size = 11)
  )

ggsave("/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/scaffold_decomposition/top_20_bemis_murcko_scaffolds.pdf", plot=p, width=16, height=7)