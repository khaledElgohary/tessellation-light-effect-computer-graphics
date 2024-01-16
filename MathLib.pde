/*
Define any mathematical operations that you need here.
 */
 
PVector crossProduct(PVector v1,PVector v2){
  return v1.cross(v2);
}

PVector normalizeVector(PVector v1){
  PVector v2=v1.normalize();
  return v2;
}

PVector increaseL(PVector v1,int mag){
  PVector r=v1.mult(mag);
  return r;
}
