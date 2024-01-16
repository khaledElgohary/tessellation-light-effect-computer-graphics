/*
COMP 3490 Assignment 1 Template
 */

// for the test mode with one triangle
Triangle[] singleTriangle;
Triangle[] rotatedSingleTriangle;

// for drawing and rotating the cylinder
Triangle[] cylinderList;
Triangle[] rotatedCylinderList;

// to make the image rotate - don't change these values
float theta = 0.0;  // rotation angle
float dtheta = 0.01; // rotation speed

PGraphics buffer;
PVector vert1=new PVector(150,250,6); //p1
PVector vert2=new PVector(100,50,6); //p2
PVector vert3= new PVector(300,100,6); //p3

PVector norm1=new PVector(50,10,8);
PVector norm2=new PVector(0,0,0);
PVector norm3=new PVector(0,0,20);

PVector[] v={vert1,vert2,vert3};
PVector[] n={norm1,norm2,norm3};

Triangle single=new Triangle(v,n);

float radiusTriangle=175;
float heightTriangle=250;
int circumTriangles= 25; // circumference triangles
int verticalTriangles= 12; //vertical triangles 

PVector circumTop=new PVector(0,heightTriangle/2,0);
PVector circumBot=new PVector(0,-heightTriangle/2,0);
PVector normalTop=new PVector(0,1,0);
PVector normalBot=new PVector(0,-1,0);


void setup() {
  // RGB values range over 0..1 rather than 0..255
  colorMode(RGB, 1.0f);

  buffer = createGraphics(600, 600);

  singleTriangle = new Triangle[]{single}; // change this line
  rotatedSingleTriangle = copyTriangleList(singleTriangle);

  cylinderList = getTesselations().toArray(new Triangle[0]); // change this line
  rotatedCylinderList = copyTriangleList(cylinderList);

  printSettings();
}

void settings() {
  size(600, 600); // hard-coded canvas size, same as the buffer
}

/*
You should read this function carefully and understand how it works,
 but you should not need to edit it
 */
void draw() {
  buffer.beginDraw();
  buffer.colorMode(RGB, 1.0f);
  buffer.background(0); // clear to black each frame

  /*
  CAUTION: none of your functions should call loadPixels() or updatePixels().
   This is already done in the template. Extra calls will probably break things.
   */
  buffer.loadPixels();

  if (doRotate) {
    theta += dtheta;
    if (theta > TWO_PI) {
      theta -= TWO_PI;
    }
  }

  //do not change these blocks: rotation is already set up for you
  if (displayMode == DisplayMode.TEST_LINES) {
    testBresenham();
  } else if (displayMode == DisplayMode.SINGLE_TRIANGLE) {
    rotateTriangles(singleTriangle, rotatedSingleTriangle, theta);
    drawTriangles(rotatedSingleTriangle);
  } else if (displayMode == DisplayMode.CYLINDER) {
    rotateTriangles(cylinderList, rotatedCylinderList, theta);
    drawTriangles(rotatedCylinderList);
  }

  buffer.updatePixels();
  buffer.endDraw();
  image(buffer, 0, 0); // draw our raster image on the screen
}

/*
 Receives an array of triangles and draws them on the raster by
 calling draw2DTriangle()
 */
void drawTriangles(Triangle[] triangles) {
  boolean normals=false;
  for(int i=0;i<triangles.length;i++){
    if(displayMode==DisplayMode.SINGLE_TRIANGLE){
      draw2DTriangle(triangles[i]);
      setColor(OUTLINE_COLOR);
    }
  else if(displayMode==DisplayMode.CYLINDER){
    fillTriangle(triangles[i],FLAT_FILL_COLOR);
    if(shadingMode==ShadingMode.NONE){
      setColor(OUTLINE_COLOR);
      draw2DTriangle(triangles[i]);
    }
    else if(shadingMode==ShadingMode.BARYCENTRIC){
      fillTriangleBarycentric(triangles[i]);
    }
    else if(shadingMode==ShadingMode.FLAT){
      fillTriangle(triangles[i],FLAT_FILL_COLOR);
    }
    else{
      phong(triangles[i]);
    }
    
    if(doNormals){
        setColor(0,100,0);
        midPointNormal(triangles[i]);
        drawNormals(triangles[i]);
      }
      
      if(doOutline&& shadingMode!=ShadingMode.NONE){
        setColor(OUTLINE_COLOR);
        draw2DTriangle(triangles[i]);
      }
  }
}
}

/*
Use the projected vertices to draw the 2D triangle on the raster.
 Several tasks need to be implemented:
 - cull degenerate or back-facing triangles
 - draw triangle edges using bresenhamLine()
 - draw normal vectors if needed
 - fill the interior using fillTriangle()
 */
void draw2DTriangle(Triangle t) {
  if(!cullTest(t)){
    drawTriangleLines(t);
  }
  if(doNormals && !cullTest(t)){
    drawTriangleLines(t);
    setColor(0,100,0);
    midPointNormal(t);
    drawNormals(t);
  }
}

/*
 Draw the normal vectors at each vertex and triangle center
 */
final int NORMAL_LENGTH = 20;
final float[] FACE_NORMAL_COLOR = {0f, 1f, 1f}; // cyan
final float[] VERTEX_NORMAL_COLOR = {1f, 1f, 0f}; // yellow

void drawNormals(Triangle t) {
  PVector[] norms=getProjectedNormals(t);
  t.vertices[0]=projectVertex(t.vertices[0]);
  t.vertices[1]=projectVertex(t.vertices[1]);
  t.vertices[2]=projectVertex(t.vertices[2]);
  bresenhamLine((int)t.vertices[0].x,(int)t.vertices[0].y,(int)norms[0].x,(int)norms[0].y);
  bresenhamLine((int)t.vertices[1].x,(int)t.vertices[1].y,(int)norms[1].x,(int)norms[1].y);
  bresenhamLine((int)t.vertices[2].x,(int)t.vertices[2].y,(int)norms[2].x,(int)norms[2].y);
}

/*
Fill the 2D triangle on the raster, using a scanline algorithm.
 Modify the raster using setColor() and setPixel() ONLY.
 */
void fillTriangle(Triangle t,float[] col) {  
  if(shadingMode == ShadingMode.FLAT){
    PVector[] vertices=new PVector[Triangle.NUM_VERTICES];
    for(int i=0;i<Triangle.NUM_VERTICES;i++){
      vertices[i]=projectVertex(t.vertices[i]);
    }
    //calculating bounding box
    int minY=(int) min(vertices[0].y,vertices[1].y,vertices[2].y);
    int maxY=(int) max(vertices[0].y,vertices[1].y,vertices[2].y);
    int maxX=(int) max(vertices[0].x,vertices[1].x,vertices[2].x);
    int minX=(int) min(vertices[0].x,vertices[1].x,vertices[2].x);
    //pixel iteration
    for(int y=minY;y<maxY;y++){
      for(int x=minX;x<maxX;x++){
        PVector point=new PVector(x,y);
        PVector e1=PVector.sub(vertices[1],vertices[0]);
        PVector e2=PVector.sub(vertices[2],vertices[1]);        
        PVector e3=PVector.sub(vertices[0],vertices[2]);
        
        PVector p1=PVector.sub(point,vertices[0]);
        PVector p2=PVector.sub(point,vertices[1]);
        PVector p3=PVector.sub(point,vertices[2]);
        
        float checker1=(e1.x * p1.y)-(e1.y*p1.x);
        float checker2=(e2.x * p2.y)-(e2.y*p2.x);
        float checker3=(e3.x * p3.y)-(e3.y*p3.x); 
        
        if(checker1>0 && checker2>0 && checker3>0){
          setColor(col);
          setPixel(x,y);
        }
      }
    }
  }
  else if(shadingMode==ShadingMode.BARYCENTRIC){
    fillTriangleBarycentric(t);
  }
}

void fillTriangleBarycentric(Triangle t)
{
    PVector[] vertices = new PVector[Triangle.NUM_VERTICES];
    for (int i = 0; i < Triangle.NUM_VERTICES; i++)
    {
        vertices[i] = projectVertex(t.vertices[i]);
    }

    // getting bounding of the triangles
    int minY = (int) min(vertices[0].y, vertices[1].y, vertices[2].y);
    int maxY = (int) max(vertices[0].y, vertices[1].y, vertices[2].y);
    int minX = (int) min(vertices[0].x, vertices[1].x, vertices[2].x);
    int maxX = (int) max(vertices[0].x, vertices[1].x, vertices[2].x);

    PVector v0 = vertices[0];
    PVector v1 = vertices[1];
    PVector v2 = vertices[2];
    
    for (int y = minY; y <= maxY; y++)
    {
        for (int x = minX; x <= maxX; x++)
        {            
            //dividing individual triangles 
            PVector p1=PVector.sub(new PVector(x,y),v0);
            PVector p2=PVector.sub(new PVector(x,y),v1);
            PVector p3=PVector.sub(new PVector(x,y),v2);
            //now what's left is to calculate u,v,w
            PVector e1=PVector.sub(v1,v0);
            PVector e2=PVector.sub(v2,v1);
            PVector e3=PVector.sub(v0,v2);
            
            p1=p1.normalize();
            p2=p2.normalize();
            p3=p3.normalize();
            e1=e1.normalize();
            e2=e2.normalize();
            e3=e3.normalize();

            float u=0.5*(((e1.x * p1.y) - (e1.y * p1.x)));
            float v=0.5*(((e3.x * p3.y) - (e3.y * p3.x)));
            float w=0.5*(((e2.x * p2.y) - (e2.y * p2.x)));
                        
            float A=0.5*(u+v+w);
            if (0 <= u && u <= 1 && 0 <= w && w <= 1 && 0 <= v && v <= 1)
            {
                setColor(u/A,v/A,w/A);
                setPixel(x, y);
            }
        }
    }
}

/*
Given a point p, unit normal vector n, eye location, light location, and various
 material properties, calculate the Phong lighting at that point (see course
 notes and the assignment text for more details).
 Return an array of length 3 containing the calculated RGB values.
 */
float[] phong(PVector p, PVector n, PVector eye, PVector light,
  float[] material, float[][] fillColor, float shininess) {
    //all vectors need to be normalized
    n=n.normalize();
    
    PVector viewerDirection=PVector.sub(eye,p);
    viewerDirection.normalize();
    
    PVector pointToLight=PVector.sub(light,p);
    pointToLight=pointToLight.normalize();
    
    //reflecting vector formula is r=d-2(d*n)n
    float dot=PVector.dot(pointToLight,n);
    PVector reflection=PVector.sub(pointToLight,PVector.mult(n,2*dot));
    reflection=reflection.normalize();
    
    float specLight=0;
    //need to check degree of prependicularity between viewer, and reflected light
    if(PVector.dot(reflection,viewerDirection)>SPECULAR_FLOOR){
      //now calculating specularity is basically material, multiplied by reflection , and viewer dot product, power the intensity
      specLight=pow(PVector.dot(reflection,viewerDirection),shininess)*material[S];
    }
    
    //color calculation
    
    float[] col=new float[NUM_DIMENSIONS];
    
    for(int x=0;x<NUM_DIMENSIONS;x++){
      //equation from notes
      col[x]=(fillColor[A][x]*material[A])+ (fillColor[D][x]*material[D]*PVector.dot(n,pointToLight))+fillColor[S][x]*specLight;
    }
    
    return col;
}


void phong(Triangle t){
  PVector v1=(t.vertices[0]);
  PVector v2=(t.vertices[1]);
  PVector v3=(t.vertices[2]);
  PVector midPoint=new PVector((int)((v1.x+v2.x+v3.x)/3),(int)((v1.y+v2.y+v3.y)/3),(int)((v1.z+v2.z+v3.z)/3));
  float[] phongCol=new float[NUM_DIMENSIONS];
  PVector n1=PVector.cross(PVector.sub(v1,midPoint),PVector.sub(midPoint,v3),null);
  n1=n1.normalize();
  n1=projectVertex(n1);
  PVector[] vertices=new PVector[Triangle.NUM_VERTICES];
  for(int i=0;i<Triangle.NUM_VERTICES;i++){
    vertices[i]=projectVertex(t.vertices[i]);
  }
  //calculating bounding box
  int minY=(int) min(vertices[0].y,vertices[1].y,vertices[2].y);
  int maxY=(int) max(vertices[0].y,vertices[1].y,vertices[2].y);
  int maxX=(int) max(vertices[0].x,vertices[1].x,vertices[2].x);
  int minX=(int) min(vertices[0].x,vertices[1].x,vertices[2].x);
  if(shadingMode==ShadingMode.PHONG_FACE){
    phongCol=phong(midPoint,n1,EYE,LIGHT,MATERIAL,PHONG_COLORS,PHONG_SHININESS);
  }
  else if(shadingMode==ShadingMode.PHONG_VERTEX){
    
    
    float[][] vertexCol=new float[Triangle.NUM_VERTICES][NUM_DIMENSIONS];
  
    for(int i=0;i<vertexCol.length;i++){
      vertexCol[i]=phong(t.vertices[i],t.vertexNormals[i],EYE,LIGHT,MATERIAL,PHONG_COLORS,PHONG_SHININESS);
    }
    
    float[] average=new float[NUM_DIMENSIONS];
    
    for(int i=0;i<NUM_DIMENSIONS;i++){
      for(int x=0;x<vertexCol.length;x++){
        average[i]=vertexCol[x][i];
      }
      average[i]=average[i]/3;
    }
    
    phongCol=average;
  }
  else if(shadingMode==ShadingMode.PHONG_GOURAUD){
    
    float[][] vertexCol=new float[Triangle.NUM_VERTICES][NUM_DIMENSIONS];
  
    for(int i=0;i<vertexCol.length;i++){
      vertexCol[i]=phong(t.vertices[i],t.vertexNormals[i],EYE,LIGHT,MATERIAL,PHONG_COLORS,PHONG_SHININESS);
    }
    
    for(int i=minY;i<maxY;i++){
      for(int x=minX;x<maxX;x++){
        PVector point=new PVector(x,i);
        PVector e1=PVector.sub(vertices[1],vertices[0]);
        PVector e2=PVector.sub(vertices[2],vertices[1]);        
        PVector e3=PVector.sub(vertices[0],vertices[2]);
        
        PVector p1=PVector.sub(point,vertices[0]);
        PVector p2=PVector.sub(point,vertices[1]);
        PVector p3=PVector.sub(point,vertices[2]);
        
        float checker1=(e1.x * p1.y)-(e1.y*p1.x);
        float checker2=(e2.x * p2.y)-(e2.y*p2.x);
        float checker3=(e3.x * p3.y)-(e3.y*p3.x); 
        
        if(checker1>0 && checker2>0 && checker3>0){
            p1=p1.normalize();
            p2=p2.normalize();
            p3=p3.normalize();
            e1=e1.normalize();
            e2=e2.normalize();
            e3=e3.normalize();

            float u=0.5*(((e1.x * p1.y) - (e1.y * p1.x)));
            float v=0.5*(((e3.x * p3.y) - (e3.y * p3.x)));
            float w=0.5*(((e2.x * p2.y) - (e2.y * p2.x)));
                        
            float A=0.5*(u+v+w);
            
            float[]colors=interpolate(new float[]{u/A,v/A,w/A},vertexCol);
            
            setColor(colors);
            setPixel(x,i);
        }
      }
    }
  }
  else{
    
    float[][] vertexCol=new float[Triangle.NUM_VERTICES][NUM_DIMENSIONS];
  
    for(int i=0;i<vertexCol.length;i++){
      vertexCol[i]=phong(t.vertices[i],t.vertexNormals[i],EYE,LIGHT,MATERIAL,PHONG_COLORS,PHONG_SHININESS);
    }
    
    for(int i=minY;i<maxY;i++){
      for(int x=minX;x<maxX;x++){
        PVector point=new PVector(x,i);
        PVector e1=PVector.sub(vertices[1],vertices[0]);
        PVector e2=PVector.sub(vertices[2],vertices[1]);        
        PVector e3=PVector.sub(vertices[0],vertices[2]);
        
        PVector p1=PVector.sub(point,vertices[0]);
        PVector p2=PVector.sub(point,vertices[1]);
        PVector p3=PVector.sub(point,vertices[2]);
        
        float checker1=(e1.x * p1.y)-(e1.y*p1.x);
        float checker2=(e2.x * p2.y)-(e2.y*p2.x);
        float checker3=(e3.x * p3.y)-(e3.y*p3.x); 
        
        if(checker1>0 && checker2>0 && checker3>0){
            p1=p1.normalize();
            p2=p2.normalize();
            p3=p3.normalize();
            e1=e1.normalize();
            e2=e2.normalize();
            e3=e3.normalize();

            float u=0.5*(((e1.x * p1.y) - (e1.y * p1.x)));
            float v=0.5*(((e3.x * p3.y) - (e3.y * p3.x)));
            float w=0.5*(((e2.x * p2.y) - (e2.y * p2.x)));
                        
            float A=0.5*(u+v+w);
            float xCol= u/A * t.vertexNormals[0].x+ u/A * t.vertexNormals[1].x + u/A * t.vertexNormals[2].x;
            float yCol= v/A * t.vertexNormals[0].y+ v/A * t.vertexNormals[1].y + v/A * t.vertexNormals[2].y;
            float zCol= w/A * t.vertexNormals[0].z+ w/A * t.vertexNormals[1].z + w/A * t.vertexNormals[2].z;
            
            PVector res=new PVector(xCol,yCol,zCol);
            
            res=res.normalize();
            
            float[] colors=phong(point,res,EYE,LIGHT,MATERIAL,PHONG_COLORS,PHONG_SHININESS);
            
            setColor(colors);
            setPixel(x,i);
        }
      }
    }
  }
  
  //pixel iteration
  if(shadingMode!=ShadingMode.PHONG_GOURAUD && shadingMode!=ShadingMode.PHONG_SHADING){
    
    for(int y=minY;y<maxY;y++){
      for(int x=minX;x<maxX;x++){
        PVector point=new PVector(x,y);
        PVector e1=PVector.sub(vertices[1],vertices[0]);
        PVector e2=PVector.sub(vertices[2],vertices[1]);        
        PVector e3=PVector.sub(vertices[0],vertices[2]);
        
        PVector p1=PVector.sub(point,vertices[0]);
        PVector p2=PVector.sub(point,vertices[1]);
        PVector p3=PVector.sub(point,vertices[2]);
        
        float checker1=(e1.x * p1.y)-(e1.y*p1.x);
        float checker2=(e2.x * p2.y)-(e2.y*p2.x);
        float checker3=(e3.x * p3.y)-(e3.y*p3.x); 
        
        if(checker1>0 && checker2>0 && checker3>0){
          setColor(phongCol);
          setPixel(x,y);
        }
      }
    }
  }
}

float[] interpolate(float[] coordinates,float[][] vertexCol){
  float[] colors=new float[NUM_DIMENSIONS];
  for(int i=0;i<NUM_DIMENSIONS;i++){
    colors[i]=coordinates[0]*vertexCol[0][i]+coordinates[1]*vertexCol[1][i]+coordinates[2]*vertexCol[2][i];
  }
  return colors;
}


//Function used to plot the bresenham's lines for the triangle
void drawTriangleLines(Triangle t){
  PVector[] projected=new PVector[3];
  for(int i=0;i<projected.length;i++){
    projected[i]=projectVertex(t.vertices[i]);
  }
  bresenhamLine((int)projected[0].x,(int)projected[0].y,(int)projected[1].x,(int)projected[1].y);
  bresenhamLine((int)projected[1].x,(int)projected[1].y,(int)projected[2].x,(int)projected[2].y);
  bresenhamLine((int)projected[2].x,(int)projected[2].y,(int)projected[0].x,(int)projected[0].y);
}




//This function calculates the normal points for the triangle, and projects them
PVector[] getProjectedNormals(Triangle t){
  PVector v1=(t.vertices[0]);
  PVector v2=(t.vertices[1]);
  PVector v3=(t.vertices[2]);
  PVector n1=PVector.cross(PVector.sub(v1,v3),PVector.sub(v2,v1),null);
  PVector n2=PVector.cross(PVector.sub(v2,v1),PVector.sub(v3,v2),null);
  PVector n3=PVector.cross(PVector.sub(v3,v2),PVector.sub(v1,v3),null);
  //Normalizing the vectors
  n1=n1.normalize();
  n2=n2.normalize();
  n3=n3.normalize();
  //Increasing the vector length to 20, for shorter lines
  n1=increaseL(n1,20);
  n2=increaseL(n2,20);
  n3=increaseL(n3,20);
  //Getting the end points
  n1=PVector.add(n1,v1);
  n2=PVector.add(n2,v2);
  n3=PVector.add(n3,v3);
  //Projecting the end points
  n1=projectVertex(n1);
  n2=projectVertex(n2);
  n3=projectVertex(n3);
  return new PVector[]{n1,n2,n3};
}

//This function is responsible for plotting the normal for the midpoint of the triangle 
void midPointNormal(Triangle t){
  PVector v1=(t.vertices[0]);
  PVector v2=(t.vertices[1]);
  PVector v3=(t.vertices[2]);
  PVector midPoint=new PVector((int)((v1.x+v2.x+v3.x)/3),(int)((v1.y+v2.y+v3.y)/3),(int)((v1.z+v2.z+v3.z)/3));
  PVector n1=PVector.cross(PVector.sub(v1,midPoint),PVector.sub(midPoint,v3),null);
  n1=n1.normalize();
  n1=increaseL(n1,20);
  n1=PVector.add(n1,midPoint);
  n1=projectVertex(n1);
  midPoint=projectVertex(midPoint);
  bresenhamLine((int)midPoint.x,(int)midPoint.y,(int)n1.x,(int)n1.y);
}

boolean cullTest(Triangle t){
  PVector v1=(t.vertices[0]);
  PVector v2=(t.vertices[1]);
  PVector v3=(t.vertices[2]);
  PVector e1=PVector.sub(projectVertex(v2),projectVertex(v1));
  PVector e2=PVector.sub(projectVertex(v3),projectVertex(v1));
  float checker=(e1.x * e2.y)-(e2.x * e1.y);
  if(checker>=1){
    return false;
  }
  else{
    return true;
  }
}

public ArrayList<Triangle> getTesselations(){
  ArrayList<Triangle> triangles= new ArrayList<>();
  //getting normals and vertices for the rims triangles
  for(int i=0;i<circumTriangles;i++){
    float theta=TWO_PI * i/circumTriangles;
    float alpha=TWO_PI * (i+1)/circumTriangles;
    
    PVector v1=new PVector(radiusTriangle*sin(theta),heightTriangle/2,radiusTriangle*cos(theta));
    PVector v2=new PVector(radiusTriangle*sin(alpha),heightTriangle/2,radiusTriangle*cos(alpha));
    PVector v3=new PVector(radiusTriangle*sin(theta),-heightTriangle/2,radiusTriangle*cos(theta));
    PVector v4=new PVector(radiusTriangle*sin(alpha),-heightTriangle/2,radiusTriangle*cos(alpha));
    
    triangles.add(new Triangle(new PVector[]{circumTop,v1,v2},new PVector[]{normalTop,normalTop,normalTop}));
    triangles.add(new Triangle(new PVector[]{circumBot,v4,v3},new PVector[]{normalBot,normalBot,normalBot}));
  }
  //getting normals and vertices for the barell triangles
  
  for(int i=0;i<circumTriangles;i++){
    float theta=TWO_PI * i/circumTriangles;
    float alpha=TWO_PI * (i+1)/circumTriangles;
    
    for(int x=0;x<verticalTriangles;x++){
      float y1= -heightTriangle/2 + x * (heightTriangle/verticalTriangles);
      float y2= -heightTriangle/2 + (x+1) * (heightTriangle/verticalTriangles);
      
      PVector v1=new PVector(radiusTriangle*sin(theta),y1,radiusTriangle*cos(theta));
      PVector v2=new PVector(radiusTriangle*sin(alpha),y1,radiusTriangle*cos(alpha));
      PVector v3=new PVector(radiusTriangle*sin(theta),y2,radiusTriangle*cos(theta));
      PVector v4=new PVector(radiusTriangle*sin(alpha),y2,radiusTriangle*cos(alpha));
      
      PVector n1=v1.copy().normalize();
      PVector n2=v2.copy().normalize();
      PVector n3=v3.copy().normalize();
      PVector n4=v4.copy().normalize();
      
      triangles.add(new Triangle(new PVector[]{v1,v2,v3},new PVector[]{n1,n2,n3}));
      triangles.add(new Triangle(new PVector[]{v3,v2,v4},new PVector[]{n3,n2,n3}));
    }
  }
  
  
  return triangles;
}
