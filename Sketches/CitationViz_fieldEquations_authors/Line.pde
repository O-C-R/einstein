class Line {
  
  float x1, y1, x2, y2;
  
  Line(float _x1, float _y1, float _x2, float _y2) {
    x1 = _x1;
    y1 = _y1;
    x2 = _x2;
    y2 = _y2;
  }
  
  void display() {
    //stroke(255,0,0,50);
    line(x1, y1, x2, y2);
  }
}
