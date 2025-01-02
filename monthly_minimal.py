#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import csv
import sqlite3
import sys

INPUT_PATH = "output/monthly.csv"
OUTPUT_PATH = "output/monthly-minimal.csv"
QUERY = "sql/monthly-minimal.sql"


def query_csv(input_csv, output_csv, sql_query):
    # Read query from file
    with open(sql_query, "r", encoding="utf-8") as file:
        query = file.read()

    # Create a memory SQLite DB
    conn = sqlite3.connect(":memory:")
    cursor = conn.cursor()

    # Read CSV and create table
    with open(input_csv, "r", encoding="utf-8") as csvfile:
        reader = csv.reader(csvfile)
        headers = next(reader)
        cursor.execute(f"CREATE TABLE Monthly ({', '.join(headers)})")
        cursor.executemany(
            # trunk-ignore(bandit/B608): intended SQL injection
            f"INSERT INTO Monthly VALUES ({', '.join(['?']*len(headers))})",
            reader,
        )

    cursor.execute(query)
    results = cursor.fetchall()

    with open(output_csv, "w", encoding="utf-8", newline="") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow([description[0] for description in cursor.description])
        writer.writerows(results)

    conn.close()


try:
    with open(INPUT_PATH, "r", encoding="utf-8") as f:
        pass  # Check if file exist
except FileNotFoundError:
    print("Monthly list not found. Export via VNDB Query first.")
    sys.exit()

# Query results
query_csv(INPUT_PATH, OUTPUT_PATH, QUERY)
