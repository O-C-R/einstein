// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2010
// Toxiclibs example: http://toxiclibs.org/

// Force directed graph
// Heavily based on: http://code.google.com/p/fidgen/

// Notice how we are using inheritance here!
// We could have just stored a reference to a VerletParticle object
// inside the Node class, but inheritance is a nice alternative

class Node extends VerletParticle2D {
  PVector localPos = new PVector();
  boolean ptIsOver = false;
  boolean selected = false;
  
  Node(Vec2D pos) {
    super(pos);
  }
  
  //
  void update(PVector pt) {
    ptIsOver = ptIsOver(pt);
  } // end update

  // All we're doing really is adding a display() function to a VerletParticle
  void display() {
    fill(0, 150);
    if (ptIsOver) fill(255, 0, 0, 150);
    stroke(0);
    ellipse(x, y, 16, 16);
  }

  //
  boolean ptIsOver(PVector pt) {
    localPos.set(x, y);
    if (pt.dist(localPos) <= 16) return true;
    return false;
  } // end ptIsOver
}

