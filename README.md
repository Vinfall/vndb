# VNDB

## Intro

VNDB, is an acronym of *VNDB Novel Data Breakup*, which is also the abbreviation of *Visual Novel DataBase*.

It contains the companion scripts for [VNDB Query](https://query.vndb.org/about) for my personal use.

I used VNDB List Export in the past but eventually switched to VNDB Query
as PostgreSQL seems more robust than Pandas to me now.

With this, you can get the data with just a single UID (provided the list is not private).
No more hastle of jumping through pages.

> [!TIP]
> A downside of query is it's synced with VNDB's public dump daily at 8:30 UTC, so it may take up to 24 hours (+ ~30 minutes) for changes to the main database to show up in query results.

This is usually not a problem as I can't see why someone would use it on a daily basis.
~~Even on that case, you can just append the missing data yourself...~~

## Query

First, you need to export your VNDB VN/length vote list with [queries in /sql](/sql/):
1. Choose the query you need, usually it's [monthly.sql](sql/monthly.sql) (if you want a complete list, use [user-list.sql](sql/user-list.sql) instead) or [lengthvotes.sql](sql/lengthvotes.sql)
2. Paste the query on [VNDB Query](https://query.vndb.org), change things like `UID`, just see query comments
3. Click `Run`
4. `Export` > `CSV`
5. Place the exported CSV in [output](output/) directory

> [!NOTE]
> If you ever export your data on VNDB, the vanilla `XML` format sadly will NOT work (as I'm lazy to write/find a parser).
>
> You can also use [the counterfeit example](example/) to take a look at the results.

## Usage

Tested with Python 3.12 & R 4.4 on Void Linux.

### Easy way

Install Python, R & GNU Make (which you can install on Windows too), clone the repo and simply run `make`.

Everything should be done now.
Just check `output` or console log for the results.

> [!TIP]
> To get a list of available commands, run `make help` (only available on Linux, other commands are system agnostic though).

To clean up the data, run `make clean`.
Previous results are cleaned before restart though.
Similarly, run `make uninstall` to uninstall dependencies.

***

### Vanilla way

1. Install Python, R & respective dependencies:

```python
# Python
pip install -r requirements.txt
```

```r
# R
install.packages("tidyverse")
install.packages("corrplot")
install.packages("gridExtra")
```

2. Now run the sanitizer and plot generator:

```sh
python ./vndb_sanitizer.py
python ./vndb_barchartrace.py
Rscript ./vndb-plot.r
```

3. Check `output` or console log for the ugly (toldya) plots.

### Legacy way

If you still prefer legacy way with VNDB List Export (for more robust multi-language support), you can use the scripts in [legacy](/legacy/), the code may or may not work. Anyway, that's why it's called *legacy*. There is also no intro about it, good luck with that😉

## [License](LICENSE)

WTFPL

[user-list.sql](./sql/user-list.sql) is (probably) adapted from [User VN List](https://query.vndb.org/3ccc1cf3e6f18e48), other queries are written by myself and still licensed under WTFPL.
