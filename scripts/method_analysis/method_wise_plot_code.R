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
    levels = df$descriptor[order(df$percentage_occurrence)]
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
      fill = "hotpink"
    ) +
    
    geom_text(
      aes(
        label = paste0(
          round(percentage_occurrence, 1),
          "%"
        )
      ),
      hjust = -0.1,
      size = 3.8
    ) +
    
    coord_flip() +
    
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
      
      axis.text.y = element_text(
        face = "bold",
        size = 10
      ),
      
      panel.grid.major.y = element_blank(),
      
      panel.grid.minor = element_blank()
    )
  
  # Save plot
  ggsave(
    filename = output_file,
    plot = p,
    width = 7,
    height = 14,
    dpi = 300
  )
  
  print(p)
}

# Example usage
plot_descriptor_occurrence(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/method_wise_desc_presence/greedy_max_coverage_descriptor_occurrence.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/descriptor_wise_method_analysis/method/greedy_max_cov.pdf", plot_title="Greedy Maximum Coverage")
plot_descriptor_occurrence(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/method_wise_desc_presence/hierarchical_max_avg_descriptor_occurrence.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/descriptor_wise_method_analysis/method/hierarchical_max_avg.pdf", plot_title="Hierarchical (Max. Avg. Correlation)")
plot_descriptor_occurrence(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/method_wise_desc_presence/hierarchical_min_avg_descriptor_occurrence.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/descriptor_wise_method_analysis/method/hierarchical_min_avg.pdf", plot_title="Hierarchical (Min. Avg. Correlation)")

plot_descriptor_occurrence(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/desc_method_wise/band1_descriptor_occurrence.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/descriptor_wise_method_analysis/bands/band1.pdf", plot_title="Band 1")
plot_descriptor_occurrence(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/desc_method_wise/band2_descriptor_occurrence.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/descriptor_wise_method_analysis/bands/band2.pdf", plot_title="Band 2")
plot_descriptor_occurrence(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/desc_method_wise/band3_descriptor_occurrence.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/descriptor_wise_method_analysis/bands/band3.pdf", plot_title="Band 3")
plot_descriptor_occurrence(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/desc_method_wise/band4_descriptor_occurrence.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/descriptor_wise_method_analysis/bands/band4.pdf", plot_title="Band 4")

plot_descriptor_occurrence(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/band_wise_analysis/10_descriptor_occurrence.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/descriptor_wise_method_analysis/desc_counts/10_descriptors.pdf", plot_title="10 Descriptors")
plot_descriptor_occurrence(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/band_wise_analysis/15_descriptor_occurrence.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/descriptor_wise_method_analysis/desc_counts/15_descriptors.pdf", plot_title="15 Descriptors")
plot_descriptor_occurrence(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/band_wise_analysis/20_descriptor_occurrence.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/descriptor_wise_method_analysis/desc_counts/20_descriptors.pdf", plot_title="20 Descriptors")
plot_descriptor_occurrence(input_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/band_wise_analysis/25_descriptor_occurrence.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/descriptor_wise_method_analysis/desc_counts/25_descriptors.pdf", plot_title="25 Descriptors")
