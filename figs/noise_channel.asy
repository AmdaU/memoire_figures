import settings;
outformat = "pdf";

import graph;
include "figs/AutoColors.asy.tmp";

size(14cm, 0);

real lw = 1.5;
pen edge = linewidth(lw) + textcolor;
pen arrow_pen = linewidth(1.5) + textcolor;
defaultpen(fontsize(12pt) + textcolor);

pen noise_fill = secondary + opacity(0.7);
pen noise_line = linewidth(2) + secondary;
// --- Signal grid ---
int rows = 5;
int cols = 6;
real dot_r = 4;
real spacing = 14;

int[][] pattern = {
    {1, 0, 1, 1, 0, 1},
    {0, 1, 0, 1, 0, 1},
    {1, 1, 1, 0, 0, 1},
    {0, 0, 1, 1, 1, 0},
    {1, 0, 0, 1, 0, 0}
};

int[][] flips = {{0, 2}, {2, 1}, {4, 2}, {2, 4}, {3, 4}};

bool isFlipped(int r, int c) {
    for (int i = 0; i < flips.length; ++i)
        if (flips[i][0] == r && flips[i][1] == c) return true;
    return false;
}

void drawSignal(real x0, real y0, bool corrupted) {
    for (int r = 0; r < rows; ++r) {
        for (int c = 0; c < cols; ++c) {
            pair pos = (x0 + c * spacing, y0 - r * spacing);
            int val = pattern[r][c];
            bool err = corrupted && isFlipped(r, c);
            if (err) val = 1 - val;

            pen fc, oc;
            if (err) {
                fc = val == 1 ? secondary : background;
                oc = linewidth(lw) + secondary;
            } else {
                fc = val == 1 ? primary : background;
                oc = edge;
            }
            filldraw(circle(pos, dot_r), fc, oc);
        }
    }
}

// --- Organic noisy-boundary region ---
// Elliptical base shape with multi-frequency sinusoidal perturbation
// gives a smooth but irregular "blob" feel (similar to TN.asy blob shapes)
path noisyRegion(pair center, real rx, real ry, real amp, int npts) {
    guide g;
    for (int i = 0; i < npts; ++i) {
        real t = 2 * pi * i / npts;
        pair base = center + (rx * cos(t), ry * sin(t));
        real noise = amp * (0.5 * sin(3*t + 1.3)
                          + 0.3 * sin(7*t + 2.7)
                          + 0.2 * sin(11*t + 0.5));
        pair pt = base + noise * unit((cos(t), sin(t)));
        if (i == 0) g = pt;
        else g = g .. pt;
    }
    return g .. cycle;
}

// --- Layout (channel centered at origin) ---
real channel_rx = 45;
real channel_ry = (rows - 1) * spacing / 2 + 18;
pair ch = (0, 0);
real gap = 30;

real input_rcol = -(channel_rx + gap);
real input_x0 = input_rcol - (cols - 1) * spacing;
real output_x0 = channel_rx + gap;
real grid_top = (rows - 1) * spacing / 2;


// entry points

int opening_size = 5;
pair entry_center = (-channel_rx +10 ,0);
int entry_width = 2;

pen opening_pen = secondary + linewidth(entry_width);
//draw a small half ellipse
path top_semi_circle = arc((0,0), opening_size, -90, 90);
path bottom_semi_circle = arc((0,0), opening_size, 90, 270);
// squish the circle to an ellipse
path top_entry = shift(entry_center) * (scale(0.5, 1) * top_semi_circle);
path bottom_entry = shift(entry_center) * (scale(0.5, 1) * bottom_semi_circle);

path top_exit = shift((-entry_center.x, entry_center.y)) * (scale(-0.5, 1) * top_semi_circle);
path bottom_exit = shift((-entry_center.x, entry_center.y)) * (scale(-0.5, 1) * bottom_semi_circle);

// wriggly arrow made from bezier curves
// start 

pair start_point = (input_rcol + dot_r + 8, 0);
pair end_point = (output_x0 - dot_r - 8, 0);

real entry_offset = 0;
pair entry_point = (entry_center.x + entry_offset, 0);
pair exit_point = -entry_point;

path arrow_start = start_point -- entry_point;
path arrow_end = exit_point -- end_point;

real color_zone_height = 35;
real color_zone_width_reduction = 17;
path color_zone_top = entry_center + (0, opening_size) -- entry_center + (color_zone_width_reduction, opening_size + color_zone_height) -- exit_point + (-color_zone_width_reduction, opening_size + color_zone_height) -- exit_point + (0, opening_size);

path color_zone_bottom = scale(1, -1) * color_zone_top;


path color_zone = top_entry .. color_zone_top .. reverse(top_exit) .. reverse(color_zone_bottom)  .. cycle;

srand(5);
// path trought semi-random points
real vertical_amplitude_max = 30;
real horizontal_amplitude_max = 12;
int num_points = 7;
path wriggly_path;
for (int i = 1; i < num_points+1; ++i) {
    // guide point is a point on the line between the entry and exit points
    real variation_factor = 1 - abs(2*i/(num_points+1) - 1);
    real vertical_amplitude = vertical_amplitude_max * variation_factor;
    real horizontal_amplitude = horizontal_amplitude_max * variation_factor;
    pair guide_point = entry_point*(1-i/(num_points+1)) + exit_point*(i/(num_points+1));
    pair variation = (horizontal_amplitude * (unitrand()*2-1), vertical_amplitude * (unitrand()*2-1));
    // filldraw(circle(guide_point + variation, 1), secondary + opacity(0.1));
    wriggly_path = wriggly_path .. guide_point + variation;
}
path arrow_path = arrow_start .. wriggly_path .. arrow_end;
// === Draw layers (back to front) ===

draw(bottom_entry, opening_pen);
draw(bottom_exit, opening_pen);
// 1. Continuous arrow
// 2. Channel blob with organic boundary
path blob = noisyRegion(ch, channel_rx, channel_ry, 3.5, 48);
// Layer 1: arrow underneath — will be visible (tinted) through the
//          semi-transparent blob in the color_zone regions.
draw(arrow_path, arrow_pen, Arrow(TeXHead, size=1mm));

// Layer 2: single continuous blob fill — no split, no seam.
fill(blob, noise_fill);
draw(blob, noise_line);

// Layer 3: arrow again, clipped to *exclude* the color_zone.
//          This overpaints the tinted arrow in the tunnel area so it
//          appears crisp/on-top there, while keeping the tinted version
//          visible in the color_zone.
picture arrow_top;
draw(arrow_top, arrow_path, arrow_pen, Arrow(TeXHead, size=1mm));
pair pad = (10, 10);
clip(arrow_top, box(min(arrow_top)-pad, max(arrow_top)+pad)
               ^^ reverse(color_zone), evenodd);
add(arrow_top);

draw(top_entry, opening_pen);
draw(top_exit, opening_pen);


// 3. Noise marks scattered inside
srand(42);
for (int i = 0; i < 40; ++i) {
    pair np = ch + ((unitrand() - 0.5) * channel_rx * 1.4,
                    (unitrand() - 0.5) * channel_ry * 1.4);
    real a = unitrand() * 360;
    real len = 1.5 + unitrand() * 4.5;
    draw(np - len * dir(a) -- np + len * dir(a),
         linewidth(2) + secondary + opacity(0.3));
}

// 4. Channel label (above the blob)
label("$\mathcal{E}$", ch + (-5, channel_ry -7), fontsize(14pt) + textcolor);

// 5. Signal grids (topmost layer)
drawSignal(input_x0, grid_top, false);
drawSignal(output_x0, grid_top, true);

shipout(bbox(4mm, background, Fill));
