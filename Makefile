# Commands
PYTHON = python
PIP = pip
R = Rscript

# Dependencies & scripts
REQUIREMENTS = requirements.txt
PACKAGES = tidyverse corrplot
SANITIZER = vndb-sanitizer.py
BARCHART = vndb-barchartrace.py
PLOT = vndb-plot.r

# Default
all: install sanitize plot

# Install dependencies for Python and R
install: $(REQUIREMENTS) $(PACKAGES)
	$(PIP) install -r $(REQUIREMENTS)
	$(R) -e "install.packages(c('$(PACKAGES)'), repos = 'https://cran.rstudio.com/')"

# Sanitize data
sanitize: $(SANITIZER)
	$(PYTHON) $(SANITIZER)
	$(PYTHON) $(BARCHART)

# Generate plots
plot: $(BARCHART) $(PLOT)
	$(R) $(PLOT)
	-rm Rplots.pdf

# Clean up outputs
clean:
	-rm vndb-*-sanitized-*.csv vndb-list-barchartrace-*.csv Rplots.pdf output/*.png
