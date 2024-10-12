#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import csv
import os
import urllib.request

# Output files
_OUTPUT_FOLDER = "output/"
_CSV_FILE = "lengthvotes.csv"


# Edited from first-fm
def load_secrets():
    # Load secret credentials from local file
    secrets_file = ".env"
    if os.path.isfile(secrets_file):
        with open(secrets_file, "r") as f:
            lines = f.readlines()
            doc = {}
            for line in lines:
                if "=" in line:
                    key, value = line.split("=")
                    doc[key.strip()] = value.strip().strip("'")
    return doc


secrets = load_secrets()
lvid = secrets["LVID"]

# Get query results
url = "https://query.vndb.org/" + lvid + ".csv"
# trunk-ignore(bandit/B310)
response = urllib.request.urlopen(url)
lengthvotes = response.read().decode("utf-8").splitlines()

os.makedirs(_OUTPUT_FOLDER, exist_ok=True)
with open(_OUTPUT_FOLDER + _CSV_FILE, "w", encoding="utf-8") as f:
    writer = csv.writer(f)
    for row in csv.reader(lengthvotes):
        writer.writerow(row)
