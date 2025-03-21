#!/usr/bin/env python3

import sys

import pandas as pd

# INPUT_PATH = "output/user-list.csv"
INPUT_PATH = "output/monthly.csv"
OUTPUT_PATH = "output/barchartrace.csv"


# Modified from HLTB-Barchartrace.py
# Doc:  https://blog.vinfall.com/posts/2023/11/hltb/#bar-chart-race
# Code: https://github.com/Vinfall/hltb/blob/370288b0831d49fd29d720b5343ce3ff98714f2a/HLTB-Barchartrace.py#L47-L103
def calculate_number(dataframe):
    # Sort the DataFrame by 'Date' column in ascending order
    df_sorted = dataframe.sort_values(by="Date")

    # Initialize an empty list to store the calculated 'Count' values
    count_value = []

    # Iterate over each row in the sorted DataFrame
    for _index, row in df_sorted.iterrows():
        # Get the current 'Date' and 'Labels' values
        current_date = row["Date"]
        current_label = row["labels"]

        # Count occurrences of current label in rows with dates up to current date
        count = (
            df_sorted.loc[df_sorted["Date"] <= current_date]
            .loc[df_sorted["labels"] == current_label]
            .shape[0]
        )

        # Append the count to the list of 'Count' values
        count_value.append(count)

    # Add the 'Count' column to the DataFrame
    df_sorted["Count"] = count_value

    # Create a new DataFrame with only the 'Date', 'labels', and 'Count' columns
    df_sorted = df_sorted[["Date", "labels", "Count"]]

    # Drop the duplicate rows
    df_sorted = df_sorted.drop_duplicates()

    # Filter out rows where 'Count' is 0
    df_sorted = df_sorted[df_sorted["Count"] != 0]

    # Filter out rows where 'Date' is later than '2022-10-31'
    # df_sorted = df_sorted[df_sorted['Date'] <= '2022-10-31']

    # Create a new DataFrame with all unique 'Date' and 'labels' combinations
    unique_dates = df_sorted["Date"].unique()
    unique_platforms = df_sorted["labels"].unique()
    new_index = pd.MultiIndex.from_product(
        [unique_dates, unique_platforms], names=["Date", "labels"]
    )
    # new_df = df_sorted.set_index(['Date', "labels"]).reindex(new_index)
    new_df = pd.DataFrame(index=new_index).reset_index()

    # Merge the new DataFrame with the sorted DataFrame
    merged_df = pd.merge(new_df, df_sorted, on=["Date", "labels"], how="left")

    # Forward fill the missing values within each group of same label
    merged_df["Count"] = merged_df.groupby("labels")["Count"].ffill()

    # Fill the first 'Count' value of every label with 0
    merged_df["Count"] = merged_df.groupby("labels")["Count"].transform(
        lambda x: x.fillna(0)
    )

    return merged_df


def format_barchartrace(dataframe, date_type):
    # Rename date_type column to "Date"
    dataframe = dataframe.rename(columns={date_type: "Date"})
    # Calculate Count of platforms at a specific date
    return calculate_number(dataframe)


try:
    with open(INPUT_PATH, encoding="utf-8") as f:
        pass
except FileNotFoundError:
    print(
        "VNDB exported CSV not found.\n\
Please export data via VNDB Query first.\n\
For details, see instructions in README."
    )
    sys.exit()

df_raw = pd.read_csv(INPUT_PATH)
# Accepted vlaues: 'started', 'finished', 'released'
# Note: 'finished' does not work much, which is expected
#       since other labels would not exist if you finish it already
df_mod = format_barchartrace(df_raw, "started")
# Debug preview
print(df_mod.head())
# Export to CSV
df_mod.to_csv(OUTPUT_PATH, index=False, quoting=1)
# Message output
print("Now drop output to https://fabdevgit.github.io/barchartrace")
