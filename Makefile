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

# Install dependencies for Python and R
install: $(VENV) $(PACKAGES)
	$(PIP) install -r $(REQUIREMENTS)
	$(R) -e "install.packages(c('$(PACKAGES)'), repos = 'https://cran.rstudio.com/')"

$(VENV):
	virtualenv $(VENV)
	source $(VENV)/bin/activate; \
	$(PIP) install -r $(REQUIREMENTS)

# Get data from VNDB query
query:
	$(PYTHON) $(QUERY)

# Get minimal monthly list from query
minimal:
	$(PYTHON) $(MINIMAL_QUERY)

# Format data to bar chart race style
barchart:
	$(PYTHON) $(BARCHART)

# Generate plots
plot: $(BARCHART) $(PLOT)
	$(R) $(PLOT)
	-rm Rplots.pdf

# Clean up outputs
clean:
	-rm vndb-list-barchartrace-*.csv  Rplots.pdf
	-rm output/*.png output/*.json output/monthly-minimal.csv
