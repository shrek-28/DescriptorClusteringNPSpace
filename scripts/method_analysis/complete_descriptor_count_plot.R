library(ggplot2)
library(readr)

plot_descriptor_occurrence <- function(
    input_file,
    output_file,
    plot_title = "Descriptor Percentage Occurrence"
) {
  
  # Load data
  df <- read_csv(input_file)
  
  # Sort descriptors
  df$descriptor <- factor(
    df$descriptor,
    levels = df$descriptor[
      order(df$percentage_occurrence, decreasing = TRUE)
    ]
  )
  
  # Generate plot
  p <- ggplot(
    df,
    aes(
      x = descriptor,
      y = percentage_occurrence
    )
  ) +
    
    geom_bar(
      stat = "identity",
      width = 0.75,
      fill = "darkgreen"
    ) +
    
    geom_text(
      aes(
        label = paste0(
          round(percentage_occurrence, 1)
        )
      ),
      vjust = -0.35,
      size = 3.8
    ) +
    
    labs(
      title = plot_title,
      x = "Descriptor",
      y = "Percentage Occurrence (%)"
    ) +
    
    ylim(
      0,
      max(df$percentage_occurrence) * 1.15
    ) +
    
    theme_minimal(base_size = 13) +
    
    theme(
      plot.title = element_text(
        face = "bold",
        size = 16,
        hjust = 0.5
      ),
      
      axis.title = element_text(
        face = "bold"
      ),
      
      axis.text.x = element_text(
        angle = 45,
        hjust = 1,
        face = "bold",
        size = 10
      ),
      
      panel.grid.minor = element_blank(),
      
      panel.grid.major.x = element_blank()
    )
  
  # Save plot
  ggsave(
    filename = output_file,
    plot = p,
    width = 25,
    height = 7,
    dpi = 300
  )
  
  print(p)
}

# Example usage
plot_descriptor_occurrence(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/descriptor_occurrence_analysis.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/descriptor_wise_method_analysis/complete_descriptor_plot.pdf", plot_title="Complete Descriptor Presence Across Methods")
