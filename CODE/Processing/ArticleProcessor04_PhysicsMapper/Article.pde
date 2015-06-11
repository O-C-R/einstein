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
  //int[] termCounts = new int[0]; // the count of times this term occurs... sentences and title
  float[] termScores = new float[0]; // the score of times this term occurs... alchemy scores
  //boolean[] termInTitle = new boolean[0]; // if the term is in the title
  HashMap<Term, Integer> termIndex = new HashMap(); // Term, index for above arrays where the term lives

  // wos characteristics  
  public String abstractString = "";
  public String[] abstractSentences = new String[0]; // the abstract String split into sentences
  public int publishedYear = 0; // year of publication
  public String[] subjectArea = new String[0];

  public boolean isValid = true; // marked as false if the basic criteria isnt met

  public PVector pos = new PVector();




  // author vars
  HashMap<String, Integer> authorCounts = new HashMap(); // from the author search
  int authorCountsSum = 0; // sum of all papers listed for the authors
  // this is a list of the authors listed for this article 
  // and the integer is the number of other Articles they are linked to via Arxiv

  // cites vars
  HashMap<String, Integer> citerIds = new HashMap(); // <Citer id, nothing> a list of all of the id's of things that cite this Article
  HashMap<String, ArrayList<Article>> citerBuddies = new HashMap(); // <citer id, ArrayList of other Articles that also have this citerId> for each citerID here is a list of other current Articles that cite the same thing.  if no other articles cite it then it will just be a blank ArrayList
  // reference vars
  HashMap<String, Integer> referenceIds = new HashMap(); // <reference id, nothing> a list of all of the id's of things that this Article references
  HashMap<String, ArrayList<Article>> referenceBuddies = new HashMap(); // <reference id, ArrayList of other Articles that also have this referenceId> for each referenceId here is a list of other current Articles that reference the same thing.  if no other articles reference it then it will just be a blank ArrayList


  // temporary variables
  int temp = 0; // used for temporarily assigning values
  ArrayList<Object> objs = new ArrayList();
  float temp2 = 0f; // also used for whatever sorting

  Calendar cal = null;

  //box2d stuff
  Body body = null; // the box2d object of the article
  float radius = random(3, 20); // the radius used for the box2d and for the screen display
  Vec2 regPosVec2 = new Vec2(); // the screen vec2 pos of the article
  PVector regPos = new PVector(); // the screen pos of the article
  Vec2 targetVec2 = new Vec2(); // the vec2 world pos of the target??
  PVector target = new PVector(); // the screen position of the target


  // TERMLESS ARTICLES
  // keep track of the search by a search of the concepts within the abstract
  boolean hasConceptInText = false;
  HashMap<Term, Integer> hasConceptInTextCounts = new HashMap(); // <the Term, the count within the abstract> 
  // for those articles that don't have any terms nor any keyword matches, a position will be determined by the average of it's reference buddies and cite buddies
  boolean isTermless = true; 





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


    //polygon
    /*
    int sideCount = (int)random(3, 8);
     //sideCount = 8; // 8 is the max??
     Vec2[] vertices = new Vec2[0];  // An array of 4 vectors
     //vertices[0] = box2d.vectorPixelsToWorld(new Vec2(-15, 25));
     //vertices[1] = box2d.vectorPixelsToWorld(new Vec2(15, 0));
     //vertices[2] = box2d.vectorPixelsToWorld(new Vec2(20, -15));
     //vertices[3] = box2d.vectorPixelsToWorld(new Vec2(-10, -10));
     float angle = 0f;
     float division = TWO_PI / (sideCount);
     for (int i = 0; i < sideCount; i++) {
     radius = random(10, 30);
     Vec2 pt = new Vec2(cos(angle) * radius, sin(angle) * radius);
     println(pt + " -- angle: " + angle);
     vertices = (Vec2[])append(vertices, box2d.vectorPixelsToWorld(pt));
     angle += division;
     }
     
     //Making a polygon from that array
     PolygonShape ps = new PolygonShape();
     ps.set(vertices, vertices.length);
     */

    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = cs; // for circle
    //fd.shape = ps; // for polygon
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0.3;
    fd.restitution = 0.5;

    body.createFixture(fd);

    body.setLinearVelocity(new Vec2());
    //body.setAngularVelocity(random(-1, 1));
  } // end setupBody

  //
  // will set the body to the box2d position
  public void setExactPosition (Vec2 exactPosition) {
    if (body != null) body.setTransform(exactPosition, 0);
    //println("setting position to: " + exactPosition);
    //println(" box2d.vectorWorldToPixelsPVector(targetVec2);: " + box2d.vectorWorldToPixelsPVector(exactPosition));
    //println("   double check of screen coords of body: " + box2d.getBodyPixelCoord(body));
  } // end setExactPosition

  //
  // will set the targetVec2 to the box2d world position
  public void setTarget(Vec2 targetVec2) {
    this.targetVec2 = targetVec2;
    //println("setting target to: " + targetVec2);
  } // end setTarget


  // with the new concept base, use the Alchemy score
  public void addTerm(Term t, float score) {
    terms = (Term[])append(terms, t);
    termScores = (float[])append(termScores, score);
    termIndex.put(t, termIndex.size());
    isTermless = false;
  } // end addTerm

  //
  // when an article is termless, will look to see if the text of the term is in the abstract, if so keep track of it
  public void addHasConceptInText(Term t, int count) {
    hasConceptInTextCounts.put(t, count);
    hasConceptInText = true;
  } // end addHasConceptInText


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
    pg.fill(255, 127);
    if (isTermless && hasConceptInText) pg.fill(127, 255, 155, 70);
    else if (isTermless && !hasConceptInText) pg.fill(255, 255, 0, 70);
    pg.stroke(255, 127);

    // draw the circle
    pg.ellipse(0, 0, 2 * radius, 2.5 * radius);

    // draw the polygon
    /*
    Fixture f = body.getFixtureList();
     PolygonShape ps = (PolygonShape) f.getShape();
     float a = body.getAngle();
     pg.rotate(-a);
     pg.beginShape();
     for (int i = 0; i < ps.getVertexCount (); i++) {
     Vec2 v = box2d.vectorWorldToPixels(ps.getVertex(i));
     pg.vertex(v.x, v.y);
     }
     pg.endShape(CLOSE);
     pg.rotate(a);
     */


    boolean isOver = false;
    if (doCheck) {
      if (pt.x >= regPos.x - radius  && pt.x <= regPos.x  + radius && pt.y >= regPos.y - radius && pt.y <= regPos.y + radius) {

        String tempTermList = "";
        for (int i = 0; i < terms.length; i++) {
          //tempTermList += "\ni:" + i + "-" + terms[i].term + "-" + termCounts[i];
          tempTermList += "\ni:" + i + "-" + terms[i].term + "-" + termScores[i];
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
          //pg.strokeWeight(termCounts[i]);
          pg.strokeWeight(10 * termScores[i]);
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
    builder += "\n total: " + authorCountsSum + " -- by authors:";
    for (Map.Entry me : authorCounts.entrySet ()) {
      builder += "\n  " + (String)me.getKey() + " -- " + (Integer)me.getValue();
    }
    builder += "\n total CITERS: " + citerIds.size() + " and cite buddies: " + citerBuddies.size();
    for (Map.Entry me : citerBuddies.entrySet ()) {
      String citerId = (String)me.getKey();
      ArrayList<Article> buddies = (ArrayList<Article>)me.getValue();
      builder += "\n  id: " + citerId + " buddies.size(): " + buddies.size();
      for (Article a : buddies) builder += "\n     id: " + a.id;
    }
    builder += "\n total REFERENCES: " + referenceIds.size() + " and reference buddies: " + referenceBuddies.size();
    for (Map.Entry me : referenceBuddies.entrySet ()) {
      String referenceId = (String)me.getKey();
      ArrayList<Article> buddies = (ArrayList<Article>)me.getValue();
      builder += "\n  id: " + referenceId + " buddies.size(): " + buddies.size();
      for (Article a : buddies) builder += "\n     id: " + a.id;
    }
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

