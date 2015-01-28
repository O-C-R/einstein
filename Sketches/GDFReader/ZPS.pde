class ZoomPanSimple {
  final static int ZOOM_OUT = 4;
  final static int ZOOM_IN = 5;

  PApplet parent;

  float sc = 1f;
  PVector offset = new PVector();
  PVector currentWorldLoc = new PVector();

  //
  ZoomPanSimple(PApplet parent) {
    this.parent = parent;
  } // end constructor

  //
  void use() {
    parent.g.pushMatrix();
    parent.g.translate(offset.x, offset.y);
    parent.g.scale(sc);
  } // end use

  //
  void pause() {
    parent.g.popMatrix();
  } // end pause

  public void zoomIn() {
    zoom(ZOOM_IN);
  } // end zoomIn

  public void zoomOut() {
    zoom(ZOOM_OUT);
  } // end zoomOut

  private void zoom(int whereTo) {  
    float scaleAmt = .1;
    switch(whereTo) {
    case ZOOM_IN:
      sc = sc * (1 + scaleAmt);
      offset.set(offset.x + (offset.x - mouseX) * scaleAmt, offset.y + (offset.y - mouseY) * scaleAmt);
      break;
    case ZOOM_OUT:
      sc = sc * (1 - scaleAmt);
      offset.set(offset.x - (offset.x - mouseX) * scaleAmt, offset.y - (offset.y - mouseY) * scaleAmt);
      break;
    } // end switch
  } // end moveWorld

  //
  PVector getWorldCoordFromPoint(PVector mouseLoc) {
    PVector worldCoord = new PVector();
    worldCoord.set(mouseLoc.x, mouseLoc.y);
    worldCoord.sub(offset);
    worldCoord.div(sc);
    return worldCoord;
  } // end getWorldCoordFromPoint

  //
  void dealWithMouseDragged() {
    PVector offset = new PVector(parent.pmouseX - parent.mouseX, parent.pmouseY - parent.mouseY);
    this.offset.set(this.offset.x - offset.x, this.offset.y - offset.y);
  } // end dealWithMouseDragged

  //
  void dealWithMouseWheel(MouseEvent event) {
    float e = event.getAmount();
    if (e != 0) {
      if (e < 0) zoomIn();
      else zoomOut();
    }
  } // end dealWithMouseWheel
} // end class ZoomPanSimple

