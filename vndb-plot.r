# Tidyverse
library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(gridExtra)
library(lubridate)
# Miscellaneous
library(corrplot)

# Get all files matching the pattern
files <- list.files(pattern = "vndb-list-sanitized-.*\\.csv")

# Check if any files were found
if (length(files) == 0) {
  stop("VNDB sanitized CSV not found.\n
    Please run vndb-sanitizer.py first.")
}

# Read the first matching file into a data frame with UTF-8 encoding
data <- read_csv(files[1], locale = locale(encoding = "UTF-8"))

# Convert score to numeric
data$Vote <- as.numeric(data$Vote)
data$Rating <- as.numeric(data$Rating)
# Convert Length string into float
data <- data %>%
  mutate(
    # Match strings like "12h34m"
    Hours = as.numeric(str_extract(Length, "\\d+(?=h)")),
    Minutes = as.numeric(str_extract(Length, "\\d+(?=m)")),
    # Replace NA w/ 0
    Hours = replace_na(Hours, 0),
    Minutes = replace_na(Minutes, 0),
    # Add up minutes & hours
    TotalMinutes = Hours * 60 + Minutes
  ) %>%
  select(-Hours, -Minutes, TotalMinutes)
# Convert dates
data$`Start date` <- as.Date(data$`Start date`)
data$`Finish date` <- as.Date(data$`Finish date`)
data$`Release date` <- as.Date(data$`Release date`)

temporal_stat <- function(data) {
  # Sort data ascendingly
  data <- arrange(
    data,
    data$`Start date`, data$`Finish date`, data$`Release date`
  )

  # Generate plot
  p1 <- ggplot() +
    # Excel style
    # Vote
    geom_line(data = data, aes(
      x = `Start date`, y = Vote,
      group = 1, color = "Vote"
    )) +
    geom_point(
      data = data, aes(x = `Start date`, y = Vote),
      color = "#4472c4"
    ) +
    # Rating
    geom_line(data = subset(data, Rating != 0), aes(
      x = `Start date`, y = Rating,
      group = 1, color = "Rating"
    )) +
    # Only fill if not zero
    geom_point(
      data = data, aes(x = `Start date`, y = Rating),
      color = "#f8766d"
    ) +
    # Minimum score line
    geom_hline(
      yintercept = 4,
      linewidth = 1, linetype = "dotted", color = "black"
    ) +
    # Vertical starting line
    geom_vline(
      xintercept = as.numeric(as.Date("2020-11-24")),
      linewidth = 1, linetype = "dotted", color = "black"
    ) +
    scale_x_date(
      # Ignore data before a certain date
      limits = as.Date(c("2020-11-01", max(data$`Start date`))),
      # Grouped by month
      date_breaks = "1 month", date_labels = "%Y-%m"
    ) +
    labs(title = "Vote/Rating over Time", x = "Date", y = "Value") +
    # Rotate label so that it can be shown
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

  # Save plot
  ggsave("output/temporal-stat.png",
    plot = p1,
    width = 20, height = 5, units = "in", dpi = 300
  )
}

vote_rating_regression <- function(data) {
  # Filter finished VNs w/ vote stats
  filtered_data <- filter(data, Labels == "Finished" & Vote != 0 & Rating != 0) # nolint

  # Perform linear regression
  relation <- lm(Vote ~ Rating, data = filtered_data)

  # Display summary of the linear regression model
  # print((summary(relation)))

  # Generate a scatter plot with regression line
  plot <- ggplot(filtered_data, aes(x = Rating, y = Vote)) + # nolint
    # Add scatter plot points
    geom_point(alpha = 0.7, size = 1.0, shape = 21, stroke = 1) +
    # Add w/o confidence interval
    geom_smooth(
      method = "auto", se = FALSE, color = "blue"
    ) +
    geom_hline(
      yintercept = 4,
      linewidth = 1, linetype = "dotted", color = "black"
    ) +
    geom_vline(
      xintercept = 9,
      linewidth = 1, linetype = "dotted", color = "black"
    ) +
    labs(title = "Rating x Vote Regression", x = "Rating", y = "Vote") +
    coord_cartesian(xlim = c(5, 9), ylim = c(4, 10)) +
    theme_linedraw()

  # Save plot
  ggsave("output/regression-vote-rating.png", plot,
    width = 8, height = 6, units = "in", dpi = 300
  )
}

stat_correlogram <- function(data) {
  # Filter finished VNs w/ vote stats
  filtered_data <- filter(data, Labels == "Finished" & Vote != 0 & Rating != 0 & Length != 0) # nolint

  # Correlate
  numeric_data <- filtered_data[
    , c("Vote", "Rating", "RatingDP", "TotalMinutes", "LengthDP")
  ]
  cor_matrix <- cor(numeric_data, use = "complete.obs")

  # Generate correlation matrix
  png(filename = "output/corrplot-stat.png")
  corrplot(cor_matrix,
    method = "circle"
    # title = "Stat Correlation Matrix",
  )
  dev.off()
  # TODO1: sharpen output image and make title fully visible
  # TODO2: use ggplot instead of corrplot
  # ggsave("output/corrplot-stat.png", plot = replayPlot(p1), width = 8, height = 7, units = "in", dpi = 300 ) # nolint
}

vote_length_regression <- function(data) {
  # Filter finished VNs w/ real length (instead of guessed one)
  # Check "_TO_REPLACE_LEN" in `vndb-sanitizer.py`
  filtered_data <- filter(data, Labels == "Finished" & Vote != 0 & LengthDP != -1) # nolint

  # Perform linear regression
  relation <- lm(Vote ~ TotalMinutes, data = filtered_data)

  # Display summary of the linear regression model
  # print((summary(relation)))

  plot <- ggplot(filtered_data, aes(x = TotalMinutes, y = Vote)) + # nolint
    # Add scatter plot points
    geom_point(alpha = 0.7, size = 1.0, shape = 21, stroke = 1) +
    # Add w/o confidence interval
    geom_smooth(
      method = "auto", se = FALSE, color = "yellow"
    ) +
    geom_hline(
      yintercept = 4,
      linewidth = 1, linetype = "dotted", color = "black"
    ) +
    geom_vline(
      xintercept = 5000,
      linewidth = 1, linetype = "dotted", color = "black"
    ) +
    labs(title = "Length x Vote Regression", x = "Length", y = "Vote") +
    coord_cartesian(xlim = c(0, 5000), ylim = c(4, 10)) +
    theme_linedraw()

  # Save plot
  ggsave("output/regression-vote-length.png", plot,
    width = 8, height = 6, units = "in", dpi = 300
  )
}

header_bar <- function(data, label) {
  label_var <- ensym(label)
  label_str <- as.character(label_var)

  # Count the frequency of each Labels and arrange in descending order
  label_counts <- data %>%
    count(!!label_var) %>%
    arrange(desc(n))

  bar <- ggplot(data = label_counts) +
    geom_bar(mapping = aes(
      x = reorder(!!label_var, -n), y = n, fill = as.factor(!!label_var)
    ), stat = "identity", show.legend = FALSE, width = 1) +
    theme(aspect.ratio = 1) +
    scale_fill_brewer() +
    labs(x = NULL, y = NULL)

  # Flip x and y
  bar1 <- bar + coord_flip()
  # Polar
  bar2 <- bar + coord_polar()
  plots <- list(bar1, bar2)

  filename <- paste("output/", label_str, "-bar.png", sep = "")
  ggsave(filename,
    gridExtra::grid.arrange(grobs = plots, ncol = 2),
    width = 10, height = 5, units = "in", dpi = 300
  )
}

weekly_vn_heatmap <- function(data) {
  # Filter finished VNs w/ finish date
  finished_data <- filter(data, Labels == "Finished" & !is.null(`Finish date`)) # nolint
  # Ascending sort by Start Date and Finish Date
  finished_data <- finished_data[
    order(finished_data$`Start date`, finished_data$`Finish date`),
  ]

  # Split into year & week
  finished_data$year <- year(finished_data$`Start date`)
  finished_data$week <- isoweek(finished_data$`Start date`)

  # Counted weekly VNs, devided by year
  weekly_counts_by_year <- finished_data %>%
    group_by(year, week) %>%
    summarise(count = n(), .groups = "drop")

  # Generate heatmap for every year
  heatmap <- ggplot(
    # Omit NA year
    weekly_counts_by_year %>% filter(!is.na(year)),
    aes(x = week, y = factor(year))
  ) +
    geom_tile(aes(fill = count), color = "white") +
    scale_fill_gradientn(
      # GitHub Style, reverted, misleading but more beautiful
      # colors = c("#196127", "#239a3b", "#7bc96f", "#c6e48b", "#ebedf0"),
      # GitHub Style
      colors = c("#ebedf0", "#c6e48b", "#7bc96f", "#239a3b", "#196127"),
      # Default scale
      # values = scales::rescale(c(0, 0.1, 0.5, 0.9, 1)),
      # My preferred scale, as 10 VNs per week is rarely achieved, 4 is enough
      values = scales::rescale(c(0, 0.1, 0.2, 0.4, 1)),
      name = "Count"
    ) +
    # minimal theme looks weird
    theme_light() +
    theme(
      axis.title.y = element_blank(),
      axis.text.y = element_text(angle = 0),
      axis.ticks.y = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      strip.background = element_blank(),
      strip.text.y = element_text(angle = 0)
    ) +
    labs(
      title = "Weekly VN Heatmap",
      x = "Week", y = "Year", fill = "Count"
    )

  # Save plot
  ggsave("output/heatmap-weekly-vn.png",
    plot = heatmap,
    width = 10, height = 5, units = "in", dpi = 300
  )
}

temporal_stat(data)
# vote_rating_regression(data)
# vote_length_regression(data)
# stat_correlogram(data)

# header_bar(data, "Labels")
# Be careful, these would throw alota of warnings
# header_bar(data, "Vote")
# header_bar(data, "Developer")

# weekly_vn_heatmap(data)
