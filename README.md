## Intro

VNDB, is an acronym of *VNDB Novel Data Breakup*, which is also the abbreviation of *Visual Novel DataBase*.

It contains the companion scripts for [VNDB List Export](https://github.com/Vinfall/UserScripts#list) for my personal use.
Although I started with general applications in mind, I became more interest in visualization
using `ggplot2` package provided by R language and discarded availability for others in the end.

## Usage

Tested with Python 3.12 & R 4.4 on Void Linux ~~Windows 11 24H2 & [DevuanWSL](https://github.com/Vinfall/DevuanWSL)~~.
TBH it's not meant to be used by others, but anyway here is the recipe.

0. Export VNDB VN/length vote list with [instruction provided here](https://github.com/Vinfall/UserScripts#vndb-list-export)
and place it in the top directory, the vanilla `XML` VNDB export will NOT work.
You can also use [the counterfeit example](example/vndb-list-export-20240101.csv) to take a look at the results.

***

### Easy way

Install Python, R & GNU Make, clone the repo and simply run `make`.
Everything should be done now. Just check `output` or console log for the results.
To clean up the data and restart, run `make clean`.

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
python ./vndb-sanitizer.py
python ./vndb-barchartrace.py
Rscript ./vndb-plot.r
```

3. Check `output` or console log for the ugly (toldya) plots.

## [License](LICENSE)

WTFPL
