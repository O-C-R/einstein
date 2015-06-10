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
    termManager.setTermPositionsRandom();
  }
  if (key == 's') {
    termManager.saveDefaultPositions(termDirectory);
  }
  if (key == 'd') {
    termManager.loadDefaultTermPositions(termDirectory);
  }
  if (key == '-') {
    //termManager.setTermPositionsLeft();
    termManager.setArticlesToExactPositions(articles);
  }
  if (key == 'b') {
    box2dOn = !box2dOn;
  }


  if (key == '\\') {
    println("going to setup the term network");
    makeTermNetwork();
  }
  if (key == '[') {
    showPhysics = !showPhysics;
    println("changed showPhysics to: " + showPhysics);
  }
  if (key == 'p') {
    physicsOn = !physicsOn;
    println("physicsOn set to: " + physicsOn);
  }
} // end keyReleased

//
//
//
//

