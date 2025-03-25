#!/usr/bin/env python3

import glob
import sys

import pandas as pd


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
        current_label = row["Labels"]

        # Count occurrences of current label in rows with dates up to current date
        count = (
            df_sorted.loc[df_sorted["Date"] <= current_date]
            .loc[df_sorted["Labels"] == current_label]
            .shape[0]
        )

        # Append the count to the list of 'Count' values
        count_value.append(count)

    # Add the 'Count' column to the DataFrame
    df_sorted["Count"] = count_value

    # Create a new DataFrame with only the 'Date', 'Labels', and 'Count' columns
    df_sorted = df_sorted[["Date", "Labels", "Count"]]

    # Drop the duplicate rows
    df_sorted = df_sorted.drop_duplicates()

    # Filter out rows where 'Count' is 0
    df_sorted = df_sorted[df_sorted["Count"] != 0]

    # Filter out rows where 'Date' is later than '2022-10-31'
    # df_sorted = df_sorted[df_sorted['Date'] <= '2022-10-31']

    # Create a new DataFrame with all unique 'Date' and 'Labels' combinations
    unique_dates = df_sorted["Date"].unique()
    unique_platforms = df_sorted["Labels"].unique()
    new_index = pd.MultiIndex.from_product(
        [unique_dates, unique_platforms], names=["Date", "Labels"]
    )
    # new_df = df_sorted.set_index(['Date', "Labels"]).reindex(new_index)
    new_df = pd.DataFrame(index=new_index).reset_index()

    # Merge the new DataFrame with the sorted DataFrame
    merged_df = pd.merge(new_df, df_sorted, on=["Date", "Labels"], how="left")

    # Forward fill the missing values within each group of same label
    merged_df["Count"] = merged_df.groupby("Labels")["Count"].ffill()

    # Fill the first 'Count' value of every label with 0
    merged_df["Count"] = merged_df.groupby("Labels")["Count"].transform(
        lambda x: x.fillna(0)
    )

    return merged_df


def format_barchartrace(dataframe, date_type):
    # Rename date_type column to "Date"
    dataframe = dataframe.rename(columns={date_type: "Date"})
    # Calculate Count of platforms at a specific date
    return calculate_number(dataframe)


# Read CSV file
file_list = glob.glob("vndb-list-export-*.csv")
if len(file_list) > 0:
    # Sanitize every file
    for filepath in file_list:
        new_file_name = filepath.replace("vndb-list-export-", "vndb-list-barchartrace-")
        df_raw = pd.read_csv(filepath)
        # Accepted vlaues: 'Start date', 'Finish date', 'Release date'
        # Note: 'Finish date' does not work much, which is expected
        #       since other labels would not exist if you finish it already
        df_mod = format_barchartrace(df_raw, "Start date")
        # Debug preview
        print(df_mod.head())
        # Export to CSV
        df_mod.to_csv(new_file_name, index=False, quoting=1)
else:
    print(
        "VNDB exported CSV not found.\n\
Please install VNDB List Export and export first.\n\
You can get it from https://github.com/Vinfall/UserScripts#vndb-list-export."
    )
    sys.exit()

# Seperate this to avoid message flooding in loops
print("Now drop output to https://fabdevgit.github.io/barchartrace")
