#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import glob
import numpy as np
import pandas as pd
import re

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
    # Alias
    ("株式会社カプコン", "CAPCOM"),
    ("ニトロプラス", "Nitro+"),
    ("パープルソフトウェア", "Purple"),
    ("Juzi Ban", "橘子班"),
    # Imprint
    ("ブルゲLIGHT", "Blue Gale"),
    ("MOONSTONE Cherry", "MOONSTONE"),
)


def replace_length(row):
    if row["LengthDP"] in _TO_REPLACE_LEN:
        row["Length"] = _TO_REPLACE_LEN[row["LengthDP"]]
        row["LengthDP"] = 0
    return row


# Make already nicely exported CSV more awesome
def sanitized_dataframe(df):
    # Split df["Rating"] into df["Rating"] and df["RatingDP"]
    df[["Rating", "RatingDP"]] = df["Rating"].str.extract(r"(\d+\.\d+)\s\((\d+)\)")

    # Split Length into Length and LengthDP
    # Loop through each row
    for index, row in df.iterrows():
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
                    match = re.search(r"(\d+h\d+m|\d+h|\d+m)\s\((\d+)\)", length_data)
                    if match:
                        df.at[index, "Length"] = match.group(1)
                        # Make sure LengthDP is integer
                        df.at[index, "LengthDP"] = int(match.group(2))

    # Apply the replacement function
    df = df.apply(replace_length, axis=1)

    # Replace "-" (implying null vote) with NaN
    df.replace("-", np.nan, inplace=True)

    # Exclude blacklisted games
    # df = df[df["Blacklisted"] != "✓"]

    # Reorder the columns
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
file_list = glob.glob("vndb-list-export-*.csv")
if len(file_list) > 0:
    filepath = file_list[0]
    df = pd.read_csv(filepath)
    new_file_name = filepath.replace("vndb-list-export-", "vndb-list-sanitized-")
else:
    # TODO: point to userscript repo
    print(
        "VNDB list CSV not found.\nPlease install VNDB User List Exporter and export first.\nYou can get it from https://github.com/Vinfall/UserScripts#list."
    )
    exit()

df = sanitized_dataframe(df)

# Debug preview
print(df)

# Export to CSV
df.to_csv(new_file_name, index=False, quoting=1)
