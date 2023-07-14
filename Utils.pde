
PVector rotateY(PVector v, float angle){
  float tmpX = v.x;
  v.x = cos(angle)*v.x + sin(angle)*v.z;
  v.z = cos(angle)*v.z - sin(angle)*tmpX;
  return v;
}

PVector rotateX(PVector v, float angle){
  float tmpY = v.y;
  v.y = cos(angle)*v.y - sin(angle)*v.z;
  v.z = cos(angle)*v.z + sin(angle)*tmpY;
  return v;
}
