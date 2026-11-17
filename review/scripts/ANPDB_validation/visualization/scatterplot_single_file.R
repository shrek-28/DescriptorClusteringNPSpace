
#!/usr/bin/env Rscript

library(ggplot2)

# =========================================================
# Argument Parser
# =========================================================

parse_args <- function() {

  args <- commandArgs(trailingOnly = TRUE)

  defaults <- list(
    input = NULL,
    x_col = NULL,
    y_col = NULL,
    output = NULL,
    point_color = "pink",
    point_alpha = 0.7,
    point_size = 1,
    regression_color = "#DD8452",
    regression_width = 1,
    show_confidence_interval = TRUE,
    title = NULL,
    x_label = NULL,
    y_label = NULL,
    annotation_size = 4,
    annotation_hjust = 1.1,
    annotation_vjust = -0.5,
    width = 8,
    height = 6
  )

  # -------------------------
  # Help
  # -------------------------

  if ("--help" %in% args || "-h" %in% args) {

    cat("
Usage:
  Rscript scatterplot.R --input FILE --x-col COLUMN --y-col COLUMN --output FILE [OPTIONS]

Required:
  --input                     Input CSV file
  --x-col                     X-axis column name
  --y-col                     Y-axis column name
  --output                    Output plot file

Point aesthetics:
  --point-color               Point color (default: pink)
  --point-alpha               Point transparency (default: 0.7)
  --point-size                Point size (default: 1)

Regression aesthetics:
  --regression-color          Regression line color
  --regression-width          Regression line width
  --show-confidence-interval  Show confidence interval (TRUE/FALSE)

Labels:
  --title                     Plot title
  --x-label                   X-axis label
  --y-label                   Y-axis label

Annotations:
  --annotation-size           Annotation text size
  --annotation-hjust          Horizontal annotation position
  --annotation-vjust          Vertical annotation position

Figure:
  --width                     Figure width (default: 8)
  --height                    Figure height (default: 6)

")

    quit(status = 0)
  }

  # -------------------------
  # Validate argument pairs
  # -------------------------

  if (length(args) %% 2 != 0) {
    stop("Arguments must be supplied as --option value pairs.")
  }

  # -------------------------
  # Parse arguments
  # -------------------------

  for (i in seq(1, length(args), by = 2)) {

    key <- gsub("-", "_", sub("^--", "", args[i]))

    value <- args[i + 1]

    if (startsWith(args[i], "--") && key %in% names(defaults)) {

      defaults[[key]] <- value

    } else {

      stop(paste("Unknown argument:", args[i]))
    }
  }

  # -------------------------
  # Required arguments
  # -------------------------

  required <- c(
    "input",
    "x_col",
    "y_col",
    "output"
  )

  for (key in required) {

    if (is.null(defaults[[key]])) {
      stop(paste("Required argument missing:", key))
    }
  }

  # -------------------------
  # Numeric arguments
  # -------------------------

  numeric_args <- c(
    "point_alpha",
    "point_size",
    "regression_width",
    "annotation_size",
    "annotation_hjust",
    "annotation_vjust",
    "width",
    "height"
  )

  for (key in numeric_args) {

    defaults[[key]] <- as.numeric(defaults[[key]])

    if (length(defaults[[key]]) != 1 ||
        !is.finite(defaults[[key]])) {

      stop(paste("Invalid numeric argument:", key))
    }
  }

  # -------------------------
  # Logical arguments
  # -------------------------

  defaults$show_confidence_interval <-
    tolower(defaults$show_confidence_interval)

  if (!(defaults$show_confidence_interval %in% c("true", "false"))) {
    stop("--show-confidence-interval must be TRUE or FALSE")
  }

  defaults$show_confidence_interval <-
    as.logical(defaults$show_confidence_interval)

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
# Validate Columns
# =========================================================

if (!(args$x_col %in% colnames(df))) {
  stop(paste(args$x_col, "not found"))
}

if (!(args$y_col %in% colnames(df))) {
  stop(paste(args$y_col, "not found"))
}

# =========================================================
# Extract Columns
# =========================================================

x <- df[[args$x_col]]
y <- df[[args$y_col]]

# =========================================================
# Numeric Validation
# =========================================================

if (!is.numeric(x) || !is.numeric(y)) {
  stop("Both columns must be numeric")
}

# =========================================================
# Remove Invalid Values
# =========================================================

valid <- is.finite(x) & is.finite(y)

x <- x[valid]
y <- y[valid]

if (length(x) < 3) {
  stop("At least three valid observations are required")
}

if (length(unique(x)) < 2) {
  stop("X column must contain at least two unique values")
}

# =========================================================
# Regression
# =========================================================

model <- lm(y ~ x)

intercept <- coef(model)[1]
slope <- coef(model)[2]

r2 <- summary(model)$r.squared
r <- cor(x, y)

eq_label <- paste0(
  "y = ",
  round(slope, 3),
  "x + ",
  round(intercept, 3),
  "\nR² = ",
  round(r2, 3),
  "\nr = ",
  round(r, 3)
)

# =========================================================
# Plot Dataframe
# =========================================================

plot_df <- data.frame(
  x = x,
  y = y
)

# =========================================================
# Default Labels
# =========================================================

plot_title <- args$title

if (is.null(plot_title)) {
  plot_title <- paste(args$x_col, "vs", args$y_col)
}

x_label <- args$x_label

if (is.null(x_label)) {
  x_label <- args$x_col
}

y_label <- args$y_label

if (is.null(y_label)) {
  y_label <- args$y_col
}

# =========================================================
# Plot
# =========================================================

p <- ggplot(
  plot_df,
  aes(
    x = x,
    y = y
  )
) +

  geom_point(
    color = args$point_color,
    alpha = args$point_alpha,
    size = args$point_size
  ) +

  geom_smooth(
    method = "lm",
    se = args$show_confidence_interval,
    color = args$regression_color,
    linewidth = args$regression_width
  ) +

  annotate(
    "text",
    x = Inf,
    y = -Inf,
    label = eq_label,
    hjust = args$annotation_hjust,
    vjust = args$annotation_vjust,
    size = args$annotation_size
  ) +

  labs(
    title = plot_title,
    x = x_label,
    y = y_label
  ) +

  theme_minimal(base_size = 14) +

  theme(
    plot.title = element_text(
      face = "bold",
      hjust = 0.5
    ),

    axis.title = element_text(
      face = "bold"
    ),

    panel.grid.minor = element_blank()
  )

# =========================================================
# Print
# =========================================================

print(p)

# =========================================================
# Save
# =========================================================

ggsave(
  filename = args$output,
  plot = p,
  width = args$width,
  height = args$height,
  dpi = 300
)

cat("Plot saved:", args$output, "\n")
