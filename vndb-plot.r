library(readr)
library(dplyr)
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

vote_rating_regression(data)
