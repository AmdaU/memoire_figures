settings.outformat = "png";
settings.render = 16; 

import graph3;
import solids;
include "figs/AutoColors.asy.tmp";

size(500);
currentprojection = perspective(10, -10, 5);
currentlight = light(background, specular=gray(0.8), (10, 10, 10), (-10, -10, 10));
currentlight.background = background;

// --- Materials ---
// Core: Light-carrying, so we use secondary (Red) or bright white/red mix
// "glowing" effect via emissivepen
material coreMat = material(diffusepen=secondary, emissivepen=0.3*secondary, specularpen=white, shininess=0.9);

// Cladding: Glass, usually transparent but here represented as light grey/white
// slightly transparent to look like glass, or solid for schematic clarity.
// Let's use solid light grey/tertiary mix to distinguish from coating.
material cladMat = material(diffusepen=gray(0.9), specularpen=white, shininess=0.8);

// Coating/Buffer: Protective layer, use Primary (Teal)
material coatMat = material(diffusepen=primary, specularpen=gray(0.5), shininess=0.4);


// --- Geometry ---
real fiberLength = 8.0;
real coatR = 1.0;
real cladR = 0.65;
real coreR = 0.25;

// --- Drawing Function ---
void drawStrippedFiber(triple start, triple dirVec) {
    triple dir = unit(dirVec);
    
    real lenCoat = fiberLength * 0.5;
    real lenClad = fiberLength * 0.3;
    real lenCore = fiberLength * 0.2;
    
    // 1. Coating Section
    triple p1 = start;
    triple p2 = start + dir * lenCoat;
    
    // Cylinder
    draw(surface(cylinder(p1, coatR, lenCoat, dir)), coatMat);
    // Start cap
    draw(surface(circle(p1, coatR, normal=-dir)), coatMat);
    // End step face (Coating material)
    draw(surface(circle(p2, coatR, normal=dir)), coatMat);
    
    // 2. Cladding Section
    triple p3 = p2 + dir * lenClad;
    // Cylinder
    draw(surface(cylinder(p2, cladR, lenClad, dir)), cladMat);
    // End step face (Cladding material)
    draw(surface(circle(p3, cladR, normal=dir)), cladMat);
    
    // 3. Core Section
    triple p4 = p3 + dir * lenCore;
    // Cylinder
    draw(surface(cylinder(p3, coreR, lenCore, dir)), coreMat);
    // End face (Core material)
    draw(surface(circle(p4, coreR, normal=dir)), coreMat);
}

// --- Scene ---

// 1. Main stripped fiber in foreground
// Slightly angled
drawStrippedFiber((-4, 0, 0), (1, 0.2, 0));


