//
void mousePressed() {
  boolean isRight = false;
  if (mouseButton == LEFT) {
    termManager.dealWithMousePressed(worldLoc, isRight);
    // deal with spotCheck
    if (spotCheck != null) {
      if (!spotCheck.isSelecting) {
        spotCheck.setStart(mouseLoc);
      }
    }
  } else if (mouseButton == RIGHT) {
    isRight = true;
    if (termDebug) termManager.dealWithMousePressed(worldLoc, isRight);
  }
} // end mousePressed


//
void mouseReleased() {
  if (mouseButton == RIGHT) {
    zpt.dealWithMouseReleased();
  } else if (mouseButton == LEFT) {
    if (termDebug) termManager.dealWithMouseReleased(worldLoc, articles);
    if (spotCheck != null) {
      if (spotCheck.isSelecting) {
        spotCheck.setIsDone();
      }
    }
  }
} // end mouseReleased

//
void mouseDragged() {
  PVector mouseOffset = new PVector(pmouseX - mouseX, pmouseY - mouseY);
  if (mouseButton == RIGHT) {
    zpt.dealWithMouseDragged(mouseLoc, mouseOffset);
  } else if (mouseButton == LEFT) {
    if (lockDefaultTermPositions) return;
    if (termDebug) termManager.dealWithMouseDragged(worldLoc);
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

  if (key == 'd') {
    termDebug = !termDebug;
    println("termDebug set to: " + termDebug);
  }
  if (key == 't') {
    termDisplay = !termDisplay;
    println("termDisplay set to: " + termDisplay);
  }

  if (key == 'a') {
    useAngles = !useAngles;
    println("toggled useAngles to: " + useAngles);
  }
  if (key == 'c') {
    drawConnectingLines = !drawConnectingLines;
    println("drawConnectingLines set to: " + drawConnectingLines);
  }

  if (key == 'g') {
    gridOn = !gridOn;
  } 


  if (key == 'r') {
    if (physicsOn) physicsOn = false;
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
    if (physicsOn) physicsOn = false;
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
    if (box2dOn) box2dOn = false;
    println("saving specific article positions");
    selectOutput("Write out the article positions to file:", "outputArticlePositions");
  }
  if (key == '4') {
    if (box2dOn) box2dOn = false;
    println("saving specific article positions");
    selectInput("Choose an article position file to input:", "inputArticlePositions");
  }

  if (key == '8') {
    setupArticleZs(articles);
  }

  if (key == '-') {
    if (lockDefaultArticlePositions) return;
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

  if (key == 'v') {
    displayArticles = !displayArticles;
    println("displayArticles set to: " + displayArticles);
  }

  if (key == 'n') {
    displayCategories = !displayCategories;
    println("displayCategories set to: " + displayCategories);
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


  // output
  if (key == '`') {
    //saveFrame("frames/" + OCRUtils.getTimeStampWithDate() + ".tif"); 
    saveFrame("frames/" + OCRUtils.getTimeStampWithDate() + ".jpg");
    println("saved frame");
  }

  /*
// took this out because not really needed now/ to prevent accidental movie making
   if (key == 'm') {
   if (!movieSave) {
   movieSaveDirectory = "movieFrames/" + OCRUtils.getTimeStampWithDate() + "/";
   println("saving movie to " + movieSaveDirectory);
   movieSave = true;
   } else {
   println("done saving out movie");
   movieSave = false;
   }
   }
   */
  if (key == '6') {
    renderThings();
  } 
  if (key == 'x') {
    if (spotCheck == null) {
      spotCheck = new SpotCheck(); 
      println("making new SpotCheck");
    } else {
      println("cancelling out of the spot check");
      spotCheck = null;
    }
  }

  // panning stuff
  if (key == '\'') {
    zpt.centerScreenOn(new PVector(84, -46), zpt.sc.value(), 100);
  }
  if (key == ';') {
    zpt.centerScreenOn(new PVector(1150, 1346), zpt.sc.value(), 1100);
  }
} // end keyReleased

//
//
////
//
//
////
//

