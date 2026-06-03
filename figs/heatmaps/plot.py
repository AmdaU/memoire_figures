import argparse
import json
import os

import matplotlib.pyplot as plt
import numpy as np
import matplotlib.colors as mcl

parser = argparse.ArgumentParser()
parser.add_argument("data_file", type=str, help="Path to the .dat file")
args = parser.parse_args()

plt.rcParams.update({
    "text.usetex": True,
    "text.latex.preamble": 
    r"\usepackage{amssymb}" + "\n" +
    r"\usepackage{wasysym}" + "\n",
    "font.family": "serif",
    "font.size": 12,
    "axes.linewidth": 0.8,
})

with open(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                        '..', '..', 'colors.json'), 'r') as f:
    colors_json = json.load(f)

background = colors_json.get('background', '#ffffff')
textcolor  = colors_json.get('textcolor', '#000000')
plt.rcParams.update({
    'figure.facecolor':  background,
    'axes.facecolor':    background,
    'savefig.facecolor': background,
    'text.color':        textcolor,
    'axes.labelcolor':   textcolor,
    'axes.edgecolor':    textcolor,
    'xtick.color':       textcolor,
    'ytick.color':       textcolor,
    'legend.facecolor':  background,
    'legend.edgecolor':  'none',
})


def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip("#")
    return tuple(int(hex_color[i:i + 2], 16) / 255 for i in (0, 2, 4))


primary = hex_to_rgb(colors_json["primary"])
secondary = hex_to_rgb(colors_json["secondary"])
tertiary = hex_to_rgb(colors_json["tertiary"])
tertiary_dark = tuple(c * 0.7 for c in tertiary)
bg_rgb = hex_to_rgb(background)
LABEL_MAP = {
    "GKP-Qubit": r"$\newmoon$",
    "Repetition": r"\small{$\blacksquare$}",
    r"Repetition $\otimes$ GKP": r"$\blacktriangle$",
    r"Repetition $\otimes$ GKP-Correct": r"$\blacklozenge$",
}

COLOR_MAP = {
    r"$\bullet$": primary,
    r"\small{$\blacksquare$}": secondary,
    r"$\blacktriangle$": tertiary,
    r"$\blacklozenge$": tertiary_dark,
}

codes = []
probs = []
with open(args.data_file, "r") as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        tokens = line.split()
        values = [abs(float(v)) for v in tokens[-4:]]
        raw_name = " ".join(tokens[:-4])
        label = LABEL_MAP.get(raw_name, raw_name)
        codes.append(label)
        probs.append(values)

data = np.array(probs)
n_rows, n_cols = data.shape
pauli_labels = [r"$I$", r"$X$", r"$Y$", r"$Z$"]

row_colors = [COLOR_MAP.get(c, primary) for c in codes]

# vmin = max(data[data > 0].min(), 1e-6)
vmin = 1e-4
vmax = 1
log_norm = mcl.LogNorm(vmin=vmin, vmax=vmax)

rgba = np.empty((n_rows, n_cols, 3))
for i in range(n_rows):
    for j in range(n_cols):
        t = float(log_norm(max(data[i, j], vmin)))
        for ch in range(3):
            # t → 0 (probability → 0): match page background, not white
            rgba[i, j, ch] = bg_rgb[ch] * (1 - t) + row_colors[i][ch] * t

fig, ax = plt.subplots(figsize=(3, 3.5))

ax.imshow(rgba, aspect="auto")

ax.set_xticks(range(n_cols))
ax.set_xticklabels(pauli_labels)
ax.set_yticks(range(n_rows))
ax.set_yticklabels(codes)
for tick_label, color in zip(ax.get_yticklabels(), row_colors):
    tick_label.set_color(color)

for i in range(n_rows):
    for j in range(n_cols):
        val = data[i, j]
        luminance = sum(rgba[i, j, ch] * w
                        for ch, w in enumerate([0.299, 0.587, 0.114]))
        text_color = (
            textcolor if luminance < 0.55 else "#11111b"
        )
        ax.text(
            j, i, f"{val:.4f}", ha="center", va="center",
            color=text_color, fontsize=11,
        )

# ax.spines["top"].set_visible(False)
# ax.spines["right"].set_visible(False)
ax.set_title("Canal de Pauli effectif")

xlabel = ax.set_xlabel("Opérateur de Pauli")

fig.tight_layout()
outname = args.data_file.rsplit(".", 1)[0] + ".pdf"
fig.savefig(outname, bbox_inches="tight")
plt.close(fig)
