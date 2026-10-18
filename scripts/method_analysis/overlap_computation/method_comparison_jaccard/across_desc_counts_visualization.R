library(readr)
library(dplyr)
library(stringr)
library(ggplot2)
library(reshape2)

input_folder <- "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/desc_counts_results"
output_folder <- "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/method_comparison/desc_counts_vary"


dir.create(output_folder, recursive = TRUE, showWarnings = FALSE)

files <- list.files(input_folder, pattern = "\\.csv$", full.names = TRUE)

for(file in files){
  
  df <- read_csv(file, show_col_types = FALSE) %>%
    filter(analysis_type == "overlap", str_detect(comparison, "vs"))
  
  method <- unique(df$method)
  band <- unique(df$band)
  
  desc_levels <- sort(unique(unlist(str_split(df$comparison, " vs "))))
  
  sets <- list()
  
  for(i in 1:nrow(df)){
    
    comps <- str_split(df$comparison[i], " vs ")[[1]]
    if(length(comps) != 2) next
    
    a <- comps[1]
    b <- comps[2]
    
    desc_set <- str_split(df$common_descriptors[i], ",\\s*")[[1]]
    
    sets[[paste(a, b, sep = "_")]] <- list(
      pair = c(a, b),
      set = unique(desc_set)
    )
  }
  
  # build full descriptor sets per node (union across pairs)
  node_sets <- list()
  
  for(n in desc_levels){
    all_desc <- c()
    for(k in names(sets)){
      if(n %in% sets[[k]]$pair){
        all_desc <- c(all_desc, sets[[k]]$set)
      }
    }
    node_sets[[n]] <- unique(all_desc)
  }
  
  # jaccard matrix
  mat <- matrix(
    1,
    nrow = length(desc_levels),
    ncol = length(desc_levels),
    dimnames = list(desc_levels, desc_levels)
  )
  
  for(i in desc_levels){
    for(j in desc_levels){
      
      inter <- length(intersect(node_sets[[i]], node_sets[[j]]))
      uni <- length(union(node_sets[[i]], node_sets[[j]]))
      
      mat[i, j] <- ifelse(uni == 0, 0, inter / uni)
    }
  }
  
  heatmap_df <- melt(mat)
  
  p <- ggplot(heatmap_df, aes(Var1, Var2, fill = value)) +
    geom_tile(color = "white") +
    geom_text(aes(label = round(value, 2)), size = 5) +
    scale_fill_gradient(low = "white", high = "darkgreen") +
    labs(
      title = paste0(method, " | ", band),
      x = "Descriptor Count",
      y = "Descriptor Count",
      fill = "Jaccard"
    ) +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
      axis.text.y = element_text(size = 12),
      panel.grid = element_blank(),
      title = element_text(face = "bold", hjust = 0.5, size = 14)
    )
  
  ggsave(
    filename = file.path(output_folder, paste0(method, "_", band, "_jaccard.pdf")),
    plot = p,
    width = 5,
    height = 5,
    dpi = 300
  )
  
  print(paste("Saved:", method, band))
}