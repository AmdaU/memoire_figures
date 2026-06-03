settings.outformat = "png";
settings.render = 16; 
import graph3;
import solids;
include "figs/AutoColors.asy.tmp";

size(500);
// Head on view with small angle
// Looking from positive Z, slightly tilted down (negative Y) or similar.
// "Head on" usually implies looking at the top face.
// perspective(x,y,z) camera position.
// (0, -1, 10) looks from above and slightly "south".
// View from South East with a small elevation angle
currentprojection = perspective(8, -8, 4);

currentlight = light(gray(0.5), specular=gray(0.8), 
                     (10, 20, 50),    // Top down light - Main source
                     (10, -10, 20), // Side light
                     (-5, 5, 10)   // Fill
                    );
currentlight.background = background;

// --- Materials ---
// Substrate: Dark Silicon/Sapphire
material substrateMat = material(diffusepen=tertiary*0.8+black*0.2, specularpen=white, shininess=0.9);

// Resonator: Gold/Copper metallic
material resonatorMat = material(
    diffusepen=0.7*primary + 0.3*background,   // Lighter primary, blend to page bg
    emissivepen=0.1*primary, 
    specularpen=white, 
    shininess=0.8
);

// --- Dimensions ---
real chipW = 4.0;
real chipL = 8.0;
real chipH = 0.2;

real resWidth = 0.4;
real resH = 0.05; // Very thin

// --- Draw Substrate ---
// Center at origin
triple chipCenter = (0,0,0);
triple chipMin = (-chipW/2, -chipL/2, -chipH/2);
triple chipMax = (chipW/2, chipL/2, chipH/2);

// Draw Box (Substrate)
// Using unitcube scaled and shifted to form the substrate solid
surface chip = shift(chipMin) * scale(chipW, chipL, chipH) * unitcube;
draw(chip, substrateMat);

// --- Draw Resonator (Square U-shape) ---
// Path on top surface (z = chipH/2)
real zTop = chipH/2;
real gap = 1.0; // Center-to-center distance approximately, or gap between inner edges. Let's stick to geometry.
real armLen = 5.0;
real startY = -chipL/2 + 1.0;

// Geometry for Square U
// Right Arm Outer X: gap/2 + resWidth
// Left Arm Outer X: -gap/2 - resWidth
// (Assuming gap is the empty space between arms)

real innerGapHalf = gap/2;
real outerX = innerGapHalf + resWidth;

// Outer path (Clockwise or Counter-Clockwise)
// Let's go Up Right -> Left -> Down Left
// Using 2D paths for extrusion
path outerP = (outerX, startY) 
            -- (outerX, startY + armLen + resWidth) // Up to top outer corner
            -- (-outerX, startY + armLen + resWidth) // Across to top left outer corner
            -- (-outerX, startY); // Down to bottom left

// Inner path (inside the U)
// Let's go Up Right Inner -> Left Inner -> Down Inner
// Inner X is just gap/2
path innerP = (innerGapHalf, startY) 
            -- (innerGapHalf, startY + armLen) // Up to inner corner
            -- (-innerGapHalf, startY + armLen) // Across
            -- (-innerGapHalf, startY); // Down

// Close the loop
// Connect Outer End to Inner End? 
// outerP end is (-outerX, startY). innerP end is (-innerGapHalf, startY).
// We need a closed cycle.
// Start at (outerX, startY) -> Up -> Left -> Down (-outerX) -> In to (-innerGapHalf) -> Up -> Right -> Down (innerGapHalf) -> Out to Start.

path loop = (outerX, startY) 
          -- (outerX, startY + armLen + resWidth)
          -- (-outerX, startY + armLen + resWidth)
          -- (-outerX, startY)
          -- (-innerGapHalf, startY)
          -- (-innerGapHalf, startY + armLen)
          -- (innerGapHalf, startY + armLen)
          -- (innerGapHalf, startY)
          -- cycle;

// Draw the surface
// Extrude to give thickness
// Sides
draw(shift(0,0,zTop)*extrude(loop, resH*Z), resonatorMat);
// Top cap
draw(shift(0,0,zTop+resH)*surface(loop), resonatorMat);
