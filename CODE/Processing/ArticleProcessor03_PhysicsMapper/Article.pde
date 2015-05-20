//
class Article {
  //
  public XML xml = null; // the original xml

    //
  public String id = "";
  public String title = "";
  public String[] authors = new String[0];

  // term stuff - keep track of which terms this article belongs to
  Term[] terms = new Term[0]; // the term.  only added if it has at least one occurance in this article
  int[] termCounts = new int[0]; // the count of times this term occurs... sentences and title
  boolean[] termInTitle = new boolean[0]; // if the term is in the title
  HashMap<Term, Integer> termIndex = new HashMap(); // Term, index for above arrays where the term lives

  // wos characteristics  
  public String abstractString = "";
  public String[] abstractSentences = new String[0]; // the abstract String split into sentences
  public int publishedYear = 0; // year of publication
  public String[] subjectArea = new String[0];

  public boolean isValid = true; // marked as false if the basic criteria isnt met

  public PVector pos = new PVector();

  HashMap<String, Article> citers = new HashMap(); // articles that cite this one
  HashMap<String, Article> cites = new HashMap(); // articles that this one is recorded as citing

  // temporary variables
  int temp = 0; // used for temporarily assigning values
  ArrayList<Object> objs = new ArrayList();
  float temp2 = 0f; // also used for whatever sorting

  Calendar cal = null;

  //box2d stuff
  Body body = null; // the box2d object of the article
  float radius = 20; // the radius used for the box2d and for the screen display
  Vec2 regPosVec2 = new Vec2(); // the screen vec2 pos of the article
  PVector regPos = new PVector(); // the screen pos of the article
  Vec2 targetVec2 = new Vec2(); // the vec2 world pos of the target??
  PVector target = new PVector(); // the screen position of the target


  //
  Article(String id) {
    this.id = id;
  } // end constructor

  //
  public void setupBody(float radius) {
    this.radius = radius;
    // Define a body
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;

    // Set its position
    //bd.position = box2d.coordPixelsToWorld(x,y);
    bd.position = new Vec2();

    bd.linearDamping = .95; // SET THE 'FRICTION' 

    body = box2d.world.createBody(bd);

    // Make the body's shape a circle
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(radius);

    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0.3;
    fd.restitution = 0.5;

    body.createFixture(fd);

    body.setLinearVelocity(new Vec2(random(-5, 5), random(-5, -5)));
    //body.setAngularVelocity(random(-1, 1));
  } // end setupBody

  //
  // will set the body to the box2d position
  public void setExactPosition (Vec2 exactPosition) {
    if (body != null) body.setTransform(exactPosition, 0);
    println("setting position to: " + exactPosition);
    println(" box2d.vectorWorldToPixelsPVector(targetVec2);: " + box2d.vectorWorldToPixelsPVector(exactPosition));
    println("   double check of screen coords of body: " + box2d.getBodyPixelCoord(body));
  } // end setExactPosition

  //
  // will set the targetVec2 to the box2d world position
  public void setTarget(Vec2 targetVec2) {
    this.targetVec2 = targetVec2;
    println("setting target to: " + targetVec2);
  } // end setTarget

  //a.addTermCount(term, occurance, occursInTitle);
  // 
  public void addTermCount(Term t, int occurance, boolean occursInTitle) {
    terms = (Term[])append(terms, t);
    termCounts = (int[])append(termCounts, occurance);
    termInTitle = (boolean[])append(termInTitle, occursInTitle);
    termIndex.put(t, termIndex.size());
  } // end addTermCount


  //
  // articles that cite this thing
  public void addCiter(Article a) {
    if (!citers.containsKey(a.id)) citers.put(a.id, a);
  } // end addCiter


  //
  // articles that this thing cites
  public void addCites(Article a) {
    if (!cites.containsKey(a.id)) cites.put(a.id, a);
  } // end addCite


  //
  public void update() {
    if (body != null) {
      regPosVec2 = box2d.getBodyPixelCoord(body);
      regPos.set(regPosVec2.x, regPosVec2.y);
      //target = box2d.vectorWorldToPixelsPVector(targetVec2); << this one sucks!
      Vec2 tmp = box2d.coordWorldToPixels(targetVec2);  // this is the one to use to convert a box2d world vec2 to a screen vec2
      target.set(tmp.x, tmp.y);

      // do apply force stuff
      Vec2 force = targetVec2.clone();
      force.subLocal(body.getWorldCenter());

      // multiply?
      force.mulLocal(10);

      body.applyForce(force, body.getWorldCenter());
    }
  } // end update

  //
  public void debugDisplayTarget(PGraphics pg) {
    pg.pushMatrix();
    pg.translate(target.x, target.y);
    pg.noFill();
    pg.stroke(0, 255, 255);
    pg.ellipse(0, 0, 5, 5);
    pg.popMatrix();
    pg.stroke(127, 50);
    pg.line(target.x, target.y, regPos.x, regPos.y);
  } // end debugDisplayTarget

  //
  public boolean debugDisplay(PGraphics pg, float sc, PVector pt, boolean doCheck) {
    pg.pushMatrix();
    pg.translate(regPos.x, regPos.y);
    pg.noFill();
    pg.stroke(255, 127);
    pg.ellipse(0, 0, 2 * radius, 2 * radius);
    boolean isOver = false;
    if (doCheck) {
      if (pt.x >= regPos.x - radius  && pt.x <= regPos.x  + radius && pt.y >= regPos.y - radius && pt.y <= regPos.y + radius) {

        String tempTermList = "";
        for (int i = 0; i < terms.length; i++) {
          tempTermList += "\ni:" + i + "-" + terms[i].term + "-" + termCounts[i];
        }
        pg.fill(255);
        pg.scale(1f/sc);
        pg.textAlign(CENTER, CENTER);
        pg.text(tempTermList, 0, 0 );
        pg.scale(sc);

        pushMatrix();

        pg.translate(-regPos.x, -regPos.y);
        pg.stroke(255, 120);
        for (int i = 0; i < terms.length; i++) {
          pushStyle();
          pg.strokeWeight(termCounts[i]);
          pg.line(regPos.x, regPos.y, terms[i].pos.x, terms[i].pos.y);
          popStyle();
        }
        popMatrix();


        isOver = true;
      }
    }
    pg.popMatrix();
    return isOver;
  } // end debugDisplay



  //
  String toString() {
    String builder = "";
    builder += "Article " + id + ": " + title;
    return builder;
  } // end toString


  //
  String toSimplifiedString() {
    String builder = "";
    //builder += id + " - " + title + "\n  abstract: " + abstractString + "\n  publishedYear " + publishedYear + " subjects: " + join(subjectArea, ", ");
    builder += id + " - " + title + "\n  publishedYear " + publishedYear + " subjects: " + join(subjectArea, ", ");
    for (String s : abstractSentences) builder += " \n    " + s;
    return builder;
  } // end toSimplifiedString
} // end class Article

//
//
//
//
//
//
//
//
//

