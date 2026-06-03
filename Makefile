SHELL = /bin/bash

# =====================================================================
#  Figure build system for the research group
# ---------------------------------------------------------------------
#  Quick start:
#    make                  build every figure with the default theme
#    make THEME=joker      build every figure with the "joker" theme
#    make list-themes      show the available color themes
#    make help             show all targets
#
#  Rebuild a single figure (any theme):
#    make figs/TNs/ex.pdf
#    make figs/heatmaps/heatmap_exemple.pdf THEME=catppuccin_mocha
#
#  Edit a figure source (.asy / .tex / .py / .dat / .csv) and just run
#  `make` again: only the figures that changed are rebuilt.
# =====================================================================

# ---------------------------------------------------------------------
#  Theme selection
# ---------------------------------------------------------------------
#  Themes live in themes/<name>.json. The active theme is copied to
#  ./colors.json, which every figure script reads. DEFAULT_THEME is used
#  the first time you build (when ./colors.json does not exist yet).
#  Set the lab default once here:
DEFAULT_THEME ?= royer_lab_main
THEME ?=

AVAILABLE_THEMES := $(patsubst themes/%.json,%,$(wildcard themes/*.json))

# Initialize colors.json on first build.
ifeq ($(wildcard colors.json),)
$(info [theme] initializing colors.json from themes/$(DEFAULT_THEME).json)
_INIT := $(shell cp themes/$(DEFAULT_THEME).json colors.json && echo $(DEFAULT_THEME) > .active_theme)
endif

# Switch theme when THEME= is given and differs from the active one.
ifneq ($(strip $(THEME)),)
THEME_FILE := themes/$(THEME).json
ifeq ($(wildcard $(THEME_FILE)),)
$(error Theme '$(THEME)' not found. Available: $(AVAILABLE_THEMES))
endif
ACTIVE_THEME := $(strip $(shell cat .active_theme 2>/dev/null))
ifneq ($(ACTIVE_THEME),$(THEME))
$(info [theme] switching $(ACTIVE_THEME) -> $(THEME))
# New colors + force regeneration of the derived color files.
_SWAP := $(shell cp $(THEME_FILE) colors.json && echo $(THEME) > .active_theme && rm -f AutoColors.sty.tmp figs/AutoColors.asy.tmp)
endif
endif

# Build figures in parallel by default; override with `make -j1`.
NPROC := $(shell nproc 2>/dev/null || echo 4)
MAKEFLAGS += -j$(NPROC)

PYTHON := .venv/bin/python3

# ---------------------------------------------------------------------
#  Source discovery
# ---------------------------------------------------------------------
ASY       = $(shell find ./figs -name "*.asy" -type f)
FIGS_TEX  = $(shell find ./figs -maxdepth 1 -name "*.tex" -type f)
STATES    = $(shell find ./figs/states -name "*.dat" -type f)
HEATMAPS  = $(shell find ./figs/heatmaps -name "*.dat" -type f)
GRAPHS    = $(shell find ./figs/graphs -name "*.dat" -type f)
GAUGE_CSV = $(shell find ./figs/gauge_graphs -name "*.csv" -type f)
GAUGE_FIG = figs/gauge_graphs/gauge_plot.pdf

# Asymptote files declare their output format inside the source.
ASY_GIF_SOURCES = $(shell grep -r -l --include="*.asy" 'settings.outformat = "gif"' ./figs || true)
ASY_PNG_SOURCES = $(shell grep -r -l --include="*.asy" 'settings.outformat = "png"' ./figs || true)
ASY_PDF_SOURCES = $(filter-out $(ASY_GIF_SOURCES) $(ASY_PNG_SOURCES),$(ASY))

ASY_PDF_OUTS = $(ASY_PDF_SOURCES:.asy=.pdf)
ASY_PNG_OUTS = $(ASY_PNG_SOURCES:.asy=.png)
ASY_GIF_OUTS = $(ASY_GIF_SOURCES:.asy=.gif)

TEX_FIGS     = $(FIGS_TEX:.tex=.pdf)
STATES_FIGS  = $(STATES:.dat=_wigner.pdf)
HEATMAPS_FIGS = $(HEATMAPS:.dat=.pdf)
GRAPHS_FIGS  = $(GRAPHS:.dat=.pdf)

# Everything that `make` produces.
ALL_FIGS = $(ASY_PDF_OUTS) $(ASY_PNG_OUTS) $(ASY_GIF_OUTS) $(TEX_FIGS) \
           $(STATES_FIGS) $(HEATMAPS_FIGS) $(GRAPHS_FIGS) \
           $(GAUGE_FIG)

.PHONY: all figs help list-themes asy tex states heatmaps graphs gauge \
        clean cleanfigs distclean

all: figs

figs: $(ALL_FIGS)

# Convenience group targets ------------------------------------------------
asy:      $(ASY_PDF_OUTS) $(ASY_PNG_OUTS) $(ASY_GIF_OUTS)
tex:      $(TEX_FIGS)
states:   $(STATES_FIGS)
heatmaps: $(HEATMAPS_FIGS)
graphs:   $(GRAPHS_FIGS)
gauge:    $(GAUGE_FIG)

# ---------------------------------------------------------------------
#  Generated color definitions (derived from the active colors.json)
# ---------------------------------------------------------------------
# LaTeX colors (read by figs/quantikz_head.sty via \input{../AutoColors.sty.tmp})
AutoColors.sty.tmp: colors.json scripts/convert_json.py
	python3 scripts/convert_json.py --latex

# Asymptote colors (included by every .asy file)
figs/AutoColors.asy.tmp: colors.json scripts/convert_json.py
	python3 scripts/convert_json.py --asy

# ---------------------------------------------------------------------
#  Asymptote figures
# ---------------------------------------------------------------------
$(ASY_PDF_OUTS): %.pdf: %.asy figs/AutoColors.asy.tmp
	asy -f pdf $< -o $(basename $@)

$(ASY_PNG_OUTS): %.png: %.asy figs/AutoColors.asy.tmp
	asy -f png $< -o $(basename $@)

$(ASY_GIF_OUTS): %.gif: %.asy figs/AutoColors.asy.tmp
	asy -f gif $< -o $(basename $@)

# These Asymptote figures embed state PDFs produced from figs/states/*.dat.
figs/sBs_q_relation.pdf figs/sBs_p_relation.pdf: $(STATES_FIGS)

# ---------------------------------------------------------------------
#  LaTeX (quantikz) figures
# ---------------------------------------------------------------------
$(TEX_FIGS): %.pdf: %.tex AutoColors.sty.tmp
	cd figs && lualatex -interaction=nonstopmode -halt-on-error $(notdir $(basename $<))

# ---------------------------------------------------------------------
#  Matplotlib / QuTiP figures (need the virtualenv)
# ---------------------------------------------------------------------
$(HEATMAPS_FIGS): %.pdf: %.dat .venv/.stamp colors.json figs/heatmaps/plot.py
	$(PYTHON) figs/heatmaps/plot.py $<

$(STATES_FIGS): %_wigner.pdf: %.dat .venv/.stamp colors.json figs/states/wigner.py
	$(PYTHON) figs/states/wigner.py $(notdir $(basename $<))

$(GRAPHS_FIGS): %.pdf: %.dat .venv/.stamp colors.json figs/graphs/make_plot.py
	$(PYTHON) figs/graphs/make_plot.py $(notdir $(basename $<))

$(GAUGE_FIG): $(GAUGE_CSV) .venv/.stamp colors.json figs/gauge_graphs/plot_gauge.py
	$(PYTHON) figs/gauge_graphs/plot_gauge.py gauge_plot

# ---------------------------------------------------------------------
#  Python virtual environment
# ---------------------------------------------------------------------
.venv/.stamp: requirements.txt
	python3 -m venv .venv
	.venv/bin/pip install --upgrade pip
	.venv/bin/pip install -r requirements.txt
	touch $@

# ---------------------------------------------------------------------
#  Housekeeping
# ---------------------------------------------------------------------
list-themes:
	@echo "Available themes (themes/<name>.json):"
	@for t in $(AVAILABLE_THEMES); do \
	  if [ "$$t" = "$$(cat .active_theme 2>/dev/null)" ]; then \
	    echo "  * $$t (active)"; else echo "    $$t"; fi; \
	done
	@echo ""
	@echo "Default theme (used on first build): $(DEFAULT_THEME)"

help:
	@echo "Figure build system"
	@echo ""
	@echo "  make                       build all figures (current/default theme)"
	@echo "  make THEME=<name>          build all figures with a given theme"
	@echo "  make <path/to/fig.pdf>     build a single figure"
	@echo ""
	@echo "  Group targets: asy tex states heatmaps graphs gauge"
	@echo ""
	@echo "  make list-themes           list color themes"
	@echo "  make clean                 remove LaTeX/asy junk + color caches"
	@echo "  make cleanfigs             remove all generated figures"
	@echo "  make distclean             cleanfigs + remove .venv and colors.json"
	@echo ""
	@echo "  Available themes: $(AVAILABLE_THEMES)"

clean:
	find . -type f \( -name "*.aux" -o -name "*.log" -o -name "*.fls" \
	  -o -name "*.fdb_latexmk" -o -name "*.synctex.gz" -o -name "*.out" \
	  -o -name "*.toc" -o -name "*.bbl" -o -name "*.blg" \) -delete
	rm -f AutoColors.sty.tmp figs/AutoColors.asy.tmp figs/AutoColors.mplstyle.tmp
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true

cleanfigs:
	rm -f $(ALL_FIGS)

distclean: cleanfigs clean
	rm -rf .venv
	rm -f colors.json .active_theme
