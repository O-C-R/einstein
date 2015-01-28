class Circle {
  
  boolean rollover = false;
  //boolean clicked = false;
  
  float x, y, diam;
  
  Circle (float _x, float _y, float _diam) {
    x = _x;
    y = _y;
    diam = _diam;
    
  }
  
  void display(boolean overlay) {
    noStroke();
    
    if (overlay) fill (100, 100);
    else fill(255,0,0,30);
    ellipse(x, y, diam, diam);
  }
  
  void rollover(float mx, float my, float diameter) {
    float disX = x - mx;
    float disY = y - my;
    if(sqrt(sq(disX) + sq(disY)) < diameter/2) {
      rollover = true;
    } else {
      rollover = false;
    }
  }
  
  float distanceToCenter(float mx, float my) {
   float disX = x - mx;
   float disY = y - my;
   float mouseCenterDist = sqrt(sq(disX) + sq(disY));
   return mouseCenterDist;
  }
   
}
