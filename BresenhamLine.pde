/*
Use Bresenham's line algorithm to draw a line on the raster between
 the two given points. Modify the raster using setColor() and setPixel() ONLY.
 */
 
void bresenhamLine(int fromX, int fromY, int toX, int toY) {
  loadPixels();
  //First need to decide which direction will be the fast direction
    float error=0.0;
    float slope=(float)((fromY)-(toY))/((fromX)-(toX));
    /*2 cases for the slope, and 2 cases for the fast direction */
    int scenario=-1;
    if(fromX<toX && fromY<toY){
      scenario=0;
    }
    else if(fromX>toX && fromY<toY){
      scenario=1;
    }
    else if(fromX>toX && fromY>toY){
      scenario=2;
    }
    else if(fromX<toX && fromY>toY){
      scenario=3;
    }
    else if(fromX>=toX && fromY<toY){
      scenario=4;
    }
    else if(fromX>=toX && fromY>toY){
      scenario=5;
    }
    else if(fromX>toX && fromY<=toY){
    scenario=6;
    }
    switch(scenario){
      case 0:
        if(toX-fromX>=toY-fromY){
          while(fromX<toX){
            setPixel(fromX,fromY);
            fromX++;
            error=error+slope;
            if(error>=0.5){
              fromY++;
              error=error-1.0;
            }
          }
        }
        else{
          slope=1/slope;
          while(fromY<toY){
            setPixel(fromX,fromY);
            fromY++;
            error=error+slope;
            if(error>=0.5){
              fromX++;
              error=error-1.0;
            }
          }
        }
    case 1:
      if(fromX-toX>=toY-fromY){
        while(fromX>toX){
          setPixel(fromX,fromY);
          fromX--;
          slope=abs(slope);
          error=error+slope;
          if(error>=0.5){
            fromY++;
            error=error-1.0;
          }
        }
      }
      else{
        slope=1/abs(slope);
        while(fromY<toY){
          setPixel(fromX,fromY);
          fromY++;
          error=error+slope;
          if(error>=0.5){
            fromX--;
            error=error-1.0;
          }
        }
      }
  case 2:
    if(fromX-toX>=fromY-toY){
      while(fromX>toX){
        setPixel(fromX,fromY);
        fromX--;
        slope=abs(slope);
        error=error+slope;
        if(error>=0.5){
          fromY--;
          error=error-1.0;
        }
      }
    }
    else{
      slope=1/abs(slope);
      while(fromY>toY){
        setPixel(fromX,fromY);
        fromY--;
        error=error+slope;
        if(error>=0.5){
          fromX--;
          error=error-1.0;
        }
      }
    }
  case 3:
    if(toX-fromX>=fromY-toY){
      slope=abs(slope);
      while(fromX<toX){
        setPixel(fromX,fromY);
        fromX++;
        error=error+slope;
        if(error>=0.5){
          fromY--;
          error=error-1.0;
        }
      }
    }
    else{
      slope=1/abs(slope);
      while(fromY>toY){
        setPixel(fromX,fromY);
        fromY--;
        error=error+slope;
        if(error>=0.5){
          fromX++;
          error=error-1.0;
        }
      }
    }
  case 4:
    while(fromY<toY){
      setPixel(fromX,fromY);
      fromY++;
    }
  case 5:
    while(fromY>toY){
      setPixel(fromX,fromY);
      fromY--;
    }
  case 6:
    while(fromX>toX){
      setPixel(fromX,fromY);
      fromX--;
    }
  case -1:
    while(fromX<toX){
      setPixel(fromX,fromY);
      fromX++;
    }
  }
    updatePixels();
}

/*
Don't change anything below here
 */

final int LENGTH_X = 125;
final int LENGTH_Y = 125;
final int LINE_OFFSET = 52;

void testBresenham() {
  final color WHITE = color(1f, 1f, 1f);
  final color RED = color(1f, 0f, 0f);

  final int CENTER_X = 125;
  final int CENTER_Y = 125;

  buffer.updatePixels(); // display everything drawn so far

  buffer.stroke(RED);
  // comparison lines
  drawTestAllQuadrants(CENTER_X, CENTER_Y);

  buffer.loadPixels(); // switch back to editing raster
  setColor(WHITE);

  // using the implementation of Bresenham's algorithm
  drawBresenhamAllQuadrants(CENTER_X, CENTER_Y);
}

void drawBresenhamAllQuadrants(int centerX, int centerY) {
  for (int signX=-1; signX<=1; signX+=2) {
    int startX = signX*centerX;
    for (int signY=-1; signY<=1; signY+=2) {
      int startY = signY*centerY;
      drawBresenhamPattern(startX, startY);
    }
  }
}

void drawBresenhamPattern(int startX, int startY) {
  for (int sign=-1; sign<=1; sign+=2) {
    int endXHorizontal = startX + sign*LENGTH_X;
    int endYVertical = startY + sign*LENGTH_Y;
    bresenhamLine(startX, startY, endXHorizontal, startY);
    bresenhamLine(startX, startY, startX, endYVertical);
  }

  for (int signX=-1; signX<=1; signX+=2) {
    int endXHorizontal = startX + signX*LENGTH_X;
    int endXOffset = startX + signX*LINE_OFFSET;
    for (int signY=-1; signY<=1; signY+=2) {
      int endYVertical = startY + signY*LENGTH_Y;
      int endYOffset = startY + signY*LINE_OFFSET;
      bresenhamLine(startX, startY, endXOffset, endYVertical);
      bresenhamLine(startX, startY, endXHorizontal, endYOffset);
    }
  }
}

void drawTestAllQuadrants(int centerX, int centerY) {
  for (int signX=-1; signX<=1; signX+=2) {
    int startX = signX*centerX;
    for (int signY=-1; signY<=1; signY+=2) {
      int startY = signY*centerY;
      drawTestPattern(startX, startY);
    }
  }
}

void drawTestPattern(int startX, int startY) {
  for (int sign=-1; sign<=1; sign+=2) {
    int endXHorizontal = startX + sign*LENGTH_X;
    int endYVertical = startY + sign*LENGTH_Y;
    shiftedLine(startX, startY, endXHorizontal, startY);
    shiftedLine(startX, startY, startX, endYVertical);
  }

  for (int signX=-1; signX<=1; signX+=2) {
    int endXHorizontal = startX + signX*LENGTH_X;
    int endXOffset = startX + signX*LINE_OFFSET;
    for (int signY=-1; signY<=1; signY+=2) {
      int endYVertical = startY + signY*LENGTH_Y;
      int endYOffset = startY + signY*LINE_OFFSET;
      shiftedLine(startX, startY, endXOffset, endYVertical);
      shiftedLine(startX, startY, endXHorizontal, endYOffset);
    }
  }
}

void shiftedLine(int x0, int y0, int x1, int y1) {
  final int LINE_SHIFT = 3;

  // shift left/right or up/down
  int xDir = -Integer.signum(y1 - y0);
  int yDir = Integer.signum(x1 - x0);

  int px0 = rasterToProcessingX(x0 + xDir*LINE_SHIFT);
  int py0 = rasterToProcessingY(y0 + yDir*LINE_SHIFT);

  int px1 = rasterToProcessingX(x1 + xDir*LINE_SHIFT);
  int py1 = rasterToProcessingY(y1 + yDir*LINE_SHIFT);

  buffer.line(px0, py0, px1, py1);
}

int rasterToProcessingX(int rx) {
  return width/2 + rx;
}

int rasterToProcessingY(int ry) {
  return height/2 - ry;
}
