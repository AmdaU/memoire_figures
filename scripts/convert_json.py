#!/usr/bin/env python3
"""
Convert colors.json to LaTeX-friendly format
Usage: python json_to_latex.py
"""


import json
import argparse
parser = argparse.ArgumentParser(description='Convert colors.json to LaTeX-friendly format')
parser.add_argument('--latex', action='store_true', help='Convert to LaTeX-friendly format')
parser.add_argument('--asy', action='store_true', help='Convert to Asymptote-friendly format')
parser.add_argument('--matplotlib', action='store_true', help='Convert to Matplotlib-friendly format')
args = parser.parse_args()


def load_colors():
    with open('colors.json', 'r') as f:
        return json.load(f)


def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i + 2], 16) for i in (0, 2, 4))


def export_to_latex(colors):
    with open('AutoColors.sty.tmp', 'w') as f:
        f.write("% Auto-generated LaTeX color configuration\n")
        f.write("% Generated from colors.json\n\n")
        f.write("\\usepackage{xcolor}\n\n")
        
        for color_name, color_data in colors.items():
            color_data = color_data.lstrip('#')
            f.write(f"% {color_name.title()} color: #{color_data}\n")
            f.write(f"\\definecolor{{Auto{color_name}}}{{HTML}}{{{color_data}}}\n")
            f.write(r'\colorlet{lightAuto' + color_name + '}{Auto' + color_name + '!80}\n')
            f.write(r'\colorlet{darkAuto' + color_name + '}{Auto' + color_name + '!80!black}\n')
            f.write(r'\colorlet{paleAuto' + color_name + '}{Auto' + color_name + '!10}\n\n')

        if 'background' in colors:
            f.write("% Apply theme colors to page\n")
            f.write("\\pagecolor{Autobackground}\n")
        if 'textcolor' in colors:
            f.write("\\AtBeginDocument{\\color{Autotextcolor}}\n")


def export_to_asy(colors):
    with open('figs/AutoColors.asy.tmp', 'w') as f:
        f.write("// Auto-generated Asymptote color configuration\n")
        f.write("// Generated from colors.json\n\n")
        
        for color_name, color_data in colors.items():
            color_data = color_data.lstrip('#')
            f.write(f"// {color_name.title()} color: #{color_data};\n")
            f.write(f"pen {color_name} = RGB{hex_to_rgb(color_data)};\n")

def export_to_matplotlib(colors):
    with open('figs/AutoColors.mplstyle.tmp', 'w') as f:
        f.write("// Auto-generated Matplotlib color configuration\n")
        f.write("// Generated from colors.json\n\n")
        
        for color_name, color_data in colors.items():
            color_data = color_data.lstrip('#')
            f.write(f"// {color_name.title()} color: #{color_data};\n")
            f.write(f"{color_name} = '{color_data}'\n")

def main():
    # Read JSON file
    colors = load_colors()

    # Generate colors.cfg file
    if args.latex:
        export_to_latex(colors)
    elif args.asy:
        export_to_asy(colors)
    elif args.matplotlib:
        export_to_matplotlib(colors)
    else:
        # export all
        export_to_latex(colors)
        export_to_asy(colors)


if __name__ == "__main__":
    main()
