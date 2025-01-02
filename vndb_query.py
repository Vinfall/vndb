#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import csv
import os
import urllib.request

# Output files
_OUTPUT_FOLDER = "output/"


# Edited from first-fm
def load_secrets():
    # Load secret credentials from local file
    secrets_file = ".env.local"
    if os.path.isfile(secrets_file):
        with open(secrets_file, "r", encoding="utf-8") as f:
            lines = f.readlines()
            doc = {}
            for line in lines:
                if "=" in line:
                    key, value = line.split("=")
                    doc[key.strip()] = value.strip().strip("'")
    return doc


def get_data(query_id, output):
    # Get query results
    url = "https://query.vndb.org/" + query_id + ".csv"
    # trunk-ignore(bandit/B310)
    with urllib.request.urlopen(url, timeout=30) as response:
        data = response.read().decode("utf-8").splitlines()

    os.makedirs(_OUTPUT_FOLDER, exist_ok=True)
    with open(_OUTPUT_FOLDER + output, "w", encoding="utf-8") as file:
        writer = csv.writer(file)
        for row in csv.reader(data):
            writer.writerow(row)


secrets = load_secrets()
lvid = secrets["LVID"]
mmid = secrets["MMID"]

get_data(lvid, "lengthvotes.csv")
get_data(mmid, "monthly.csv")
