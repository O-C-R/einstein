//
class Term {
  int id = 0;
  String term = "";

  // each term will have a gravity associated with it
  float gravity = 1f; // gravity -- how much it pulls
  // each term will also have a location associated with it
  PVector pos = new PVector();
  PVector lastPos = pos.get();
  // and a radius
  float rad = 10f;


  boolean mouseIsOver = false;
  boolean selected = false;
  PVector selectedOffset = new PVector();


  // for visualizing the articles that are connected to this Term
  Article[] articles = new Article[0]; // the articles connected to this term
  //float[] articleCounts = new float[0];
  float[] articleScores = new float[0]; // keep track of the article scores
  HashMap<Article, Integer> articleIndex = new HashMap(); // keep track of the index

  // physics stuff
  VerletParticle2D particle;
  ArrayList<Term> connections = new ArrayList(); // for which other Terms this is connected to 
  ArrayList<Float> connectionStrengths = new ArrayList();  // the strength of the connection
  ArrayList<Float> connectionLengths = new ArrayList();  // the length of the connection
  boolean hardLock = false; // if manually locking a thing this gets set to true
  float relativeConnectionPercentile = 0; // based on how many connections this Term has relative to the term with max no of connections

  boolean connectionSelected = false;



  //
  Term (int id, String term) {
    this.id = id;
    this.term = term;
    particle = new VerletParticle2D(new Vec2D(pos.x, pos.y));
    //physics.addParticle(particle);
  } // end constructor

  //
  public void addArticle(Article a, float score) {
    articles = (Article[])append(articles, a);
    articleScores = (float[])append(articleScores, score);
    articleIndex.put(a, articleIndex.size());
  } // end addArticle

    //
  public void addConnection(Term t, float str, float len) {
    connections.add(t);
    connectionStrengths.add(str);
    connectionLengths.add(len);
  } // end addConnection

  //
  public void update(PVector pt) {
    // always record if mouse is over
    lastPos.set(pos.x, pos.y);
    pos.set(particle.x, particle.y);
    if (ptIsOver(pt)) mouseIsOver = true;
    else mouseIsOver = false;
  } // end update

    //
  // this will reset the connectionSelected to false  
  public void resetConnectionSelected() {
    connectionSelected = false;
  } // end resetConnectionSelected

  //
  // when a buddy is selected, it will set this one to true so that it can be indicated in debugView
  public void setConnectionSelected() {
    connectionSelected = true;
  } // end setConnectionSelected



  //
  boolean ptIsOver(PVector pt) {
    if (pt.dist(pos) <= rad) return true;
    return false;
  } // end ptIsOver

  //
  public void select(PVector pt) {
    selected = true;
    selectedOffset = PVector.sub(pt, pos);
    particle.lock();
  } // nd select

  //
  public void drag(PVector pt) {
    PVector change = PVector.add(pos, selectedOffset);
    PVector diff = PVector.sub(pt, change);
    particle.x += diff.x;
    particle.y += diff.y;
  } // end drag

  //
  public void deselect(PVector pt) {
    selected = false;
    if (!hardLock) particle.unlock();
  } // end deselect

  //
  public void setPosition(PVector pos) {
    //this.pos = pos.get();
    this.particle.x = pos.x;
    this.particle.y = pos.y;
    this.pos.set(pos.x, pos.y); /// update the local position
  } // end setPosition

  //
  public void setHardLock() {
    hardLock = true;
    particle.lock();
  } // end setHardLock

    //
  public void releaseHardLock() {
    hardLock = false;
    particle.unlock();
  } // end releaseHardLock

    //
  public void debugDisplay(PGraphics pg) {
    pg.pushMatrix();
    pg.translate(pos.x, pos.y);
    pg.fill(255, 0, 0, map(relativeConnectionPercentile, 0, 1f, 0, 255));
    if (connectionSelected) {
      pg.fill(0, 255, 0, constrain(2 * map(relativeConnectionPercentile, 0, 1f, 0, 255), 0, 255));
    }
    pg.stroke(255, 0, 0);
    if (particle.isLocked()) {
      pg.stroke(0, 255, 255);
    }

    pg.ellipse(0, 0, 2 * rad, 2 * rad);

    if (mouseIsOver) {
      pg.stroke(255);
      pg.ellipse(0, 0, 2 * rad + 2, 2 * rad + 2);
    }
    pg.fill(255, 0, 0);
    pg.textAlign(CENTER, CENTER);

    pg.text(term + "\n" + nf(gravity, 0, 2) + "--" + articles.length + "\n" + (int)pos.x  + ", " + (int)pos.y, 0, 0);

    pg.popMatrix();

    // connect to term positions
    if (mouseIsOver || selected) {
      pg.stroke(0, 127, 225, 100);
      for (int i = 0; i < articles.length; i++) {
        pg.pushStyle();
        Article a = articles[i];
        //pg.strokeWeight(articleCounts[i]);
        pg.strokeWeight(10 * articleScores[i]);
        pg.line(pos.x, pos.y, a.regPos.x, a.regPos.y);
        pg.popStyle();
      }
    }
  } // end debugDisplay

  //
  public void showPhysics(PGraphics pg) {
    for (int i = 0; i < connections.size (); i++) {
      Term connection = connections.get(i);
      float strength = connectionStrengths.get(i);
      pg.pushStyle();
      pg.strokeWeight(10 * strength);
      pg.stroke(255, 100);
      pg.line(pos.x, pos.y, connection.pos.x, connection.pos.y);
      pg.popStyle();
    }
  } // end showPhysics


  //
  public String toString() {
    String builder = "Term: " + id + " --_" + term + "_   gravity: " + gravity;
    builder += "\n   pos: " + pos;
    return builder;
  } // end toString
} // end class Term

//
//
//
//
//

