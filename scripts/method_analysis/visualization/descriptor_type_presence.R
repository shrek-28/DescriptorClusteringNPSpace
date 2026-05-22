# =========================================================
# Descriptor Type Enrichment Plot
# =========================================================

# ---------------- Libraries ----------------
library(ggplot2)
library(readr)

# ---------------- Function ----------------
plot_descriptor_type_summary <- function(
    input_file,
    output_file,
    plot_title = "Descriptor Type Enrichment"
) {
  
  # Libraries
  library(ggplot2)
  library(readr)
  
  # Read CSV
  df <- read_csv(input_file)
  
  # Manual order
  desired_order <- c(
    "physicochemical",
    "pharmacophoric",
    "ring",
    "3D",
    "partial_charge",
    "EState",
    "graph_and_topo"
  )
  
  # Apply factor order
  df$descriptor_type <- factor(
    df$descriptor_type,
    levels = desired_order
  )
  
  # Create plot
  p <- ggplot(
    df,
    aes(
      x = descriptor_type,
      y = total_occurrence
    )
  ) +
    
    geom_col(
      width = 0.7,
      fill = "darkgreen"
    ) +
    
    # Annotate normalized occurrence
    geom_text(
      aes(
        label = round(normalized_occurrence, 2),
        y = total_occurrence + 2
      ),
      size = 4
    ) +
    
    # Labels
    labs(
      title = plot_title,
      x = "Descriptor Type",
      y = "Total Occurrence Count"
    ) +
    
    # Theme
    theme_minimal(base_size = 14) +
    
    theme(
      plot.title = element_text(
        hjust = 0.5,
        face = "bold",
        size = 16
      ),
      
      axis.title = element_text(
        face = "bold"
      ),
      
      axis.text.x = element_text(
        angle = 45,
        hjust = 1,
        face = "bold"
      )
    )
  
  # Save plot
  ggsave(
    filename = output_file,
    plot = p,
    width = 10,
    height = 6,
    dpi = 300
  )
  
  return(p)
}

# ---------------- Example Usage ----------------
plot_descriptor_type_summary(
    input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/descriptor_type_presence/global_summary.csv",
    output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/descriptor_presence_plots/global_presence_plot.pdf",
    plot_title = "Global Enrichment Count"   
)

plot_descriptor_type_summary(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/descriptor_type_presence/methods/greedy_max_coverage_summary.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/descriptor_presence_plots/methods/greedy_max_coverage_presence_plot.pdf", plot_title = "Greedy Maximum Coverage")
plot_descriptor_type_summary(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/descriptor_type_presence/methods/hierarchical_max_avg_summary.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/descriptor_presence_plots/methods/hierarchical_max_avg_presence_plot.pdf", plot_title = "Hierarchical (Maximum Average Correlation)")
plot_descriptor_type_summary(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/descriptor_type_presence/methods/hierarchical_min_avg_summary.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/descriptor_presence_plots/methods/hierarchical_min_avg_presence_plot.pdf", plot_title = "Hierarchical (Minimum Average Correlation)")

plot_descriptor_type_summary(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/descriptor_type_presence/desc_counts/10_summary.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/descriptor_presence_plots/desc_counts/10_descriptors.pdf", plot_title = "10 Descriptors")
plot_descriptor_type_summary(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/descriptor_type_presence/desc_counts/15_summary.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/descriptor_presence_plots/desc_counts/15_descriptors.pdf", plot_title = "15 Descriptors")
plot_descriptor_type_summary(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/descriptor_type_presence/desc_counts/20_summary.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/descriptor_presence_plots/desc_counts/20_descriptors.pdf", plot_title = "20 Descriptors")
plot_descriptor_type_summary(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/descriptor_type_presence/desc_counts/25_summary.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/descriptor_presence_plots/desc_counts/25_descriptors.pdf", plot_title = "25 Descriptors")

plot_descriptor_type_summary(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/descriptor_type_presence/bands/band1_summary.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/descriptor_presence_plots/bands/band1_presence_plot.pdf", plot_title = "Band 1")
plot_descriptor_type_summary(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/descriptor_type_presence/bands/band2_summary.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/descriptor_presence_plots/bands/band2_presence_plot.pdf", plot_title = "Band 2")
plot_descriptor_type_summary(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/descriptor_type_presence/bands/band3_summary.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/descriptor_presence_plots/bands/band3_presence_plot.pdf", plot_title = "Band 3")
plot_descriptor_type_summary(input_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/descriptor_type_presence/bands/band4_summary.csv", output_file = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/descriptor_presence_plots/bands/band4_presence_plot.pdf", plot_title = "Band 4")