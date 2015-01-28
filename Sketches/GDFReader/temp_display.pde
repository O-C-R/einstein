//
void tempDisplayStuff(PGraphics pg) {
  pg.pushMatrix();
  pg.translate(width/2, height/2);

  for (Map.Entry me : edges.entrySet ()) {
    Edge e = (Edge)me.getValue();
    pg.strokeWeight(.5);
    gradientLine(pg, e.from.pos.x, e.from.pos.y, e.to.pos.x, e.to.pos.y, e.from.c, e.to.c, 55);
    //pg.stroke(255, 10);
    //pg.line(e.from.pos.x, e.from.pos.y, e.to.pos.x, e.to.pos.y);
  }   

  for (Map.Entry me : nodes.entrySet ()) {
    Node n = (Node)me.getValue();
    pg.pushMatrix();
    pg.translate(n.pos.x, n.pos.y);
    pg.noStroke();
    pg.fill(n.c, 30);
    pg.ellipse(0, 0, n.dims.x, n.dims.y);
    pg.popMatrix();
  }


  pg.popMatrix();
} // end tempDisplayStuff


//
// draw a gradient between two points 
void gradientLine(PGraphics pg, float x1, float y1, float x2, float y2, color c1, color c2, int divisions) {
  color c = c1;
  //pg.strokeCap(SQUARE);
  for (int i = 1; i <= divisions; i++) {
    pg.stroke(c);
    pg.line(map(i - 1, 0, divisions, x1, x2), map(i - 1, 0, divisions, y1, y2), map(i, 0, divisions, x1, x2), map(i, 0, divisions, y1, y2));
    c = lerpColor(c1, c2, (float)i / (divisions - 1));
  }
} // end gradientLine
//
//
//
//

