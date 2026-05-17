# =========================
# Libraries
# =========================
library(readr)
library(dplyr)
library(ggplot2)

# =========================
# Cleaning Function
# =========================

clean_results <- function(df) {
  
  # Keep numeric columns
  numeric_df <- df %>%
    select(where(is.numeric))
  
  # Retain k column
  numeric_df$k <- df$k
  
  # Aggregate by k
  cleaned_df <- numeric_df %>%
    group_by(k) %>%
    summarise(across(everything(), mean), .groups = "drop") %>%
    arrange(k)
  
  return(cleaned_df)
}

# =========================
# Plotting Function
# =========================

plot_metric <- function(
    df_random,
    df_kpp,
    metric,
    ylabel,
    title,
    output_dir,
    width = 8,
    height = 5
) {
  
  # -------------------------
  # Create plotting dataframe
  # -------------------------
  
  plot_df <- bind_rows(
    data.frame(
      k = df_random$k,
      value = df_random[[metric]],
      Method = "Random Init"
    ),
    
    data.frame(
      k = df_kpp$k,
      value = df_kpp[[metric]],
      Method = "KMeans++ Init"
    )
  )
  
  # -------------------------
  # Plot
  # -------------------------
  
  p <- ggplot(
    plot_df,
    aes(
      x = k,
      y = value,
      color = Method,
      linetype = Method
    )
  ) +
    
    geom_line(linewidth = 1) +
    
    geom_point(size = 2) +
    
    labs(
      title = title,
      x = "k",
      y = ylabel
    ) +
    
    theme_bw() +
    
    theme(
      legend.position = "top",
      
      plot.title = element_text(
        face = "bold",
        hjust = 0.5,
        size = 16
      ),
      
      axis.title = element_text(size = 12),
      
      axis.text = element_text(size = 10)
    )
  
  print(p)
  
  # -------------------------
  # Save
  # -------------------------
  
  ggsave(
    filename = paste0(
      output_dir,
      "/",
      gsub(" ", "_", title),
      ".pdf"
    ),
    plot = p,
    width = width,
    height = height,
    dpi = 300
  )
}

# =========================
# Main Function
# =========================

compare_kmeans_initializations <- function(
    random_input_path,
    kpp_input_path,
    output_dir
) {
  
  # -------------------------
  # Read files
  # -------------------------
  
  df_random <- read_csv(random_input_path)
  df_kpp <- read_csv(kpp_input_path)
  
  # -------------------------
  # Remove unnamed columns
  # -------------------------
  
  df_random <- df_random %>%
    select(-matches("^Unnamed"))
  
  df_kpp <- df_kpp %>%
    select(-matches("^Unnamed"))
  
  # -------------------------
  # Sort
  # -------------------------
  
  df_random <- df_random %>%
    arrange(k)
  
  df_kpp <- df_kpp %>%
    arrange(k)
  
  # -------------------------
  # Clean
  # -------------------------
  
  dfR <- clean_results(df_random)
  dfK <- clean_results(df_kpp)
  
  # -------------------------
  # Generate plots
  # -------------------------
  
  plot_metric(
    dfR,
    dfK,
    metric = "inertia",
    ylabel = "Inertia",
    title = "Elbow Plot",
    output_dir = output_dir
  )
  
  plot_metric(
    dfR,
    dfK,
    metric = "silhouette",
    ylabel = "Silhouette Score",
    title = "Silhouette vs k",
    output_dir = output_dir
  )
  
  plot_metric(
    dfR,
    dfK,
    metric = "calinski_harabasz",
    ylabel = "Calinski-Harabasz Index",
    title = "Calinski-Harabasz vs k",
    output_dir = output_dir
  )
  
  plot_metric(
    dfR,
    dfK,
    metric = "davies_bouldin",
    ylabel = "Davies-Bouldin Index",
    title = "Davies-Bouldin vs k",
    output_dir = output_dir
  )
}

# =========================
# Example Usage
# =========================

compare_kmeans_initializations(
  random_input_path = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/clustering_try_results/kmeans/kmeansrandom.csv",
  kpp_input_path = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/data/clustering_try_results/kmeans/kmeanspp_results.csv",
  output_dir = "/Users/shreyasree/Documents/GitHub/DescriptorClusteringNPSpace/plots/clustering_try_result_analysis/kmeans"
)