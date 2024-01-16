final char KEY_OUTLINE = 'o';
final char KEY_ROTATE = ' ';
final char KEY_NORMALS = 'n';
final char KEY_NEXT_DISPLAY = 'd';
final char KEY_PREV_DISPLAY = 'e';
final char KEY_NEXT_SHADING = 's';
final char KEY_PREV_SHADING = 'w';

final int NUM_DISPLAY_MODES = DisplayMode.values().length;
final int NUM_SHADING_MODES = ShadingMode.values().length;

enum DisplayMode {
    TEST_LINES, // Bresenham's algorithm
    SINGLE_TRIANGLE, // single-triangle test mode
    CYLINDER, // cylinder built from triangles
}
DisplayMode displayMode = DisplayMode.TEST_LINES;

enum ShadingMode {
  NONE, // no shading
    FLAT, // solid colour
    BARYCENTRIC, // visualize barycentric coords
    PHONG_FACE, // Phong lighting calculated at triangle centers
    PHONG_VERTEX, // Phong lighting calculated at each vertex and averaged
    PHONG_GOURAUD, // Phong lighting calculated at each vertex, Gouraud shaded
    PHONG_SHADING // pixel-level Phong shading
}
ShadingMode shadingMode = ShadingMode.NONE;

/*
 Flags to turn on or off various features.
 Your code must implement each of these.
 */
boolean doOutline = true;
boolean doRotate = false;
boolean doNormals = false;

void keyPressed() {
  if (key == KEY_NEXT_DISPLAY) {
    int nextDisplay = getNextOrdinal(displayMode, NUM_DISPLAY_MODES);
    displayMode = DisplayMode.values()[nextDisplay];
  } else if (key == KEY_PREV_DISPLAY) {
    int prevDisplay = getPreviousOrdinal(displayMode, NUM_DISPLAY_MODES);
    displayMode = DisplayMode.values()[prevDisplay];
  } else if (key == KEY_NEXT_SHADING) {
    int nextShading = getNextOrdinal(shadingMode, NUM_SHADING_MODES);
    shadingMode = ShadingMode.values()[nextShading];
  } else if (key == KEY_PREV_SHADING) {
    int prevShading = getPreviousOrdinal(shadingMode, NUM_SHADING_MODES);
    shadingMode = ShadingMode.values()[prevShading];
  } else if (key == KEY_OUTLINE) {
    doOutline = !doOutline;
  } else if (key == KEY_ROTATE) {
    doRotate = !doRotate;
  } else if (key == KEY_NORMALS) {
    doNormals = !doNormals;
  }
  printSettings();
}

int getNextOrdinal(Enum e, int enumLength) {
  return (e.ordinal() + 1) % enumLength;
}

int getPreviousOrdinal(Enum e, int enumLength) {
  return (e.ordinal() + enumLength - 1) % enumLength;
}

void printSettings() {
  String msg = "";
  msg += "Shading Mode: " + shadingMode + "  ";
  if (doRotate) msg += "(rotate) ";
  if (doOutline) msg += "(outlines) ";
  if (doNormals) msg += "(normals) ";
  println(msg);
}
