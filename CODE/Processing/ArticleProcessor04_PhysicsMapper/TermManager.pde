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
  void loadDefaultTermPositions(String dirName, HashMap<String, Article> articlesHMIn) {
    println("\n\n in loadDefaultTermPositions");
    String[] options = OCRUtils.getFileNames(dirName, false);
    String fileName = "";
    println("options.size(): "+ options.length + " for dirName: " + dirName);
    for (String s : options) {
      if (s.contains("defaultPositions.json")) {
        fileName = s;
      }
    }
    if (fileName.length() > 0) readInTermPositions(fileName, articlesHMIn);
  } // end loadDefaultTermPositions

  //
  // this will save the current positions in the default location
  void saveDefaultTermPositions(String dirName) {
    println("in saveDefaultPositions");
    saveTermPositions(dirName + "defaultPositions");
  } // end saveDefaultPositions



  // use the counts of terms to assign gravities...
  // make a sort of calculation that rewards those terms which are more specific and don't have as many..
  public void assignGravities(HashMap<String, Article> articlesHMIn) {
    float minGravity = .3;
    float maxGravity = 1f;
    float maxAverageCount = .7; // this will be the upper bound for determining gravity/pull;

    float maxCount = 0;
    float minCount = articlesHMIn.size();
    for (Term t : terms) {

      maxCount = (maxCount > t.articles.length ? maxCount : t.articles.length);
      minCount = (minCount < t.articles.length ? minCount : t.articles.length);
    }


    for (Term t : terms) {
      float gravity = minGravity;
      int docCount = t.articles.length;
      int totalDocs = articlesHMIn.size();
      if (docCount > 0) {
        /*
        float termCounts = 0;// total terms
         float termCountsAverage = 0f;
         for (Article a : t.articles) {
         termCounts += a.terms.length;
         termCountsAverage += (1f / a.terms.length);
         } 
         termCounts /= t.articles.length;
         termCountsAverage /= t.articles.length;
         gravity = constrain(map(termCountsAverage, 0, maxAverageCount, minGravity, maxGravity), minGravity, maxGravity);
         */
        gravity = constrain(map(log(docCount), 0, log(maxCount), maxGravity, minGravity), minGravity, maxGravity);
        //println("log(docCount): " + log(docCount));
        //println("log(minCount): " + log(minCount));
        //println("log(maxCount): " + log(maxCount));
      }
      //println("gravity for: " + t.term + " -- " + gravity);
      t.gravity = gravity;

      //println("term: " + t.term + " -- articleCount: " + articleCount + "  docCount: "  + docCount + "   gravity: " + gravity);
    }
  } // end assignGravities

  //
  public void setZs() {

    float maxZ = 2000f; // max height above baseZ
    float maxCount = 0;
    for (Term t : terms) maxCount = (maxCount > t.articles.length ? maxCount : t.articles.length);
    for (Term t : terms) {
      float newZ = map(t.articles.length, 0, maxCount, 0, maxZ);
      t.setZ(newZ);
    }
  } // end setZs


  // set the positions of all article to the exact positions
  // use for starting out
  public void setArticlesToExactPositions(ArrayList<Article> articles) {
    //println("in setArticlesToExactPositions");
    //println("in setArticlesToExactPositions");
    //println("in setArticlesToExactPositions");
    for (Article a : articles) {
      a.body.setLinearVelocity(new Vec2());
      Vec2 precisePosition = getVecTargetPos(a);
      //println("xxxxx precisePosition: " + precisePosition);
      //println("   double check of precise world position to screen: " + box2d.vectorWorldToPixelsPVector(precisePosition));
      // add a littttttle variation so it wiggles
      float variation = random(20);
      float angle = random(TWO_PI);
      precisePosition.y += cos(angle) * variation;
      precisePosition.x += sin(angle) * variation;
      a.setTarget(precisePosition);
      a.setExactPosition(precisePosition);
    }
  } // end setArticlesToExactPositions

  //
  // run when a term is released.. 
  public void updateArticleTargets(ArrayList<Article> articlesIn) {
    //println(frameCount + " in updateArticleTargets");
    for (Article a : articlesIn) a.setTarget(getVecTargetPos(a));
  } // end updateArticleTargets



  //
  // get the target pos based on the percentages of key terms
  // or if it has no terms get the average position of its buddies
  public Vec2 getVecTargetPos(Article a) {
    // find where this wants to be based on the terms.  add the total.  multiplier by the count?
    Vec2 newPos = new Vec2();

    // if an article has terms then use this method
    if (!a.isTermless) {
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

      // then make the percentage
      for (Term t : a.terms) {
        float termScore = (Float)tempScores.get(t);
        float percentOfWhole = termScore / totalPoints;
        newPos.x += percentOfWhole * t.pos.x;
        newPos.y += percentOfWhole * t.pos.y;
      }
      newPos = box2d.coordPixelsToWorld(newPos.x, newPos.y);
    }
    // if it has no direct terms, but some were found within the text, then use that count system to determine an average position
    else if (a.isTermless && a.hasConceptInText) {
      int total = 0;
      for (Map.Entry me : a.hasConceptInTextCounts.entrySet ()) {
        Term t = (Term)me.getKey();
        int count = (Integer)me.getValue();
        total += count;
        newPos.x += count * t.pos.x;
        newPos.y += count * t.pos.y;
      }
      newPos.x /= total;
      newPos.y /= total;
      newPos = box2d.coordPixelsToWorld(newPos.x, newPos.y);
    }
    // if it has no terms then use the cites and references to determine the average position
    // otherwise use the buddy system -- look at the buddies that share cites or references and latch on to their positions
    else {
      // ****** //
      // ****** //
      int maxBuddies = 1; // will use the average of the top n Article buddies based on their highest term score
      ArrayList<Float> scores = new ArrayList();
      ArrayList<Article> topBuddies = new ArrayList();

      PVector avg = new PVector();
      HashMap<Article, Integer> allBuddies = new HashMap();
      for (Map.Entry me : a.citerBuddies.entrySet ()) {
        ArrayList<Article>buddies = (ArrayList<Article>)me.getValue();
        for (Article buddy : buddies) allBuddies.put(buddy, 0);
      }
      for (Map.Entry me : a.referenceBuddies.entrySet ()) {
        ArrayList<Article>buddies = (ArrayList<Article>)me.getValue();
        for (Article buddy : buddies) allBuddies.put(buddy, 0);
      }
      for (Map.Entry me : allBuddies.entrySet ()) {
        Article aa = (Article)me.getKey();
        if (aa == a) continue;
        float score = 0;
        for (float termScore : aa.termScores) score = (score > termScore ? score : termScore);
        boolean foundSpot = false;
        for (int i = 0; i < scores.size (); i++) {
          if (score > scores.get(i)) {
            topBuddies.add(i, aa);
            scores.add(i, score);
            foundSpot = true;
            break;
          }
        }
        if (!foundSpot) {
          topBuddies.add(aa);
          scores.add(score);
        }

        // remove end ones
        for (int i = scores.size () - 1; i >= maxBuddies; i--) {
          scores.remove(i);
          topBuddies.remove(i);
        }
      }


      // finally average out the buddy positions
      for (Article aa : topBuddies) {
        newPos.x = aa.targetVec2.x;
        newPos.y = aa.targetVec2.y;
      }
      if (topBuddies.size() > 0) {
        newPos.x /= topBuddies.size();
        newPos.y /= topBuddies.size();
      }
    }

    return newPos;
  } //end getVecTargetPos

    //
  //public float getForceAdjustment







  //
  void update(PVector worldLocIn, ArrayList<Article> articlesIn, boolean ignorePositioningOfArticles) {
    for (Term t : terms) {
      t.update(worldLocIn);
      // set the connectionSelected to false
      t.resetConnectionSelected();
    }
    // then if a term is selected or moused over set its connections to connectionSelected
    for (Term t : terms) {
      if (t.mouseIsOver || t.selected) {
        for (Term con : t.connections) {
          con.setConnectionSelected();
        }
      }
    }

    // if any of the term's particles have a velocity > a certain number then update the article targets accordingly
    if (!ignorePositioningOfArticles) {
      float velocityLimit = .1;
      if (frameCount % 1 == 0) {
        for (Term t : terms) {
          if (abs(t.lastPos.x - t.pos.x) > velocityLimit || abs(t.lastPos.y - t.pos.y) > velocityLimit) {
            updateArticleTargets(articlesIn);
            break;
          }
        }
      }
    }
  } // end update

  //
  void debugDisplay(PGraphics pg) {
    for (Term t : terms) {
      t.debugDisplay(pg);
    }
  } // end display

  //
  void displayLines(PGraphics pg, float termBaseZIn) {
    for (Term t : terms) t.displayLines(pg, termBaseZIn);
  } // end displayLines
  //
  public void displayText(PGraphics pg, float termBaseZIn) {
    for (Term t : terms) t.displayText(pg, termBaseZIn);
  } // end displayText
  //
  public ArrayList<SVGText> getSVGTexts() {
    ArrayList<SVGText> svgTexts = new ArrayList();
    for (Term t : terms) svgTexts.add(t.svgText);
    return svgTexts;
  } // end getSVGTexts
  //
  void displayNetwork(PGraphics pg, float termBaseZIn) {
    // draw the network map 
    float minAlpha = 30f;
    float maxAlpha = 250f;
    float maxCountToUse = 300; // max articles to use for the alpha map.  any more than this will still result in maxAlpha
    for (int i = 0; i < terms.size (); i++) {
      Term t1 = terms.get(i);
      for (int j = i + 1; j < terms.size (); j++) {
        Term t2 = terms.get(j);
        if (t1.sharedArticles.containsKey(t2)) {
          int sharedCount = ((ArrayList<Article>)t1.sharedArticles.get(t2)).size();
          float thisAlpha = constrain(map(sharedCount, 0, maxCountToUse, minAlpha, maxAlpha), minAlpha, maxAlpha);
          pg.stroke(colorTermNetwork, thisAlpha);
          pg.line(t1.pos.x, t1.pos.y, termBaseZIn, t2.pos.x, t2.pos.y, termBaseZIn);
        }
      }
    }
  } // end displayNetwork

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
        println("articles: " + selectedTerm.articles.length);
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
      jj.setBoolean("hardLock", t.hardLock);
      jj.setFloat("gravity", t.gravity);

      // save connections and strength
      JSONArray conJar = new JSONArray();
      for (int i = 0; i < t.connections.size (); i++) {
        JSONObject con = new JSONObject();
        con.setString("id", t.connections.get(i).term);
        con.setFloat("strength", t.connectionStrengths.get(i));
        con.setFloat("length", t.connectionLengths.get(i));
        conJar.setJSONObject(conJar.size(), con);

        JSONArray shared = new JSONArray();
        ArrayList<Article> sharedArticles = (ArrayList<Article>)t.sharedArticles.get(t.connections.get(i));
        for (Article a : sharedArticles) {
          shared.setString(shared.size(), a.id);
        }

        con.setJSONArray("shared", shared);
      }
      jj.setJSONArray("connections", conJar);



      jar.setJSONObject(jar.size(), jj);
    }
    json.setJSONArray("terms", jar);

    saveJSONObject(json, fileName + ".json");
  } // end writeOutTermPositions

  //
  void readInTermPositions(String fileName, HashMap<String, Article> articlesHMIn) {
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
        boolean hardLock = jj.getBoolean("hardLock");
        Term t = (Term)termsHM.get(termName);
        t.setPosition(pos);
        if (hardLock) t.setHardLock();
        else t.releaseHardLock();
        float gravity = jj.getFloat("gravity");
        t.gravity = gravity;
        // erase connections
        t.connections.clear();
        t.connectionStrengths.clear();
        t.connectionLengths.clear();

        JSONArray connections = jj.getJSONArray("connections");
        for (int j = 0; j < connections.size (); j++) {
          JSONObject con = connections.getJSONObject(j);
          String conTerm = con.getString("id");
          float conStrength = con.getFloat("strength");
          float conLength = con.getFloat("length");
          Term otherTerm = (Term)termsHM.get(conTerm);


          ArrayList<Article> sharedArticles = new ArrayList();
          JSONArray sharedArticlesAr = con.getJSONArray("shared");
          for (int k = 0; k < sharedArticlesAr.size (); k++) {
            String articleId = sharedArticlesAr.getString(k);
            if (articlesHMIn.containsKey(articleId)) {
              sharedArticles.add((Article)articlesHMIn.get(articleId));
            }
          }

          t.addConnection(otherTerm, conStrength, conLength, sharedArticles);
        }
      }
    } 
    catch (Exception e) {
      println("error when reading in term positions for file: " + fileName);
    }

    println("done reading in");
    rebuildExistingTermNetwork(); // rebuild the network
  } // end readInTermPositions
} // end class TermManager











// some variables used for repulsion -- since used to makeTermNetwork and also rebuildTermNetwork
float repulseLengthMax = 900; // 460
float repulseLengthMin = 20; // 10
float repulseStrength = .001;


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
  // ****** CHANGE TOLERANCE HERE ****** //
  // ****** CHANGE TOLERANCE HERE ****** //
  // ****** CHANGE TOLERANCE HERE ****** //
  // ****** CHANGE TOLERANCE HERE ****** //
  float tolerance = .5; // .55 seems to work well.  HIGHER number will make for a more connected network
  // ****** CHANGE TOLERANCE HERE ****** //
  // ****** CHANGE TOLERANCE HERE ****** //
  // ****** CHANGE TOLERANCE HERE ****** //
  // ****** CHANGE TOLERANCE HERE ****** //


  physics.clear();
  for (Term t : termManager.terms) {
    t.connections.clear();
    t.connectionStrengths.clear();
  }
  //for (Object vs : allSprings) physics.removeSpring((VerletSpring2D)vs);
  //allSprings.clear();

  // clear any existing springs?
  // make random spots for all IFF they are all located at 0, 0
  for (int i = 0; i < termManager.terms.size (); i++) {
    Term t1 = termManager.terms.get(i);
    if (t1.particle.x == 0) t1.particle.x = random(width);
    if (t1.particle.y == 0) t1.particle.y = random(height);
  }

  // then assign the pulls towards one another based on the articles between them
  // do it by count?
  // do it by score?
  // by average score between the articles..?
  int maxNumberOfConnections = 0;
  float scoreDivider = 1f; // to weaken it a bit?
  float attractLength = 0f;
  float minAttractLength = 50f; // 20
  float maxAttractLength = 350f; // 220
  float attractStrength = 0f;
  float maxAttractStrength = .025;
  for (int i = 0; i < termManager.terms.size (); i++) {
    Term t1 = termManager.terms.get(i);
    for (int j = i + 1; j < termManager.terms.size (); j++) {
      Term t2 = termManager.terms.get(j);
      int similarArticleCount = 0;
      float totalArticleScore = 0f;
      int totalArticles = t1.articleIndex.size() + t2.articleIndex.size();
      ArrayList<Article> sharedArticles = new ArrayList();
      for (Map.Entry t1Me : t1.articleIndex.entrySet ()) {
        Article art = (Article)t1Me.getKey();
        float t1Score = t1.articleScores[(Integer)t1.articleIndex.get(art)];
        if (t2.articleIndex.containsKey(art)) {
          float t2Score = t2.articleScores[(Integer)t2.articleIndex.get(art)];
          totalArticleScore += t2Score + t1Score;
          similarArticleCount++;
          sharedArticles.add(art);
        }
      }
      if (similarArticleCount > 0) {
        // make a new strength
        float averageScore = totalArticleScore / similarArticleCount;
        attractStrength = constrain(map(log(averageScore), 0, log(2), 0, maxAttractStrength), 0, maxAttractStrength);
        float highestSharedPercent = max((float)similarArticleCount / t1.articleIndex.size(), (float)similarArticleCount / t2.articleIndex.size());
        attractLength = constrain(map(highestSharedPercent, 0, .5, maxAttractLength, minAttractLength), minAttractLength, maxAttractLength);

        // ******* //
        // ******* //
        // ******* //
        if (attractStrength < (1 - tolerance) * maxAttractStrength) continue;
        // ******* //
        // ******* //
        // ******* //

        println("similar: " + similarArticleCount + " attractStrength: " + attractStrength + " highestSharedPercent: " + highestSharedPercent);
        VerletParticle2D a = t1.particle;
        VerletParticle2D b = t2.particle;
        VerletSpring2D spring = new VerletSpring2D(a, b, attractLength, attractStrength);
        physics.addSpring(spring);
        //allSprings.add(spring);
        t1.addConnection(t2, attractStrength, attractLength, sharedArticles);
        t2.addConnection(t1, attractStrength, attractLength, sharedArticles);
        maxNumberOfConnections = (maxNumberOfConnections > t1.connections.size() ? maxNumberOfConnections : t1.connections.size());
      }
    }
  }

  // then assign all the repulsion springs
  // maybe based on the number of connections it has?
  for (int i = 0; i < termManager.terms.size (); i++) {
    Term t1 = termManager.terms.get(i);
    for (int j = i + 1; j < termManager.terms.size (); j++) {
      Term t2 = termManager.terms.get(j);
      VerletParticle2D a = t1.particle;
      VerletParticle2D b = t2.particle;
      float repulseLength = constrain(map(t1.connections.size(), 0, 5, repulseLengthMin, repulseLengthMax), repulseLengthMin, repulseLengthMax);
      VerletMinDistanceSpring2D spring = new VerletMinDistanceSpring2D(a, b, repulseLength, repulseStrength);
      physics.addSpring(spring);
      //allSprings.add(spring);
    }
  }

  // make a relative count of the connections used for fill
  for (Term t : termManager.terms) t.relativeConnectionPercentile = ((float)t.connections.size()) / maxNumberOfConnections;
} // end makeTermNetwork


//
// rebuild an existing term network assuming it's already been set
//
void rebuildExistingTermNetwork() {
  println("in rebuildExistingTermNetwork");
  physics.clear();
  int maxNumberOfConnections = 0;
  for (Term t1 : termManager.terms) {
    for (int i = 0; i < t1.connections.size (); i++) {
      Term t2 = t1.connections.get(i);
      println("looking at t1.term: " + t1.term + " and i: " + i);
      float attractStrength = t1.connectionStrengths.get(i);
      float attractLength = t1.connectionLengths.get(i);
      VerletParticle2D a = t1.particle;
      VerletParticle2D b = t2.particle;
      VerletSpring2D spring = new VerletSpring2D(a, b, attractLength, attractStrength);
      physics.addSpring(spring);
    }
    maxNumberOfConnections = (maxNumberOfConnections > t1.connections.size() ? maxNumberOfConnections : t1.connections.size());
  }

  // then assign all the repulsion springs
  for (int i = 0; i < termManager.terms.size (); i++) {
    Term t1 = termManager.terms.get(i);
    for (int j = i + 1; j < termManager.terms.size (); j++) {
      Term t2 = termManager.terms.get(j);
      VerletParticle2D a = t1.particle;
      VerletParticle2D b = t2.particle;
      float repulseLength = constrain(map(t1.connections.size(), 0, 15, repulseLengthMax, repulseLengthMin), repulseLengthMin, repulseLengthMax);
      VerletMinDistanceSpring2D spring = new VerletMinDistanceSpring2D(a, b, repulseLength, repulseStrength);
      physics.addSpring(spring);
    }
  }

  // make a relative count of the connections used for fill
  for (Term t : termManager.terms) t.relativeConnectionPercentile = ((float)t.connections.size()) / maxNumberOfConnections;
} // end rebuildExistingTermNetwork


//
//
//
//
//
//
//
//
//

