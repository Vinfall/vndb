library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(scales)

# Get all files matching the pattern
files <- list.files(pattern = "vndb-list-sanitized-.*\\.csv")

# Check if any files were found
if (length(files) == 0) {
  stop("VNDB sanitized CSV not found.\n
    Please run vndb-sanitizer.py first.")
}

# Read the first matching file into a data frame with UTF-8 encoding
data <- read_csv(files[1], locale = locale(encoding = "UTF-8"))

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

vote_length_regression <- function(data) {
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

# vote_rating_regression(data)
# vote_length_regression(data)

header_bar(data, "Labels")
# Be careful, these would throw alota of warnings
# header_bar(data, "Vote")
# header_bar(data, "Developer")
