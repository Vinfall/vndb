# Varables
VENV = .venv
# PYTHON = $(VENV)/bin/python
# PIP = $(VENV)/bin/pip
PYTHON = python
PIP = pip
R = Rscript

# Dependencies & scripts
REQUIREMENTS = requirements.txt
PACKAGES = tidyverse corrplot gridExtra
SANITIZER = vndb_sanitizer_legacy.py
BARCHART = vndb_barchartrace_legacy.py
PLOT = vndb-plot.r

# Default target, run one by one
all:
	$(MAKE) install
	$(MAKE) clean
	$(MAKE) sanitize
	$(MAKE) plot

run:
	$(MAKE) clean
	$(MAKE) sanitize
	$(MAKE) plot

install: $(VENV) $(PACKAGES) ## install dependencies for Python and R
	$(PIP) install -r $(REQUIREMENTS)
	$(R) -e "install.packages(c('$(PACKAGES)'), repos = 'https://cran.rstudio.com/')"

$(VENV):
	virtualenv $(VENV)
	source $(VENV)/bin/activate; \
	$(PIP) install -r $(REQUIREMENTS)

sanitize: $(SANITIZER) ## sanitize data
	$(PYTHON) $(SANITIZER)
	$(PYTHON) $(BARCHART)

monthly: $(SANITIZER) ## get monthly list
	${PYTHON} monthly_legacy.py

plot: $(BARCHART) $(PLOT) ## generate plots
	$(R) $(PLOT)
	-rm Rplots.pdf

clean: ## clean outputs
	-rm vndb-*-sanitized-*.csv vndb-list-barchartrace-*.csv vndb-ulist-monthly-*.csv Rplots.pdf
	-rm output/*.png output/*.json output/*.csv

help: ## show this help
	@echo "Specify a command:"
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[0;36m%-12s\033[m %s\n", $$1, $$2}'
	@echo ""
.PHONY: help
