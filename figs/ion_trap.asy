settings.outformat = "png";
settings.render = 8; // High quality render (reduced for animation speed)
import graph3;
import solids;
include "figs/AutoColors.asy.tmp";

size(500);
currentprojection = perspective(8, -10, 4);

currentlight = light(gray(0.45), specular=gray(0.85), (12, 8, 15), (-8, -12, 10));
currentlight.background = background;

// --- Materials ---
// Metallic copper for rods
material copperRod = material(diffusepen=grey, specularpen=rgb(0.9, 0.8, 0.6), shininess=0.8);
// Black material for the mounts (rough plastic/anodized metal)
material blackMount = material(diffusepen=primary, specularpen=gray(0.2), shininess=0.3);
// Bright glowing green for ions (emissive)
material glowingIon = material(diffusepen=tertiary, specularpen=white);
// Steel for the posts
material steelPost = material(diffusepen=secondary, specularpen=gray(0.8), shininess=0.9);

// --- Dimensions ---
real rodLength = 8.0;
real rodRadius = 0.15;
real trapRadius = 0.7; // Distance from center axis to rod center
real mountRadius = 1.6;
real mountThickness = 0.6;
real postHeight = 2.5;
real postRadius = 0.4;
real centerHoleRadius = 0.5; // Optical access hole in the mount

// --- Lighting ---
// Dark background to make it glow
// light(background, diffuse[], specular[], directions[])
// currentlight = light(
//     background=rgb(0.05, 0.05, 0.05),
//     diffuse=new pen[] {rgb(0.0, 1.0, 0.0), gray(0.3)},
//     specular=new pen[] {rgb(0.5, 1.0, 0.5), gray(0.3)},
//     position=new triple[] {(10, 0, 0), (0, -10, 10)}
// );

// --- Helper Functions ---

// Draw the 4 rods
void drawRods() {
    real rodOffset = trapRadius; 
    pair[] rodPos = {
        (rodOffset, rodOffset),
        (rodOffset, -rodOffset),
        (-rodOffset, -rodOffset),
        (-rodOffset, rodOffset)
    };

    for (pair pos : rodPos) {
        triple startPos = (-rodLength/2, pos.x, pos.y);
        triple endPos = (rodLength/2, pos.x, pos.y);
        triple rodAxis = endPos - startPos;
        draw(surface(cylinder(startPos, rodRadius, rodLength, rodAxis)), copperRod);
    }
}

// Draw Mounts (End Caps)
void drawMounts() {
    real[] centers = {-rodLength/2, rodLength/2};
    for (real xCenter : centers) {
        triple center = (xCenter - mountThickness/2, 0, 0);
        draw(surface(cylinder(center, mountRadius, mountThickness, X)), blackMount);
        draw(surface(circle((xCenter - mountThickness/2,0,0), mountRadius, normal=X)), blackMount);
        draw(surface(circle((xCenter + mountThickness/2,0,0), mountRadius, normal=X)), blackMount);
    }
}

// Draw Support Posts
void drawPosts() {
    real mountX = rodLength/2;
    triple postBaseR = (mountX, 0, -mountRadius - postHeight);
    draw(surface(cylinder(postBaseR, postRadius, postHeight, Z)), steelPost);
    triple postBaseL = (-mountX, 0, -mountRadius - postHeight);
    draw(surface(cylinder(postBaseL, postRadius, postHeight, Z)), steelPost);
}

// --- Ions Pre-calculation ---
srand(42);
int nIons = 100;
// Tighter confinement
real cloudLen = 2.0; // Reduced from 3.0
real cloudWidth = 0.2; // Reduced from 0.4

triple[] ionPositions;
for (int i = 0; i < nIons; ++i) {
    triple pos;
    while(true) {
        real x = (unitrand()*2 - 1) * cloudLen;
        real y = (unitrand()*2 - 1) * cloudWidth;
        real z = (unitrand()*2 - 1) * cloudWidth;
        if ( (x/cloudLen)^2 + (y/cloudWidth)^2 + (z/cloudWidth)^2 <= 1.0 ) {
            pos = (x, y, z);
            break;
        }
    }
    ionPositions.push(pos);
}

// --- Animation Loop ---
//animation A;
//int nFrames = 30;

//for (int f = 0; f < nFrames; ++f) {
    //save();
    //real t = f * 2 * pi / nFrames;
    
    // Draw Static Scene
    drawRods();
    drawMounts();
    drawPosts();
    
    int t = 0;
    //// Draw Animated Ions
    for (int i = 0; i < nIons; ++i) {
        triple basePos = ionPositions[i];
        
        // Wiggle Logic
        // Use index 'i' to give each ion a unique phase
        real phase = i * 2.5; 
        
        // Oscillate slightly in x, y, z
        // Amplitude: 0.03 length-wise, 0.01 radial
        real dx = 0.03 * sin(t + phase);
        real dy = 0.01 * cos(t + phase * 1.3);
        real dz = 0.01 * sin(t + phase * 0.7);
        
        triple wiggle = (dx, dy, dz);
        
        draw(shift(basePos + wiggle) * scale3(0.05) * unitsphere, glowingIon);
    }
    
    //A.add();
    //restore();
//}

//A.movie(loops=0, delay=50);
