library(readr)
library(dendextend)
library(RColorBrewer)

generate_pretty_dendrogram <- function(
    file_path,
    output_file = NULL,
    desired_clusters = 10,
    linkage_method = "average",
    plot_title = "Hierarchical Clustering Dendrogram",
    width = 15,
    height = 8,
    dpi = 300,
    label_size = 0.7,
    title_size = 1.8
) {
  
  # Read distance matrix
  dist_matrix <- read_csv(
    file_path,
    show_col_types = FALSE
  )
  
  # Convert first column to row names
  dist_matrix <- as.data.frame(dist_matrix)
  rownames(dist_matrix) <- dist_matrix[,1]
  dist_matrix <- dist_matrix[,-1]
  
  # Convert to matrix
  dist_matrix <- as.matrix(dist_matrix)
  
  # Convert to dist object
  dist_object <- as.dist(dist_matrix)
  
  # Hierarchical clustering
  hc <- hclust(
    dist_object,
    method = linkage_method
  )
  
  # Convert to dendrogram
  dend <- as.dendrogram(hc)
  
  # Cluster assignments
  cluster_assignments <- cutree(
    hc,
    k = desired_clusters
  )
  
  # Threshold
  threshold <- sort(
    hc$height,
    decreasing = TRUE
  )[desired_clusters - 1]
  
  # Cluster colors
  cluster_colors <- c(
    "#FF6F61", "#6B5B95", "#88B04B", "#F7CAC9", "#92A8D1",
    "#955251", "#B565A7", "#009B77", "#DD4124", "#45B8AC"
  )
  
  # Extend colors if needed
  if (desired_clusters > length(cluster_colors)) {
    cluster_colors <- colorRampPalette(cluster_colors)(desired_clusters)
  }
  
  # Color branches
  dend <- color_branches(
    dend,
    k = desired_clusters,
    col = cluster_colors
  )
  
  # Color labels
  labels_colors(dend) <- cluster_colors[
    cluster_assignments[order.dendrogram(dend)]
  ]
  
  # Open graphics device
  if (!is.null(output_file)) {
    
    if (grepl("\\.pdf$", output_file, ignore.case = TRUE)) {
      
      pdf(
        file = output_file,
        width = width,
        height = height
      )
      
    } else if (grepl("\\.png$", output_file, ignore.case = TRUE)) {
      
      png(
        filename = output_file,
        width = width,
        height = height,
        units = "in",
        res = dpi
      )
      
    } else {
      
      stop("Output file must end with .pdf or .png")
    }
  }
  
  # Plot margins
  par(
    mar = c(16, 5, 5, 2),
    bg = "white"
  )
  
  # Plot dendrogram without labels
  plot(
    dend,
    main = plot_title,
    ylab = "Distance",
    xlab = "",
    sub = "",
    cex.lab = 1.3,
    cex.axis = 1.1,
    cex.main = title_size,
    font.main = 2,
    leaflab = "none"
  )
  
  # Add threshold line
  abline(
    h = threshold,
    col = "red",
    lty = 2,
    lwd = 2
  )
  
  # Add legend
  legend(
    "topright",
    legend = paste(
      "Threshold =",
      round(threshold, 3)
    ),
    col = "red",
    lty = 2,
    lwd = 2,
    bty = "n",
    cex = 1
  )
  
  # Get label order
  label_order <- order.dendrogram(dend)
  dend_labels <- labels(dend)
  
  # Add rotated labels
  text(
    x = 1:length(dend_labels),
    y = par("usr")[3] - 0.02 * diff(par("usr")[3:4]),
    labels = dend_labels[label_order],
    srt = 45,
    adj = 1,
    xpd = TRUE,
    cex = label_size,
    col = labels_colors(dend)
  )
  
  # Close graphics device
  if (!is.null(output_file)) {
    dev.off()
  }
  
  # Cluster dataframe
  feature_clusters <- data.frame(
    feature = names(cluster_assignments),
    cluster = cluster_assignments
  )
  
  feature_clusters <- feature_clusters[
    order(feature_clusters$cluster),
  ]
  
  # Console output
  print(
    paste(
      "Number of clusters formed:",
      length(unique(feature_clusters$cluster))
    )
  )
  
  print(
    paste(
      "Distance threshold used:",
      round(threshold, 4)
    )
  )
  
  # Return results
  return(list(
    hc = hc,
    dendrogram = dend,
    clusters = feature_clusters,
    threshold = threshold
  ))
}

result1 <- generate_pretty_dendrogram(file_path="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/10_desc/band1_distance_matrix.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering_dendrogams/10_desc/band1.pdf", desired_clusters=10, plot_title="10 Descriptors - Band 1: 0.5 - 0.85")
result1 <- generate_pretty_dendrogram(file_path="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/10_desc/band2_distance_matrix.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering_dendrogams/10_desc/band2.pdf", desired_clusters=10, plot_title="10 Descriptors - Band 2: 0.35 - 0.85")
result1 <- generate_pretty_dendrogram(file_path="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/10_desc/band3_distance_matrix.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering_dendrogams/10_desc/band3.pdf", desired_clusters=10, plot_title="10 Descriptors - Band 3: 0.25 - 0.85")
result1 <- generate_pretty_dendrogram(file_path="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/10_desc/band4_distance_matrix.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering_dendrogams/10_desc/band4.pdf", desired_clusters=10, plot_title="10 Descriptors - Band 4: 0.35 - 0.75")

result1 <- generate_pretty_dendrogram(file_path="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/15_desc/band1_distance_matrix.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering_dendrogams/15_desc/band1.pdf", desired_clusters=15, plot_title="15 Descriptors - Band 1: 0.5 - 0.85")
result1 <- generate_pretty_dendrogram(file_path="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/15_desc/band2_distance_matrix.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering_dendrogams/15_desc/band2.pdf", desired_clusters=15, plot_title="15 Descriptors - Band 2: 0.35 - 0.85")
result1 <- generate_pretty_dendrogram(file_path="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/15_desc/band3_distance_matrix.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering_dendrogams/15_desc/band3.pdf", desired_clusters=15, plot_title="15 Descriptors - Band 3: 0.25 - 0.85")
result1 <- generate_pretty_dendrogram(file_path="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/15_desc/band4_distance_matrix.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering_dendrogams/15_desc/band4.pdf", desired_clusters=15, plot_title="15 Descriptors - Band 4: 0.35 - 0.75")

result1 <- generate_pretty_dendrogram(file_path="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/20_desc/band1_distance_matrix.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering_dendrogams/20_desc/band1.pdf", desired_clusters=20, plot_title="20 Descriptors - Band 1: 0.5 - 0.85")
result1 <- generate_pretty_dendrogram(file_path="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/20_desc/band2_distance_matrix.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering_dendrogams/20_desc/band2.pdf", desired_clusters=20, plot_title="20 Descriptors - Band 2: 0.35 - 0.85")
result1 <- generate_pretty_dendrogram(file_path="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/20_desc/band3_distance_matrix.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering_dendrogams/20_desc/band3.pdf", desired_clusters=20, plot_title="20 Descriptors - Band 3: 0.25 - 0.85")
result1 <- generate_pretty_dendrogram(file_path="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/20_desc/band4_distance_matrix.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering_dendrogams/20_desc/band4.pdf", desired_clusters=20, plot_title="20 Descriptors - Band 4: 0.35 - 0.75")

result1 <- generate_pretty_dendrogram(file_path="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/25_desc/band1_distance_matrix.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering_dendrogams/25_desc/band1.pdf", desired_clusters=25, plot_title="25 Descriptors - Band 1: 0.5 - 0.85")
result1 <- generate_pretty_dendrogram(file_path="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/25_desc/band2_distance_matrix.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering_dendrogams/25_desc/band2.pdf", desired_clusters=25, plot_title="25 Descriptors - Band 2: 0.35 - 0.85")
result1 <- generate_pretty_dendrogram(file_path="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/25_desc/band3_distance_matrix.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering_dendrogams/25_desc/band3.pdf", desired_clusters=25, plot_title="25 Descriptors - Band 3: 0.25 - 0.85")
result1 <- generate_pretty_dendrogram(file_path="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/hierarchical_clustering/max_avg/25_desc/band4_distance_matrix.csv", output_file="/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/hierarchical_clustering_dendrogams/25_desc/band4.pdf", desired_clusters=25, plot_title="25 Descriptors - Band 4: 0.35 - 0.75")
