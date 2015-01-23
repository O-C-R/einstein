class Circle {
  
  boolean rollover = false;
  boolean clicked = false;
  
  float x, y, diam;
  
  Circle (float _x, float _y, float _diam) {
    x = _x;
    y = _y;
    diam = _diam;
    
  }
  
  void display() {
    noStroke();
    
    if (rollover) fill (100, 100);
    else fill(255,0,0,30);
    ellipse(x, y, diam, diam);
  }
  
  void rollover(float mx, float my, float diameter) {
    float disX = x - mx;
    float disY = y - my;
    if(sqrt(sq(disX) + sq(disY)) < diameter/2) {
      rollover = true;
      //println("rollover is true");
    } else {
      rollover = false;
      //println("rollover is false");
    }
  }
  
  boolean intersect(Circle c) {
    float distance = dist(x, y, c.x, c.y); //calculate distance
    
    //compare distance to sum of radii
    if(distance < diam/2 + c.diam/2) {
      return true;
    } else {
      return false;
    }
  }
    
  void overlap(ArrayList circles) {
    for(int i=0; i<circles.size(); i++) {
      Circle circle1 = (Circle)circles.get(i);
      for(int j=i+1; j<circles.size(); j++) {
        if(j!=i) {
          Circle circle2 = (Circle)circles.get(j);
          
          //calculate distance
          float dx = circle1.x - circle2.x;
          float dy = circle1.y - circle2.y;
          float distance = (sqrt(dx*dx+dy*dy));
          
          if(distance < circle1.diam/2 + circle2.diam/2) {
            println("overlap");
          }
        }
      }
    }
  }
}
