# VNDB

> [!WARNING]
> Deprecated! I no longer have the interest to maintain this.
> If you wanna try it anyway, the combination of VNDB List Export + [legacy](/legacy/) is more likely to work.

## Intro

VNDB, is an acronym of *VNDB Novel Data Breakup*, which is also the abbreviation of *Visual Novel DataBase*.

It contains the companion scripts for [VNDB Query](https://query.vndb.org/about) for my personal use.

I use VNDB List Export and
~~but eventually switched to VNDB Query as SQL seems more robust than Pandas to me~~
switched back from VNDB Query due to localization.

## Query

First, you need to export your VNDB VN/length vote list with VNDB List Export (docs included) or [queries in /sql](/sql/).

If you choose to export via VNDB Query:
1. Choose the query you need, usually it's [monthly.sql](sql/monthly.sql) (if you want a complete list, use [user-list.sql](sql/user-list.sql) instead) or [lengthvotes.sql](sql/lengthvotes.sql)
2. Paste the query on [VNDB Query](https://query.vndb.org), change things like `UID`, just see query comments
3. Click `Run`
4. `Export` > `CSV`
5. Place the exported CSV in [output](output/) directory

> [!NOTE]
> If you ever export your data on VNDB, the vanilla `XML` format sadly will NOT work (as I'm lazy to write/find a parser).
>
> By the way, you can also use [the counterfeit example](example/) to take a look at the results.

## Usage

[Legacy](/legacy/) is tested with Python 3.13 & R 4.4 on GNU/Linux, I have not adapted VNDB Query format yet.
As I moved back to VNDB List Export, this is unlikely to happen.

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
    pip install .
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

## [License](LICENSE)

WTFPL

[user-list.sql](./sql/user-list.sql) is (probably) adapted from [User VN List](https://query.vndb.org/3ccc1cf3e6f18e48), other queries are written by myself and still licensed under WTFPL.
