


//
// this will render everything to separate pdf frames
// by setting the renderIndex to zero it will darw out one part each frame
public void renderThings() {
  println(frameCount + " in renderThings.  starting render");
  renderDirectory = "renders/" + OCRUtils.getTimeStampWithDate() + "/";
  renderIndex = 0;
} // end renderThings

//
// this will simply draw some crosses off to the side so that the imags can be lined up
public void drawRegistration(PGraphics pg) {
  float len = 20;
  ArrayList<PVector> locs = new ArrayList();
  locs.add(new PVector(-100, -100));
  locs.add(new PVector(width + 100, height + 100));
  for (PVector p : locs) {
    pg.pushMatrix();
    pg.translate(p.x, p.y);
    pg.stroke(colorRegistration);
    pg.line(-len/2, 0, len/2, 0);
    pg.line(0, -len/2, 0, len/2);
    pg.popMatrix();
  }
} // end drawRegistration

//
//
//
//
//
//
//
//
//
//

