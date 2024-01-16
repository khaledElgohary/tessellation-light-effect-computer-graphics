class Triangle {
  static final int NUM_VERTICES = 3;

  PVector[] vertices = new PVector[NUM_VERTICES];
  PVector[] vertexNormals = new PVector[NUM_VERTICES];

  Triangle(PVector[] vertices, PVector[] normals) {
    for (int j=0; j<NUM_VERTICES; j++) {
      this.vertices[j] = vertices[j].copy();
      this.vertexNormals[j] = normals[j].copy();
      this.vertexNormals[j].normalize();
    }
    updateAll();
  }

  // if triangle vertices and/or vertex normals change, update remaining data
  void updateAll() {
  }

  void setVectors(PVector[] newVertices, PVector[] newNormals) {
    for (int j=0; j<Triangle.NUM_VERTICES; j++) {
      vertices[j] = newVertices[j].copy();
      vertexNormals[j] = newNormals[j].copy();
    }
    updateAll();
  }
}

/*
The original and rotated lists should already be initialized.
 Each rotated triangle is updated to be a copy of the corresponding original
 triangle after its vertices have been rotated by angle theta.
 */
void rotateTriangles(Triangle[] original, Triangle[] rotated, float theta) {
  if (original == null || rotated == null) return;
  for (int i=0; i<original.length; i++) {
    PVector[] rotatedVertices = new PVector[Triangle.NUM_VERTICES];
    PVector[] rotatedNormals = new PVector[Triangle.NUM_VERTICES];
    for (int j=0; j<Triangle.NUM_VERTICES; j++) {
      rotatedVertices[j] = getRotatedVertex(original[i].vertices[j], theta);
      rotatedNormals[j] = getRotatedVertex(original[i].vertexNormals[j], theta);
    }
    rotated[i].setVectors(rotatedVertices, rotatedNormals);
  }
}

/*
Parameter v is a 3D vector. Return a copy of v after
 rotating by angle theta about the x, y and z axes in succession.
 This math will be covered later in the course.
 */
PVector getRotatedVertex(PVector v, float theta) {
  PVector r = v.copy();
  for (int axis=X; axis<=Z; axis++) {
    eulerRotate(r, theta, axis);
  }
  return r;
}

/*
Rotate 3D vector in place about the given axis
 */
void eulerRotate(PVector v, float theta, int rotateIndex) {
  float[] vectorArray = v.array();
  int ind1 = (rotateIndex+1) % NUM_DIMENSIONS;
  int ind2 = (rotateIndex+2) % NUM_DIMENSIONS;

  float tmp1, tmp2;

  tmp1 = vectorArray[ind1]*cos(theta) - vectorArray[ind2]*sin(theta);
  tmp2 = vectorArray[ind1]*sin(theta) + vectorArray[ind2]*cos(theta);
  vectorArray[ind1] = tmp1;
  vectorArray[ind2] = tmp2;
  v.set(vectorArray);
}

Triangle[] copyTriangleList(Triangle[] originalList) {
  if (originalList == null) return null;
  Triangle[] copyList = new Triangle[originalList.length];
  for (int i=0; i<originalList.length; i++) {
    copyList[i] = new Triangle(originalList[i].vertices, originalList[i].vertexNormals);
  }
  return copyList;
}
