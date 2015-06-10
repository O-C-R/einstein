//
void mousePressed() {
  boolean isRight = false;
  if (mouseButton == LEFT) {
    termManager.dealWithMousePressed(worldLoc, isRight);
  } else if (mouseButton == RIGHT) {
    isRight = true;
    termManager.dealWithMousePressed(worldLoc, isRight);
  }
} // end mousePressed


//
void mouseReleased() {
  if (mouseButton == RIGHT) {
    zpt.dealWithMouseReleased();
  } else if (mouseButton == LEFT) {
    termManager.dealWithMouseReleased(worldLoc, articles);
  }
} // end mouseReleased

//
void mouseDragged() {
  PVector mouseOffset = new PVector(pmouseX - mouseX, pmouseY - mouseY);
  if (mouseButton == RIGHT) {
    zpt.dealWithMouseDragged(mouseLoc, mouseOffset);
  } else if (mouseButton == LEFT) {
    if (lockDefaultTermPositions) return;
    termManager.dealWithMouseDragged(worldLoc);
  }
} // end mouseDragged

//
void mouseWheel(MouseEvent event) {
  float amt = event.getAmount();
  zpt.dealWithMouseWheel(amt, mouseLoc);
} // end mouseWheel

//
void keyReleased() {
  if (key == 'i') {
    println("inputting the term locations");
    selectInput("Choose term location file:", "inputTermLocations");
  }
  if (key == 'z') {
    // output the layers -- all pdf maps and text and all that stuff
    println("saving out the term locations");
    selectOutput("Write out the term locations to file:", "outputTermLocations");
  }
  if (key == '=') {
    if (lockDefaultTermPositions) return;
    termManager.setTermPositionsRandom();
  }
  if (key == 's') {
    if (lockDefaultTermPositions) return;
    termManager.saveDefaultPositions(sketchPath("") + termDirectory);
  }
  if (key == 'd') {
    if (lockDefaultTermPositions) return;
    termManager.loadDefaultTermPositions(sketchPath("") + termDirectory);
  }
  if (key == '-') {
    //termManager.setTermPositionsLeft();
    termManager.setArticlesToExactPositions(articles);
  }
  if (key == 'b') {
    box2dOn = !box2dOn;
  }


  if (key == '\\') {
    if (lockDefaultTermPositions) return;
    println("going to setup the term network");
    makeTermNetwork();
  }
  if (key == '[') {
    showPhysics = !showPhysics;
    println("changed showPhysics to: " + showPhysics);
  }
  if (key == 'p') {
    if (lockDefaultTermPositions) return;
    physicsOn = !physicsOn;
    println("physicsOn set to: " + physicsOn);
  }
  if (key == ' ') {
    if (lockDefaultTermPositions) return; 
    // lock any currently selected term.  eg if you're dragging it you can lock it so physics doesnt apply any more
    for (Term t : termManager.terms) {
     if (t.selected) t.setHardLock(); 
    }
  } 
  if (key == '`') {
   saveFrame("frames/" + OCRUtils.getTimeStampWithDate() + ".tif"); 
   println("saved frame");
  }
} // end keyReleased

//
//
//
//

