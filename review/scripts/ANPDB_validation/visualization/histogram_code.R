
#!/usr/bin/env Rscript

library(ggplot2)

# =========================================================
# Argument Parser
# =========================================================

parse_args <- function() {

  args <- commandArgs(trailingOnly = TRUE)

  defaults <- list(
    input = NULL,
    column = NULL,
    output = NULL,
    binwidth = NA,
    fill_color = "darkgreen",
    border_color = "white",
    fill_alpha = 0.9,
    mean_line_color = "black",
    median_line_color = "black",
    mean_linetype = "dashed",
    median_linetype = "dotted",
    line_width = 0.9,
    count_text_size = 3,
    stats_text_size = 4,
    title = NULL,
    x_label = NULL,
    y_label = "Count",
    width = 10,
    height = 6
  )

  if ("--help" %in% args || "-h" %in% args) {

    cat("
Usage:
  Rscript histogram.R --input FILE --column COLUMN --output FILE [OPTIONS]

Required:
  --input                 Input CSV file
  --column                Numeric column to plot
  --output                Output plot file

Binning:
  --binwidth              Histogram bin width (default: automatic)

Histogram aesthetics:
  --fill-color            Fill color (default: #4C72B0)
  --border-color          Border color (default: white)
  --fill-alpha            Fill transparency (default: 0.9)

Mean / Median lines:
  --mean-line-color       Mean line color
  --median-line-color     Median line color
  --mean-linetype         Mean line type
  --median-linetype       Median line type
  --line-width            Line width

Annotations:
  --count-text-size       Bin count text size
  --stats-text-size       Statistics text size

Labels:
  --title                 Plot title
  --x-label               X-axis label
  --y-label               Y-axis label

Figure:
  --width                 Figure width (default: 10)
  --height                Figure height (default: 6)

")

    quit(status = 0)
  }

  if (length(args) %% 2 != 0) {
    stop("Arguments must be supplied as --option value pairs.")
  }

  for (i in seq(1, length(args), by = 2)) {

    key <- sub("^--", "", args[i])
    value <- args[i + 1]

    if (startsWith(args[i], "--") && key %in% names(defaults)) {

      defaults[[key]] <- value

    } else {

      stop(paste("Unknown argument:", args[i]))
    }
  }

  if (is.null(defaults$input) ||
      is.null(defaults$column) ||
      is.null(defaults$output)) {

    stop("Required arguments: --input, --column, --output")
  }

  numeric_args <- c(
    "binwidth",
    "fill_alpha",
    "line_width",
    "count_text_size",
    "stats_text_size",
    "width",
    "height"
  )

  for (key in numeric_args) {

    defaults[[key]] <- as.numeric(defaults[[key]])

    if (length(defaults[[key]]) != 1 ||
        is.na(defaults[[key]]) && key != "binwidth") {

      stop(paste("Invalid numeric argument:", key))
    }
  }

  defaults
}

args <- parse_args()

# =========================================================
# Read Data
# =========================================================

df <- read.csv(
  args$input,
  stringsAsFactors = FALSE
)

# =========================================================
# Validate Column
# =========================================================

if (!(args$column %in% colnames(df))) {
  stop(paste("Column", args$column, "not found"))
}

x <- df[[args$column]]

if (!is.numeric(x)) {
  stop("Selected column must be numeric")
}

x <- x[is.finite(x)]

if (length(x) < 2) {
  stop("At least two finite numeric observations are required")
}

n <- length(x)

# =========================================================
# Statistics
# =========================================================

mean_x <- mean(x)
median_x <- median(x)
sd_x <- sd(x)
var_x <- var(x)

skewness_x <- if (sd_x > 0) {
  sum((x - mean_x)^3) / (n * sd_x^3)
} else {
  NA_real_
}

kurtosis_x <- if (sd_x > 0) {
  sum((x - mean_x)^4) / (n * sd_x^4) - 3
} else {
  NA_real_
}

label_text <- paste0(
  "Mean = ", round(mean_x, 3), "\n",
  "Median = ", round(median_x, 3), "\n",
  "SD = ", round(sd_x, 3), "\n",
  "Var = ", round(var_x, 3), "\n",
  "Skew = ", round(skewness_x, 3), "\n",
  "Kurtosis = ", round(kurtosis_x, 3)
)

# =========================================================
# Automatic Binning
# =========================================================

xmin <- min(x)
xmax <- max(x)

binwidth <- args$binwidth

if (is.na(binwidth)) {

  raw_bw <- (xmax - xmin) / 20

  if (raw_bw > 0) {

    scale_val <- 10^floor(log10(raw_bw))

    candidates <- c(1, 2, 5, 10) * scale_val

    binwidth <- candidates[
      which.min(abs(candidates - raw_bw))
    ]

  } else {

    binwidth <- 1
  }
}

if (binwidth <= 0) {
  stop("Bin width must be positive")
}

xmin_clean <- floor(xmin / binwidth) * binwidth
xmax_clean <- ceiling(xmax / binwidth) * binwidth

if (xmin_clean == xmax_clean) {
  xmin_clean <- xmin_clean - binwidth
  xmax_clean <- xmax_clean + binwidth
}

bin_edges <- seq(
  xmin_clean,
  xmax_clean,
  by = binwidth
)

# =========================================================
# Histogram Counts
# =========================================================

counts <- hist(
  x,
  breaks = bin_edges,
  plot = FALSE
)

count_df <- data.frame(
  mids = counts$mids,
  counts = counts$counts
)

# =========================================================
# Save Bin Table
# =========================================================

table_file <- sub(
  "\\.(png|pdf|jpg|jpeg)$",
  "_bin_table.csv",
  args$output,
  ignore.case = TRUE
)

write.csv(
  data.frame(
    lower = bin_edges[-length(bin_edges)],
    upper = bin_edges[-1],
    counts = counts$counts
  ),
  table_file,
  row.names = FALSE
)

# =========================================================
# Default Labels
# =========================================================

plot_title <- args$title

if (is.null(plot_title)) {
  plot_title <- paste("Distribution of", args$column)
}

x_label <- args$x_label

if (is.null(x_label)) {
  x_label <- args$column
}

# =========================================================
# Plot
# =========================================================

p <- ggplot(
  data.frame(x = x),
  aes(x = x)
) +

  geom_histogram(
    aes(y = after_stat(count)),
    breaks = bin_edges,
    fill = args$fill_color,
    color = args$border_color,
    alpha = args$fill_alpha
  ) +

  geom_vline(
    aes(
      xintercept = mean_x,
      linetype = "Mean"
    ),
    color = args$mean_line_color,
    linewidth = args$line_width
  ) +

  geom_vline(
    aes(
      xintercept = median_x,
      linetype = "Median"
    ),
    color = args$median_line_color,
    linewidth = args$line_width
  ) +

  scale_linetype_manual(
    name = "Statistics",
    values = c(
      "Mean" = args$mean_linetype,
      "Median" = args$median_linetype
    )
  ) +

  geom_text(
    data = count_df,
    aes(
      x = mids,
      y = counts,
      label = counts
    ),
    vjust = -0.3,
    size = args$count_text_size
  ) +

  annotate(
    "text",
    x = Inf,
    y = Inf,
    label = label_text,
    hjust = 1.1,
    vjust = 1.1,
    size = args$stats_text_size
  ) +

  labs(
    title = plot_title,
    x = x_label,
    y = args$y_label
  ) +

  coord_cartesian(clip = "off") +

  theme_minimal(base_size = 14) +

  theme(
    plot.title = element_text(
      face = "bold",
      hjust = 0.5
    ),
    axis.title = element_text(
      face = "bold"
    ),
    panel.grid.minor = element_blank(),
    legend.position = "top"
  )

# =========================================================
# Print and Save
# =========================================================

print(p)

ggsave(
  filename = args$output,
  plot = p,
  width = args$width,
  height = args$height,
  dpi = 300
)

cat("Plot saved:", args$output, "\n")
cat("Bin table saved:", table_file, "\n")