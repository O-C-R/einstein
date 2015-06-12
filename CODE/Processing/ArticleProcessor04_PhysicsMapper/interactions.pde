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
  if (useAngles) {
    if ((keyCode == UP || keyCode == RIGHT || keyCode == LEFT || keyCode == DOWN)) {
      if (keyCode == UP || keyCode == DOWN) {
        xAngle -= (keyCode == UP ? 1 : -1) * PI/32;
      } else {
        zAngle -= (keyCode == RIGHT ? 1 : -1) * PI/32;
      }
    }
  }

  if (key == 'a') {
    useAngles = !useAngles;
    println("toggled useAngles to: " + useAngles);
  }
  if (key == 'c') {
    drawConnectingLines = !drawConnectingLines;
    println("drawConnectingLines set to: " + drawConnectingLines);
  }


  if (key == 'r') {
    println("inputting the term locations");
    selectInput("Choose term location file:", "inputTermLocations");
  }
  if (key == 'e') {
    // output the layers -- all pdf maps and text and all that stuff
    println("saving out the term locations");
    selectOutput("Write out the term locations to file:", "outputTermLocations");
  }

  if (key == 'q') {
    if (lockDefaultTermPositions) return;
    termManager.saveDefaultTermPositions(sketchPath("") + termDirectory);
  }
  if (key == 'w') {
    if (lockDefaultTermPositions) return;
    termManager.loadDefaultTermPositions(sketchPath("") + termDirectory, articlesHM);
  }

  if (key == '=') {
    if (lockDefaultTermPositions) return;
    termManager.setTermPositionsRandom();
  }

  if (key == '1') {
    if (lockDefaultArticlePositions) return;
    println("saving out default article positions");
    //saveArticlePositions(sketchPath("") + articlePositionsDirectory);
    saveDefaultArticlePositions(sketchPath("") + articlePositionsDirectory);
  }
  if (key == '2') {
    if (lockDefaultArticlePositions) return;
    println("loading default article positions");
    //loadArticlePositions(sketchPath("") + articlePositionsDirectory);
    loadDefaultArticlePositions(sketchPath("") + articlePositionsDirectory);
  }
  if (key == '3') {
    if (lockDefaultArticlePositions) return;
    println("saving specific article positions");
    selectOutput("Write out the article positions to file:", "outputArticlePositions");
  }
  if (key == '4') {
    println("saving specific article positions");
    selectInput("Choose an article position file to input:", "inputArticlePositions");
  }

  if (key == '8') {
    setupArticleZs(articles);
  }

  if (key == '-') {
    //termManager.setTermPositionsLeft();
    termManager.setArticlesToExactPositions(articles);
    termManager.updateArticleTargets(articles); // update all article targets
  }
  if (key == 'b') {
    if (lockDefaultArticlePositions) return;
    box2dOn = !box2dOn;
    println("toggling box2d to: " + box2dOn);
  }

  // change the concept z height
  if (key == '.') {
    termBaseZ += 50;
  } 
  if (key == ',') {
    termBaseZ -= 50;
  }

  if (key == 'z') {
    useArticleZ = !useArticleZ;
    println("useArticleZ set to: " + useArticleZ);
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
    saveFrame("frames/" + OCRUtils.getTimeStampWithDate() + ".jpg"); 
    println("saved frame");
  }
} // end keyReleased

//
//
//
//

