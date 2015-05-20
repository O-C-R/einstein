//
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
  // after the 'assignTermsToArticles' function, this will go back and assign the article objects to the terms
  void assignArticlesToTerms(ArrayList<Article> articlesIn) {
    for (Article a : articles) {
      for (int i = 0; i < a.terms.length; i++) {
        Term t = a.terms[i];
        float count = a.termCounts[i];
        t.articles = (Article[])append(t.articles, a);
        t.articleCounts = (float[])append(t.articleCounts, count);
      }
    }
  } // end assignArticlesToTerms

    //
    // this will go through and make the counts then add the term objects and counts to the article objects
  void assignTermsToArticles(ArrayList<Article> articlesIn) {
    totalOccurancesOfAllTerms = 0;
    //String query = "black hole";
    for (Term term : terms) {
      int totalOccurances = 0;
      int articleCount = 0;
      for (int i = 0; i < articles.size (); i++) {
        int occurances = countOccurances(articles.get(i), term);
        totalOccurances += occurances;
        totalOccurancesOfAllTerms += occurances;
        if (occurances > 0) articleCount++;
      }
      //println("Term: "+ term.term);
      //println(" total occurance: " + totalOccurances);
      //println(" total article count: " + articleCount);

      totalTermOccurances.put(term, totalOccurances);
      totalTermArticles.put(term, articleCount);
    }
  } // end assignTermsToArticles



  // count how many times a term appears in an article
  // also assign to the article
  int countOccurances(Article a, Term term) {
    int occurances = 0;
    boolean occursInTitle = false;
    // check the title
    int count = StringUtils.countMatches(a.title.toLowerCase(), term.term.toLowerCase());
    occurances += count;  
    if (count > 0) occursInTitle = true;
    // then check the sentences
    for (String sentence : a.abstractSentences) {
      count = StringUtils.countMatches(sentence.toLowerCase(), term.term.toLowerCase());
      occurances += count;
    }
    // save to article if count > 0;
    if (occurances > 0) a.addTermCount(term, occurances, occursInTitle);

    return occurances;
  } // end countOccurances  


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
      int multiplierOccurance = a.termCounts[i];
      float multiplierForBeingInTitle = 1.5;
      Term t = a.terms[i];
      float termScore = t.gravity * (multiplierOccurance + (a.termInTitle[i] ? multiplierForBeingInTitle : 0f));
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
  // when pressed, find a if a term can be selected
  void dealWithMousePressed(PVector mouse) {
    //println("in dealWithMousePressed for termManager");
    // deselect all .. if any.. terms
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
//
//
//
//
//
//
//
//

