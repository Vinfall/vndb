#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sqlite3
import sys

import pandas as pd

INPUT_PATH = "output/monthly.csv"
OUTPUT_PATH = "output/monthly-minimal.csv"
QUERY = "sql/monthly-minimal.sql"


def query_csv(input_csv, output_csv, sql_query):
    # Read query from file
    with open(sql_query, "r", encoding="utf-8") as file:
        query = file.read()

    # Create a memory SQLite DB
    conn = sqlite3.connect(":memory:")
    df = pd.read_csv(input_csv)
    df.to_sql("Monthly", conn, index=False, if_exists="replace")

    result_df = pd.read_sql_query(query, conn)
    result_df.to_csv(output_csv, index=False)

    conn.close()


try:
    with open(INPUT_PATH, "r", encoding="utf-8") as f:
        pass  # Check if file exist
except FileNotFoundError:
    print("Monthly list not found. Export via VNDB Query first.")
    sys.exit()

# Query results
query_csv(INPUT_PATH, OUTPUT_PATH, QUERY)
