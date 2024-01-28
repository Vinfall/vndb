library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)

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
  print((summary(relation)))

  # Generate a scatter plot with regression line
  ggplot(filtered_data, aes(x = Rating, y = Vote)) + # nolint
    geom_point() + # Add scatter plot points
    geom_smooth(method = "lm", se = FALSE) + # Add w/o confidence interval
    labs(title = "Rating x Vote Regression", x = "Rating", y = "Vote")

  plot <- ggplot(filtered_data, aes(x = Rating, y = Vote)) + # nolint
    # Add scatter plot points
    geom_point() +
    # Add w/o confidence interval
    geom_smooth(
      method = "lm", se = FALSE, color = "blue"
    ) +
    labs(title = "Rating x Vote Regression", x = "Rating", y = "Vote")

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
  print((summary(relation)))

  plot <- ggplot(filtered_data, aes(x = TotalMinutes, y = Vote)) + # nolint
    # Add scatter plot points
    geom_point() +
    # Add w/o confidence interval
    geom_smooth(
      method = "lm", se = FALSE, color = "yellow"
    ) +
    labs(title = "Length x Vote Regression", x = "Length", y = "Vote")

  # Save plot
  ggsave("output/regression-vote-length.png", plot,
    width = 8, height = 6, units = "in", dpi = 300
  )
}

vote_rating_regression(data)
vote_length_regression(data)
