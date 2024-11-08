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
BARCHART = vndb_barchartrace.py
QUERY = vndb_query.py
MINIMAL_QUERY = monthly_minimal.py
PLOT = vndb-plot.r

# Default target, run one by one
all:
	$(MAKE) install
	$(MAKE) clean
	$(MAKE) barchart
	$(MAKE) plot

run:
	$(MAKE) clean
	$(MAKE) barchart
	$(MAKE) plot

install: $(VENV) $(PACKAGES) ## Install dependencies for Python and R
	$(PIP) install -r $(REQUIREMENTS)
	$(R) -e "install.packages(c('$(PACKAGES)'), repos = 'https://cran.rstudio.com/')"

$(VENV):
	virtualenv $(VENV)
	source $(VENV)/bin/activate; \
	$(PIP) install -r $(REQUIREMENTS)

query: ## Get data from VNDB query (private)
	$(PYTHON) $(QUERY)

minimal: ## Get minimal monthly list from query
	$(PYTHON) $(MINIMAL_QUERY)

barchart: ## Format data to bar chart race style
	$(PYTHON) $(BARCHART)

plot: $(BARCHART) $(PLOT) ## Generate plots
	$(R) $(PLOT)
	-rm Rplots.pdf

clean: ## Clean up outputs (queries are preserved)
	-rm vndb-list-barchartrace-*.csv Rplots.pdf
	-rm output/*.png output/*.json output/monthly-minimal.csv

uninstall: ## Uninstall dependencies
	@echo "Cleaning up..."
	@deactivate || true
	rm -rf $(VENV)
	pip cache purge || true

help: ## Show this help
	@echo "Specify a command:"
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[0;36m%-12s\033[m %s\n", $$1, $$2}'
	@echo ""
.PHONY: help
