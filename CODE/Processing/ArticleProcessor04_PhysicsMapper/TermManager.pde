//
// this holds the terms.. concepts defined by alchemy
class TermManager {
  ArrayList<Term> terms = new ArrayList();
  HashMap<String, Term> termsHM = new HashMap(); // hash version

  // save the occurance counts
  HashMap<Term, Integer> totalTermOccurances = new HashMap(); // storage of the total number of times this Term happened
  HashMap<Term, Integer> totalTermArticles = new HashMap(); // storage of the articles that had this term

  int totalOccurancesOfAllTerms = 0; // count of all terms and all of their occurances.  used for gravity making?

  Term selectedTerm = null;


  //
  void addTerm(Term t) {
    terms.add(t);
    termsHM.put(t.term, t);
    println(t);
  } // end addTerm



  //
  void loadDefaultTermPositions(String dirName) {
    String[] options = OCRUtils.getFileNames(dirName, false);
    String fileName = "";
    for (String s : options) if (s.contains("defaultPositions.json")) fileName = s;
    if (fileName.length() > 0) readInTermPositions(fileName);
  } // end loadDefaultTermPositions

  //
  // this will save the current positions in the default location
  void saveDefaultPositions(String dirName) {
    println("in saveDefaultPositions");
    saveTermPositions(dirName + "defaultPositions");
  } // end saveDefaultPositions



  // use the counts of terms to assign gravities
  public void assignGravities(int articleCount) {
    // make it the some sort of idf
    for (Term t : terms) {

      int docCount = (Integer)totalTermArticles.get(t); // how many documents this term appears in 
      int occurances = (Integer)totalTermOccurances.get(t); // how many times this term appears overall
      // reminder: totalOccurancesOfAllTerms is the count of all terms
      float gravity = 0;
      if (docCount > 0) gravity = log((float)articleCount / (float)docCount);
      t.gravity = gravity;
      println("term: " + t.term + " -- articleCount: " + articleCount + "  docCount: "  + docCount + "   gravity: " + gravity);
    }
  } // end assignGravities


  // set the positions of all article to the exact positions
  // use for starting out
  public void setArticlesToExactPositions(ArrayList<Article> articles) {
    //println("in setArticlesToExactPositions");
    //println("in setArticlesToExactPositions");
    //println("in setArticlesToExactPositions");
    for (Article a : articles) {
      Vec2 precisePosition = getVecTargetPos(a);
      //println("xxxxx precisePosition: " + precisePosition);
      //println("   double check of precise world position to screen: " + box2d.vectorWorldToPixelsPVector(precisePosition));
      // add a littttttle variation so it wiggles
      precisePosition.y += random(-3, 3);
      a.setTarget(precisePosition);
      a.setExactPosition(precisePosition);
    }
  } // end setArticlesToExactPositions

  //
  // run when a term is released.. 
  public void updateArticleTargets(ArrayList<Article> articlesIn) {
    for (Article a : articlesIn) a.setTarget(getVecTargetPos(a));
  } // end updateArticleTargets

  //
  // get the target pos based on the percentages of key terms

  public Vec2 getVecTargetPos(Article a) {
    // find where this wants to be based on the terms.  add the total.  multiplier by the count?
    float totalPoints = 0f;
    HashMap<Term, Float> tempScores = new HashMap();
    // make the total first
    for (int i = 0; i < a.terms.length; i++) {
      //int multiplierOccurance = a.termCounts[i];
      //float multiplierForBeingInTitle = 1.5;
      Term t = a.terms[i];
      //float termScore = t.gravity * (multiplierOccurance + (a.termInTitle[i] ? multiplierForBeingInTitle : 0f));
      float termScore = t.gravity * a.termScores[i];
      tempScores.put(t, termScore);
      totalPoints += termScore;
    }
    PVector newPos = new PVector();
    // then make the percentage
    for (Term t : a.terms) {
      float termScore = (Float)tempScores.get(t);
      float percentOfWhole = termScore / totalPoints;
      newPos.x += percentOfWhole * t.pos.x;
      newPos.y += percentOfWhole * t.pos.y;
    }





    return box2d.coordPixelsToWorld(newPos.x, newPos.y);

    //return box2d.coordPixelsToWorld(random(width), random(height));
    //return box2d.coordPixelsToWorld(400, 400);
  } //end getVecTargetPos

  //
  //public float getForceAdjustment







  //
  void update(PVector worldLocIn) {
    for (Term t : terms) t.update(worldLocIn);
  } // end update

  //
  void debugDisplay(PGraphics pg) {
    for (Term t : terms) {
      t.debugDisplay(pg);
    }
  } // end display

  //
  void showPhysics(PGraphics pg) {
    for (Term t : terms) {
      t.showPhysics(pg);
    }
  } // end showPhysics

  //
  // when pressed, find a if a term can be selected
  void dealWithMousePressed(PVector mouse, boolean isRight) {
    //println("in dealWithMousePressed for termManager");
    // deselect all .. if any.. terms
    if (!isRight) {
      for (Term t : terms) {
        if (t.selected) t.deselect(mouse);
      }
      // search for a term that the mouse is over
      for (Term t : terms) {
        if (t.ptIsOver(mouse)) {
          selectedTerm = t;
          break;
        }
      }
      if (selectedTerm != null) {
        println("selected term: " + selectedTerm.term);
        selectedTerm.select(mouse);
      }
    } else {
      for (Term t : terms) {
        if (t.ptIsOver(mouse)) {
          if (t.particle.isLocked()) t.releaseHardLock();
          else t.setHardLock();
          break;
        }
      }
    }
  } // end dealWithMousePressed

  //
  void dealWithMouseDragged(PVector mouse) {
    if (selectedTerm != null) {
      selectedTerm.drag(mouse);
    }
  } // end dealWithMouseDragged

  //
  void dealWithMouseReleased(PVector mouse, ArrayList<Article> articlesIn) {
    if (selectedTerm != null) {
      selectedTerm.deselect(mouse);
      updateArticleTargets(articlesIn); // update all article targets
    }
    for (Term t : terms) if (t.selected) t.deselect(mouse);
    selectedTerm = null;
  } // end dealWithMouseReleased

  //
  // will randomly throw the terms in the width/height
  void setTermPositionsRandom() {
    for (Term t : terms) t.setPosition(new PVector(random(width), random(height)));
  } // end setTermPositionsRandom

  //
  void setTermPositionsLeft() {
    for (Term t : terms) t.setPosition(new PVector(-100, t.pos.y));
  } // end setTermPositionsLeft

  //
  void saveTermPositions(String fileName) {
    JSONObject json = new JSONObject();
    JSONArray jar = new JSONArray();
    for (Term t : terms) {
      JSONObject jj = new JSONObject();
      jj.setString("term", t.term);
      println("term: " + t.term);
      jj.setFloat("x", t.pos.x);
      jj.setFloat("y", t.pos.y);
      jar.setJSONObject(jar.size(), jj);
    }
    json.setJSONArray("terms", jar);
    saveJSONObject(json, fileName + ".json");
  } // end writeOutTermPositions

  //
  void readInTermPositions(String fileName) {
    println("in readInTermPositions for TermManager");
    try {
      JSONObject json = loadJSONObject(fileName);
      JSONArray jar = json.getJSONArray("terms");
      for (int i = 0; i < jar.size (); i++) {
        JSONObject jj = jar.getJSONObject(i);
        String termName = jj.getString("term");
        float x = jj.getFloat("x");
        float y = jj.getFloat("y");
        PVector pos = new PVector(x, y);
        Term t = (Term)termsHM.get(termName);
        t.setPosition(pos);
      }
    } 
    catch (Exception e) {
    }
  } // end readInTermPositions
} // end class TermManager




// 
// this is the thing that will actually setup the term network in the physics world
//  what it's doing is evenly repelling each one by a constant
//  but the connections between the terms are as such:
//   a strength is calculated for the similarity between the two terms by taking an average of the scores of the articles that they both contain
//     and then dividing that by the number of articles that they contain
//     thus theoretically the maximum 'average' is 2 because the score, which ranges from 0 to 1, is added from both terms
//     this score is then used for the strength by mapping the result on a log scale, eg, from 0 to log(2) from a min strength of 0 to the max strength
//   the length is determined by looking at the ratio of shared articles.
//     by taking the highest percent of articles shared and then mapping it on a constrained scale between a min and max length
//   
public void makeTermNetwork() {
  physics.clear();
  // clear any existing springs?
  // make random spots for all
  for (int i = 0; i < termManager.terms.size (); i++) {
    Term t1 = termManager.terms.get(i);
    t1.particle.x = random(width);
    t1.particle.y = random(height);
  }

  // then assign the pulls towards one another based on the articles between them
  // do it by count?
  // do it by score?
  // by average score between the articles..?
  int maxNumberOfConnections = 0;
  float scoreDivider = 1f; // to weaken it a bit?
  float attractLength = 0f;
  float minAttractLength = 20f;
  float maxAttractLength = 220f;
  float attractStrength = 0f;
  float maxAttractStrength = .03;
  for (int i = 0; i < termManager.terms.size (); i++) {
    Term t1 = termManager.terms.get(i);
    for (int j = i + 1; j < termManager.terms.size (); j++) {
      Term t2 = termManager.terms.get(j);
      int similarArticleCount = 0;
      float totalArticleScore = 0f;
      int totalArticles = t1.articleIndex.size() + t2.articleIndex.size();
      for (Map.Entry t1Me : t1.articleIndex.entrySet ()) {
        Article art = (Article)t1Me.getKey();
        float t1Score = t1.articleScores[(Integer)t1.articleIndex.get(art)];
        if (t2.articleIndex.containsKey(art)) {
          float t2Score = t2.articleScores[(Integer)t2.articleIndex.get(art)];
          totalArticleScore += t2Score + t1Score;
          similarArticleCount++;
        }
      }
      if (similarArticleCount > 0) {
        // make a new strength
        float averageScore = totalArticleScore / similarArticleCount;
        attractStrength = constrain(map(log(averageScore), 0, log(2), 0, maxAttractStrength), 0, maxAttractStrength);
        float highestSharedPercent = max((float)similarArticleCount / t1.articleIndex.size(), (float)similarArticleCount / t2.articleIndex.size());
        attractLength = constrain(map(highestSharedPercent, 0, .5, maxAttractLength, minAttractLength), minAttractLength, maxAttractLength);
        
         
        if (attractStrength < .5 * maxAttractStrength) continue;
        println("similar: " + similarArticleCount + " attractStrength: " + attractStrength + " highestSharedPercent: " + highestSharedPercent);
        VerletParticle2D a = t1.particle;
        VerletParticle2D b = t2.particle;
        VerletSpring2D spring = new VerletSpring2D(a, b, attractLength, attractStrength);
        physics.addSpring(spring);
        t1.addConnection(t2, attractStrength);
        t2.addConnection(t1, attractStrength);
        maxNumberOfConnections = (maxNumberOfConnections > t1.connections.size() ? maxNumberOfConnections : t1.connections.size());
      }
    }
  }

  // first assign all the repulsion springs
  float repulseLength = 160;
  float repulseStrength = .01;
  for (int i = 0; i < termManager.terms.size (); i++) {
    Term t1 = termManager.terms.get(i);
    for (int j = i + 1; j < termManager.terms.size (); j++) {
      Term t2 = termManager.terms.get(j);
      VerletParticle2D a = t1.particle;
      VerletParticle2D b = t2.particle;
      VerletMinDistanceSpring2D spring = new VerletMinDistanceSpring2D(a, b, repulseLength, repulseStrength);
      physics.addSpring(spring);
    }
  }

  // make a relative count of the connections used for fill
  for (Term t : termManager.terms) t.relativeConnectionPercentile = ((float)t.connections.size()) / maxNumberOfConnections;
} // end makeTermNetwork

//
//
//
//
//
//
//
//
//

