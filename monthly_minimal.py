#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sqlite3
import sys

import pandas as pd

INPUT_PATH = "output/monthly.csv"
OUTPUT_PATH = "output/monthly-minimal.csv"
QUERY = "sql/monthly-minimal.sql"


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
    query = query.replace("2024-10-01", last_month_start).replace(
        "2024-10-31", last_month_end
    )

    # Create a memory SQLite DB
    conn = sqlite3.connect(":memory:")
    df = pd.read_csv(input_csv)
    df.to_sql("Monthly", conn, index=False, if_exists="replace")

    result_df = pd.read_sql_query(query, conn)
    result_df.to_csv(output_csv, index=False)

    conn.close()


try:
    with open(INPUT_PATH, "r", encoding="utf-8") as f:
        pass  # 仅检查文件是否存在
except FileNotFoundError:
    print("Monthly list not found. Export via VNDB Query first.")
    sys.exit()

# 调用查询函数
query_csv(INPUT_PATH, OUTPUT_PATH, QUERY)
