//
// this tab is all about making an area to check titles of articles

//
class SpotCheck {
  boolean isSelecting = false; // set to true when mouse is pressed for the first time
  boolean isDone = false; // set to true when mouse is realeased
  PVector start = new PVector(); // the starting corner position
  PVector end = new PVector () ; // the ending corner position
  ArrayList<Iguana> iguanas = new ArrayList(); 

  // display coords
  PVector upLeft = new PVector();
  PVector downRight = new PVector();  

  //
  public void setStart(PVector start) {
    this.start = start.get();
    isSelecting = true;
    println("starting a SpotCheck at coord " + start);
  } // end setStart

    //
  // set while selecting
  public void setEnd(PVector end) {
    this.end = end.get();
  } // end setEnd

  //
  // set when mouse is released
  public void setIsDone() {
    isDone = true;
    println("done setting spot check coordinates with end: " + end);
  } // end setIsDone


  //
  public void update(HashMap<String, Article> articlesHMIn) {
    upLeft = new PVector((start.x < end.x ? start.x : end.x), (start.y < end.y ? start.y : end.y));
    downRight = new PVector((start.x > end.x ? start.x : end.x), (start.y > end.y ? start.y : end.y));

    if (isDone) {
      // make the Iguaga objects
      iguanas.clear();
      PVector center = PVector.add(upLeft, downRight);
      center.div(2);
      for (Map.Entry me : articlesHMIn.entrySet ()) {
        Article a = (Article)me.getValue();
        PVector articleScreenPos = new PVector(screenX(a.regPos.x, a.regPos.y, a.z), screenY(a.regPos.x, a.regPos.y, a.z));
        if (articleScreenPos.x >= upLeft.x && articleScreenPos.x <= downRight.x && articleScreenPos.y >= upLeft.y && articleScreenPos.y <= downRight.y) {
          Iguana iggy = new Iguana(articleScreenPos, center.dist(articleScreenPos), a);
          iguanas.add(iggy);
        }
      }
      // sort the iguanas by distance
      iguanas = OCRUtils.sortObjectArrayListSimple(iguanas, "distance");
    }
  } // end update

  //
  public boolean endOfCycle() {
    if (isDone) return true;
    return false;
  } // end endOfCycle

    // 
  public void saveOutSpot(PGraphics pg) {
    println("in saveOutSpot for " + iguanas.size() + " objects within the marquee");
    String saveDirectory = "spotChecks/" +  OCRUtils.getTimeStampWithDate() + "/";
    String fileName = saveDirectory + "list.txt";
    PrintWriter output = createWriter(fileName);
    for (Iguana iggy : iguanas) output.println(iggy);
    output.flush();
    output.close();
    // and image
    fileName = saveDirectory + "img.jpg";

    saveFrame(fileName);
  } /// end saveOutSpot

  //
  public void display(PGraphics pg) {
    if (isSelecting) {
      //println(upLeft + " -- " + downRight + " \\\\ " + start + " -- " + end);
      // draw the stuff
      pg.pushStyle();
      pg.rectMode(CORNER);    
      // fade out surrounding stuff
      pg.strokeWeight(3);
      pg.fill(0, 130);
      pg.rect(0, 0, width, upLeft.y);
      pg.rect(0, downRight.y, width, height);
      pg.rect(0, upLeft.y, upLeft.x, downRight.y - upLeft.y);
      pg.rect(downRight.x, upLeft.y, width - downRight.x, downRight.y - upLeft.y);

      // redraw the main rect
      pg.noFill();
      pg.stroke(255);
      pg.rect(upLeft.x, upLeft.y, downRight.x - upLeft.x, downRight.y - upLeft.y);    
      pg.popStyle();
    }
  } // end display
} // end class SpotCheck

//
// this will just hold article related screen position stuff
class Iguana {
  PVector screenPos;
  float distance = 0f; // distance from the SpotCheck center
  Article article = null;
  //
  Iguana(PVector screenPos, float distance, Article article) {
    this.screenPos = screenPos;
    this.distance = distance;
    this.article = article;
  } // end constructor
  //
  String toString() {
    String builder = article.title;
    //builder += "\n     distance from center: " + nfc((int)distance) + " -- id: " + article.id;
    //builder += "\n     screen position: " + screenPos;
    return builder;
  } // end toString
} // end class Iguana

//
//
//
//
//
//

