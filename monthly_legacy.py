#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Edited from query.py in hltb

import glob
import sqlite3
import sys

import pandas as pd


def get_last_month_dates():
    # Get the current date
    today = pd.to_datetime("today").normalize()  # noqa

    # Get the start and end dates of last month
    month_start = (today - pd.offsets.MonthBegin(2)).strftime("%Y-%m-%d")
    month_end = (today - pd.offsets.MonthEnd(1)).strftime("%Y-%m-%d")

    return month_start, month_end


def query_csv(input_csv, output_csv, sql_query):
    # Read query from file
    with open(sql_query, "r", encoding="utf-8") as file:
        query = file.read()

    # Replace date on demand
    last_month_start, last_month_end = get_last_month_dates()
    query = query.replace("2024-09-01", last_month_start).replace(
        "2024-09-30", last_month_end
    )

    # Create a memory SQLite DB
    conn = sqlite3.connect(":memory:")
    df = pd.read_csv(input_csv)
    df.to_sql("VNDB", conn, index=False, if_exists="replace")

    result_df = pd.read_sql_query(query, conn)
    result_df.to_csv(output_csv, index=False)

    conn.close()


file_list = glob.glob("vndb-list-sanitized-*.csv")

if len(file_list) > 0:
    # Read every matched file
    for filepath in file_list:
        new_file_name = filepath.replace("vndb-list-sanitized-", "vndb-ulist-monthly-")
        query_csv(filepath, new_file_name, "sql/monthly-legacy.sql")
else:
    print("Sanitized CSV not found. Run `python vndb_sanitizer.py` first.")
    sys.exit()
