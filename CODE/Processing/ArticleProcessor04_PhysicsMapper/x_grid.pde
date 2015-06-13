//
public void drawGrid(PGraphics pg, ArrayList<Float> zs, PVector centerXY, float xExtents, float yExtents, color col) {
  float gridStrokeWeight = 1f;
  float divisions = 20;
  for (Float z : zs) {
    pg.pushMatrix();
    PVector center = new PVector(centerXY.x, centerXY.y, z);
    pg.translate(center.x, center.y, center.z);
    for (float x = -xExtents; x <= xExtents; x+= (2 * xExtents) / divisions) {
      pg.stroke(col);
      pg.strokeWeight(gridStrokeWeight);
      pg.line(x, -yExtents, x, yExtents);
    }
    for (float y = -yExtents; y <= yExtents; y+= (2 * yExtents) / divisions) {
      pg.stroke(col);
      pg.strokeWeight(gridStrokeWeight);
      pg.line(-xExtents, y, xExtents, y);
    }
    pg.popMatrix();
  }
} // end drawGrid

//
//
//
//
//
//
//

