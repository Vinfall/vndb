## Intro

VNDB, for acronym for *VNDB Novel Data Breakup*.

It has the companion scripts for [VNDB User List Exporter](https://github.com/Vinfall/UserScripts#list)
for my personal use.
Although I started with general applications in mind, I became more interest in visualization
using `ggplot2` package provided by R language and discarded availability for others in the end.

## Usage

TBH it's not meant to be used by others, but anyway here is the recipe.

0. Export your VNDB user list and place it in the top directory first, the `XML` from VNDB won't work
cuz the sanitizer would only recognize the one exported by [VNDB User List Exporter](https://github.com/Vinfall/UserScripts#list).
You can also use [the provided example file](example/vndb-list-export-20240101.csv) to take a look at the results.

1. Install Python, R & respective dependencies:

```python
# Python
pip install -r requirements.txt
```

```r
# R
install.packages("tidyverse")
```

2. Now run the sanitizer and plot generator:

```sh
python ./vndb-sanitizer.py
Rscript ./vndb-plot.r
```

3. Check `output` for the ugly (toldya) plots

## [License](LICENSE)

WTFPL
