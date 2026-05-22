library(readr)
library(dplyr)
library(stringr)
library(ggplot2)
library(reshape2)

input_folder <- "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/method_analysis/bands_counts"
output_folder <- "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/method_comparison/bands_vary"

dir.create(output_folder, recursive = TRUE, showWarnings = FALSE)

files <- list.files(input_folder, pattern = "\\.csv$", full.names = TRUE)

for(file in files){
  
  df <- read_csv(file, show_col_types = FALSE) %>%
    filter(analysis_type == "overlap", str_detect(comparison, "vs"))
  
  file_name <- tools::file_path_sans_ext(basename(file))
  
  desc_count <- as.numeric(str_split(file_name, "_")[[1]][1])
  
  bands <- sort(unique(unlist(str_split(df$comparison, " vs "))))
  
  mat <- matrix(
    1,
    nrow = length(bands),
    ncol = length(bands),
    dimnames = list(bands, bands)
  )
  
  for(i in 1:nrow(df)){
    
    comps <- str_split(df$comparison[i], " vs ")[[1]]
    
    if(length(comps) != 2) next
    
    b1 <- comps[1]
    b2 <- comps[2]
    
    overlap <- df$n_common[i]
    
    union_size <- desc_count + desc_count - overlap
    
    jaccard <- overlap / union_size
    
    mat[b1, b2] <- jaccard
    mat[b2, b1] <- jaccard
  }
  
  heatmap_df <- melt(mat)
  
  p <- ggplot(
    heatmap_df,
    aes(Var1, Var2, fill = value)
  ) +
    geom_tile(color = "white") +
    geom_text(aes(label = round(value, 2)), size = 4) +
    scale_fill_gradient(
      low = "white",
      high = "darkgreen"
    ) +
    labs(
      title = file_name,
      x = "Band",
      y = "Band",
      fill = "Jaccard"
    ) +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      panel.grid = element_blank()
    )
  
  ggsave(
    filename = file.path(output_folder, paste0(file_name, "_heatmap.pdf")),
    plot = p,
    width = 5,
    height = 5,
    dpi = 300
  )
  
  print(paste("Saved:", file_name))
}