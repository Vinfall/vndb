#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import glob
import re
import sys

import numpy as np
import pandas as pd

# Convert length estimation to readable time, YMMV
_TO_REPLACE_LEN = (
    # <2h
    ("Very short", "1h"),
    # 2-10h
    ("Short", "3h"),
    # 10-30h
    ("Medium", "10h"),
    # 30-50h
    ("Long", "20h"),
    # >50h
    ("Very long", "30h"),
)

# Replace developer Romaji with aliases
# Alternatively, you can set VNDB display preferences
_TO_REPLACE_DEV = (
    # Transliteration
    ("アージュ", "age"),
    ("アリスソフト", "AliceSoft"),
    ("あっぷりけ", "Applique"),
    ("アークシステムワークス株式会社", "Arc System Works"),
    ("きゃべつそふと", "Cabbage Soft"),
    ("株式会社ガイナックス", "Gainax"),
    ("キッド", "KID"),
    ("コナミ", "KONAMI"),
    ("まどそふと", "Madosoft"),
    ("ま～まれぇど", "Marmalade"),
    ("ナナウィンド", "NanaWind"),
    ("ぱれっと", "Palette"),
    ("レジスタ", "Regista"),
    ("ゆずソフト", "Yuzusoft"),
    ("スパイク・チュンソフト", "Spike Chunsoft"),
    ("スパイク", "Spike"),
    ("チュンソフト", "Chunsoft"),
    ("ワールプール", "Whirlpool"),
    ("エスクード", "ESCUDE"),
    # Alias
    ("株式会社カプコン", "CAPCOM"),
    ("ニトロプラス", "Nitro+"),
    ("パープルソフトウェア", "Purple"),
    ("Juzi Ban", "橘子班"),
    # Imprint
    ("ブルゲLIGHT", "Blue Gale"),
    ("MOONSTONE Cherry", "MOONSTONE"),
    ("あかべぇそふとすりぃ", "AKABEiSOFT"),
)


def replace_length(row):
    if "LengthDP" in row.index and row["LengthDP"] in _TO_REPLACE_LEN:
        row["Length"] = _TO_REPLACE_LEN[row["LengthDP"]]
        row["LengthDP"] = 0
    return row


def convert_to_time_string(length_str):
    hours, minutes = 0, 0
    # Extract hours and minutes from the matched string
    hour_match = re.search(r"(\d+)h", length_str)
    if hour_match:
        hours = int(hour_match.group(1))
    minute_match = re.search(r"(\d+)m", length_str)
    if minute_match:
        minutes = int(minute_match.group(1))
    # Convert hours and minutes to time string
    time_str = f"{hours:02d}:{minutes:02d}"
    return time_str


# Split Length and LengthDP like `18h (9)`, also works for length votes
def split_length(df, is_lengthvotes):
    # Initialize length votes dataframe to avoid KeyError
    if is_lengthvotes:
        # Rename the "Time" column to "Length"
        df.rename(columns={"Time": "Length"}, inplace=True)
    # Loop through each row
    for index, row in df.iterrows():
        if not is_lengthvotes:
            for pair in _TO_REPLACE_DEV:
                if pair[0] in str(row["Developer"]):
                    df.at[index, "Developer"] = pair[1]

        # Check and split Length and LengthDP if necessary
        for pair in _TO_REPLACE_LEN:
            # Convert length estimation like `Short`
            if pair[0] in str(row["Length"]):
                df.at[index, "Length"] = pair[1]
                # Estimated length has -1 lengthDP
                df.at[index, "LengthDP"] = -1
                # Exit inner loop once replaced to ensure conversion is only done once
                break
            # Split Length and LengthDP like `18h (9)`
            else:
                length_data = df.at[index, "Length"]
                if isinstance(length_data, str):
                    # Length vote is simpler
                    if is_lengthvotes:
                        match = re.search(r"(\d+h\d+m|\d+h|\d+m)", length_data)
                        if match:
                            length_str = match.group(1)
                            # Convert length like `12h`, `2h3m` to `12:00` and `02:03`
                            time_str = convert_to_time_string(length_str)
                            df.at[index, "Length"] = time_str
                    # User list is more complicated
                    else:
                        match = re.search(
                            r"(\d+h\d+m|\d+h|\d+m)\s\((\d+)\)", length_data
                        )
                        if match:
                            length_str = match.group(1)
                            # Convert length like `12h`, `2h3m` to `12:00` and `02:03`
                            time_str = convert_to_time_string(length_str)
                            df.at[index, "Length"] = time_str
                            # Make sure LengthDP is integer
                            df.at[index, "LengthDP"] = int(match.group(2))

    # Apply the replacement function
    df = df.apply(replace_length, axis=1)

    return df


# Make already nicely exported CSV more awesome
def sanitized_dataframe(df):
    # Flag length votes dataframe
    is_lengthvotes = bool("Time" in df.columns)

    if not is_lengthvotes:
        # Split df["Rating"] into df["Rating"] and df["RatingDP"]
        df[["Rating", "RatingDP"]] = df["Rating"].str.extract(r"(\d+\.\d+)\s\((\d+)\)")

    # Split Length into Length and LengthDP
    df = split_length(df, is_lengthvotes)

    # Replace "-" (implying null vote/speed) with NaN
    df.replace("-", np.nan, inplace=True)

    # Exclude blacklisted games
    # df = df[df["Blacklisted"] != "✓"]

    # Reorder the columns
    if is_lengthvotes:
        df = df[
            [
                "Date",
                "Title",
                "Length",
                "Speed",
                "Rel",
                "Notes",
            ]
        ]
    else:
        df = df[
            [
                "Vote",
                "Rating",
                "RatingDP",
                "Labels",
                "Title",
                "Developer",
                "Start date",
                "Finish date",
                "Release date",
                "Length",
                "LengthDP",
            ]
        ]

    return df


# Read CSV file
file_list = glob.glob("vndb-lengthvotes-export-*.csv") + glob.glob(
    "vndb-list-export-*.csv"
)
if len(file_list) > 0:
    # Sanitize every file
    for filepath in file_list:
        if "vndb-list-export-" in filepath:
            new_file_name = filepath.replace(
                "vndb-list-export-", "vndb-list-sanitized-"
            )
        else:
            new_file_name = filepath.replace(
                "vndb-lengthvotes-export-", "vndb-lengthvotes-sanitized-"
            )
        df_raw = pd.read_csv(filepath)
        df_mod = sanitized_dataframe(df_raw)

        # Debug preview
        print(df_mod.head())

        # Export to CSV
        df_mod.to_csv(new_file_name, index=False, quoting=1)
else:
    print(
        "VNDB exported CSV not found.\n\
Please install VNDB List Export and export first.\n\
You can get it from https://github.com/Vinfall/UserScripts#list."
    )
    sys.exit()
