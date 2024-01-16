// GLOBAL CONSTANTS

final int NUM_DIMENSIONS = 3;

// when you store (r,g,b) values in an array,
//USE THESE NAMED CONSTANTS to access the entries
final int R = 0;
final int G = 1;
final int B = 2;

// when you store (ambient,diffuse,specular) values in an array,
//USE THESE NAMED CONSTANTS to access the entries
final int A = 0;
final int D = 1;
final int S = 2;

// colors for drawing and filling triangles
final float[] OUTLINE_COLOR = {1.0f, 0.3f, .1f};
final float[] FLAT_FILL_COLOR = {1f, 1f, 1f};
final float[][] PHONG_COLORS = {{0.15f, 0.65f, 1f}, {0.15f, 0.65f, 1f}, {1f, 1f, 1f}} ; // A, D, S colors

// for projection and lighting
PVector EYE = new PVector(0, 0, 600); // location

// Phong lighting parameters
PVector LIGHT = new PVector(300, 300, 350); // location
final float[] MATERIAL = {0.4, 0.5, 0.5}; // A, D, S
final float PHONG_SHININESS = 100; // exponent

/*
 A shortcut, because exponents are costly: only include the specular term
 if (R dot V) > SPECULAR_FLOOR
 */
final float SPECULAR_CUTOFF = 0.01;
final float SPECULAR_FLOOR = (float)Math.pow(SPECULAR_CUTOFF, 1/PHONG_SHININESS);

// to change the current color
// assorted overloads provided for convenience
color stateColor;
void setColor(float[] col) {
  stateColor = color(col[R], col[G], col[B]);
}

void setColor(float red, float green, float blue) {
  stateColor = color(red, green, blue);
}

void setColor(color c) {
  stateColor = c;
}

void setPixel(PVector p) {
  setPixel(p.x, p.y);
}

// draw a pixel at the given location
void setPixel(float x, float y) {
  int index = indexFromXYCoord(x, y);
  if (0 <= index && index < buffer.pixels.length) {
    buffer.pixels[index] = stateColor;
  } else {
    println("ERROR:  this pixel is not within the raster.");
  }
}

// helper functions for pixel calculations
int indexFromXYCoord(float x, float y) {
  int col = colNumFromXCoord(x);
  int row = rowNumFromYCoord(y);
  return indexFromColRow(col, row);
}

int indexFromColRow(int col, int row) {
  return row*width + col;
}

int colNumFromXCoord(float x) {
  return (int)round(x + width/2);
}

int rowNumFromYCoord(float y) {
  return (int)round(height/2 - y);
}

/*
 Perspective projection. Parameter v is a 3D vector.
 Returns null if v is behind the position of the eye -- watch out for that result
 when you use this function in your code!
 The math being implemented here will be covered later in the course.
 */
final float PERSPECTIVE = 0.002; // don't change this value
PVector projectVertex(PVector v) {
  float adjZ = v.z - EYE.z;  // negative z direction points into the screen
  if (adjZ >= 0) return null; // clipping plane at z coord of eye
  adjZ = -adjZ; // use |z| for division
  PVector p = new PVector(v.x/(adjZ*PERSPECTIVE), v.y/(adjZ*PERSPECTIVE), 0);
  return p;
}
