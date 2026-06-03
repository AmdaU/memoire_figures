# This script plots the Wigner function of a cat code state using QuTiP

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import TwoSlopeNorm, LinearSegmentedColormap
import qutip as qt
import json
import os

# directory of this script
dir_path = os.path.dirname(os.path.abspath(__file__))
_repo_root = os.path.abspath(os.path.join(dir_path, "..", ".."))
_colors_path = os.path.join(_repo_root, "colors.json")

with open(_colors_path, "r") as f:
    theme = json.load(f)


def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip("#")
    return tuple(int(hex_color[i : i + 2], 16) / 255 for i in (0, 2, 4))


background = theme.get("background", "#ffffff")
textcolor = theme.get("textcolor", "#000000")

plt.rcParams.update(
    {
        "figure.facecolor": background,
        "axes.facecolor": background,
        "savefig.facecolor": background,
        "text.color": textcolor,
    }
)

red = hex_to_rgb(theme["mainred"])
blue = hex_to_rgb(theme["mainblue"])
# W = 0 neutral: match page background so the plot sits cleanly on the thesis theme
neutral = np.array(hex_to_rgb(background))


def load_rho(name):
    filename = os.path.join(dir_path, name + ".dat")
    rho = np.genfromtxt(filename, delimiter=",", dtype=complex)
    return qt.Qobj(rho)


def save_rho(rho, name):
    filename = os.path.join(dir_path, name + ".dat")
    np.savetxt(filename, rho.data.to_array(), delimiter=",")


def plot_wigner(rho):
    # Phase-space grid
    xvec = np.linspace(-5, 5, 200)
    yvec = np.linspace(-5, 5, 200)
    W = qt.wigner(rho, xvec, yvec)

    cmap_stops = [
        (0.0, blue),
        (0.5, neutral),
        (1.0, red),
    ]
    cmap = LinearSegmentedColormap.from_list("brand_rwb", cmap_stops, N=256)

    # Ensure 0 maps to the center (neutral / theme background). Symmetric limits around 0.
    v = np.max(np.abs(W))
    norm = TwoSlopeNorm(vmin=-v, vcenter=0.0, vmax=v)

    fig, ax = plt.subplots()
    fig.patch.set_facecolor(background)
    ax.set_facecolor(background)
    ax.set_rasterization_zorder(0)
    ax.contourf(W, levels=256, cmap=cmap, norm=norm, linewidths=0, zorder=-1)

    ax.set_axis_off()

    return fig, ax


import argparse

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Plot the Wigner function of a density matrix or state vector"
    )
    parser.add_argument(
        "name", type=str, help="The name of the density matrix or state vector to plot"
    )
    args = parser.parse_args()
    rho = load_rho(args.name)
    plot_wigner(rho)
    plt.gca().set_aspect("equal", adjustable="box")
    out_path = os.path.join(dir_path, args.name + "_wigner.pdf")
    plt.savefig(
        out_path,
        dpi=600,
        bbox_inches="tight",
        pad_inches=0,
        facecolor=background,
        edgecolor="none",
    )
    print(f"Saved {out_path}")
