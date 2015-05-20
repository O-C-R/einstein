//
class Term {
  int id = 0;
  String term = "";

  // each term will have a gravity associated with it
  float gravity = 1f; // gravity -- how much it pulls
  // each term will also have a location associated with it
  PVector pos = new PVector();
  // and a radius
  float rad = 10f;


  boolean mouseIsOver = false;
  boolean selected = false;
  PVector selectedOffset = new PVector();


  // for visualizing the articles that are connected to this Term
  Article[] articles = new Article[0]; // the articles connected to this term
  float[] articleCounts = new float[0];


  //
  Term (int id, String term) {
    this.id = id;
    this.term = term;
  } // end constructor


  //
  public void update(PVector pt) {
    // always record if mouse is over
    if (ptIsOver(pt)) mouseIsOver = true;
    else mouseIsOver = false;
  } // end update



    //
  boolean ptIsOver(PVector pt) {
    if (pt.dist(pos) <= rad) return true;
    return false;
  } // end ptIsOver

  //
  public void select(PVector pt) {
    selected = true;
    selectedOffset = PVector.sub(pt, pos);
  } // nd select

  //
  public void drag(PVector pt) {
    PVector change = PVector.add(pos, selectedOffset);
    PVector diff = PVector.sub(pt, change);
    pos.add(diff);
  } // end drag

  //
  public void deselect(PVector pt) {
    selected = false;
  } // end deselect

  //
  public void setPosition(PVector pos) {
    this.pos = pos.get();
  } // end setPosition

  //
  public void debugDisplay(PGraphics pg) {
    pg.pushMatrix();
    pg.translate(pos.x, pos.y);
    pg.noFill();
    pg.stroke(255, 0, 0);
    pg.ellipse(0, 0, 2 * rad, 2 * rad);
    if (mouseIsOver) {
      pg.stroke(255);
      pg.ellipse(0, 0, 2 * rad + 2, 2 * rad + 2);
    }
    pg.fill(255, 0, 0);
    pg.textAlign(CENTER, CENTER);

    pg.text(term + "\n" + nf(gravity, 0, 2) + "\n" + (int)pos.x  + ", " + (int)pos.y, 0, 0);

    pg.popMatrix();

    // connect to term positions
    if (mouseIsOver) {
      pg.stroke(0, 127, 225, 100);
      for (int i = 0; i < articles.length; i++) {
        pg.pushStyle();
        Article a = articles[i];
        pg.strokeWeight(articleCounts[i]);
        pg.line(pos.x, pos.y, a.regPos.x, a.regPos.y);
        pg.popStyle();
      }
    }
  } // end debugDisplay


  //
  public String toString() {
    String builder = "Term: " + id + " -- " + term + "   gravity: " + gravity;
    builder += "\n   pos: " + pos;
    return builder;
  } // end toString
} // end class Term

//
//
//
//
//

