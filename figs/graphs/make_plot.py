"""Generic line-graph builder for the figs/graphs/ section.

Usage:
    python make_plot.py <name>

Reads <name>.dat from this folder and writes <name>.pdf. The .dat file holds
optional "#" comment lines, one header row of column names, then comma-separated
numeric rows. The first column is the x axis; every other column becomes a curve
labelled by its header name. Curves are colored from the active color theme.

See graph_exemple.dat for the expected format.
"""
import argparse
import csv
import json
import os

import matplotlib.pyplot as plt
import numpy as np

parser = argparse.ArgumentParser()
parser.add_argument("filename", type=str,
                    help="base name of the .dat file in this folder (no extension)")
args = parser.parse_args()

path = os.path.dirname(os.path.abspath(__file__))

# Use LaTeX for text rendering (requires pdflatex on PATH)
plt.rcParams["text.usetex"] = True
plt.rcParams["font.family"] = "serif"
plt.rcParams["font.size"] = 12

# import colors from repo-root colors.json (path relative to this script, not cwd)
with open(os.path.join(path, "..", "..", "colors.json"), "r") as f:
    colors = json.load(f)

background = colors.get("background", "#ffffff")
textcolor = colors.get("textcolor", "#000000")
plt.rcParams.update({
    "figure.facecolor":  background,
    "axes.facecolor":    background,
    "savefig.facecolor": background,
    "text.color":        textcolor,
    "axes.labelcolor":   textcolor,
    "axes.edgecolor":    textcolor,
    "xtick.color":       textcolor,
    "ytick.color":       textcolor,
    "legend.facecolor":  background,
    "legend.edgecolor":  "none",
})


def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip("#")
    return tuple(int(hex_color[i:i + 2], 16) / 255 for i in (0, 2, 4))


# one color per curve, cycled from the theme's semantic colors
palette = [hex_to_rgb(colors[k]) for k in ("primary", "secondary", "tertiary")]
markers = ["o", "s", "^", "d", "v"]

# read the data file: skip blank/comment lines, first row is the header
dat_path = os.path.join(path, f"{args.filename}.dat")
header = None
rows = []
with open(dat_path, newline="") as file:
    for raw in file:
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        fields = [c.strip() for c in line.split(",")]
        if header is None:
            header = fields
        else:
            rows.append([float(c) for c in fields])

data = np.array(rows)
x = data[:, 0]
labels = header[1:]

fig, ax = plt.subplots(figsize=(8, 3.5))
for i, label in enumerate(labels):
    ax.plot(x, data[:, i + 1],
            color=palette[i % len(palette)],
            marker=markers[i % len(markers)],
            markersize=4, linewidth=1.5, label=label)

ax.set_xlabel(f"${header[0]}$")
ax.set_ylabel(r"Valeur")
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.legend(frameon=False)
fig.tight_layout()
fig.savefig(os.path.join(path, f"{args.filename}.pdf"))
