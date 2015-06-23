//
void importTerms(String dir) {
  // make the terms and termsHM from the given list
  String[] fileNames = OCRUtils.getFileNames(dir, false);
  for (String fileName : fileNames) {
    if (!fileName.contains(".txt")) continue;
    String[] rawWords = loadStrings(fileName);
    for (String word : rawWords) {
      if (word.trim().length() <= 0) continue;
      String thisTermString = split(word, ":")[1];
      thisTermString = thisTermString.replace("Score", "").trim().toLowerCase();
      Term t = new Term (termManager.terms.size(), thisTermString);
      termManager.addTerm(t);
    }
  }
} // end importTerms



//
void importArticles(String dir, int[] targetYears) {
  println("in importArticles");
  // ****** MANUAL LIMIT MANUAL LIMIT ****** // 
  // ****** MANUAL LIMIT MANUAL LIMIT ****** // 
  // ****** MANUAL LIMIT MANUAL LIMIT ****** // 
  int manualImportLimit = -1611; // set to < 0 to import all
  // ****** MANUAL LIMIT MANUAL LIMIT ****** // 
  // ****** MANUAL LIMIT MANUAL LIMIT ****** // 
  // ****** MANUAL LIMIT MANUAL LIMIT ****** // 

  ArrayList<Article> newArticles = new ArrayList(); // in arrayList form
  HashMap<String, Article> newArticlesHM = new HashMap(); // keep it in hm form too
  long startTime = millis();

  String[] files = OCRUtils.getFileNames(dir, false);
outerLoop:
  for (String fileName : files) {

    if (!fileName.contains(".xml")) continue;
    println("loading file: " +  getFileName(fileName));
    String[] rawStrings = loadStrings(fileName);
    String stringXML = join(rawStrings, " ");
    stringXML.replace("\n", " ");


    //XML xml = loadXML(fileName);
    XML xml = parseXML(stringXML);

    XML[] entries = xml.getChildren("entry");
    for (int i = 0; i < entries.length; i++) {
      try {
        Article newArticle = makeArticleFromXML(entries[i]);

        boolean validYear = false;
        if (targetYears.length == 0) validYear = true;
        else {
          for (int y : targetYears) if (y == newArticle.publishedYear) validYear = true;
        }


        if (validYear) {
          if (!newArticlesHM.containsKey(newArticle.id)) {
            newArticlesHM.put(newArticle.id, newArticle);
            newArticles.add(newArticle);
          }
        }

        //println(publishedString);

        if (manualImportLimit > 0 && newArticles.size() >= manualImportLimit) break outerLoop;
      }
      catch (Exception ee) {
        print("q");
      }
    }
  }

  println("done loading: " + newArticles.size() + " new articles in " + (((float)millis() - startTime) / 1000) + " seconds");
  articles = newArticles;
  articlesHM = newArticlesHM;
} //end importARticles









//
// the thing that turns an xml into an article
public Article makeArticleFromXML(XML a) {
  XML idXML = a.getChild("id");
  String id = idXML.getContent();
  XML abstractXML = a.getChild("summary");
  String abstractString = abstractXML.getContent();
  XML titleXML = a.getChild("title");
  String title = titleXML.getContent();

  boolean published = false;
  try {
    XML publishedComment = a.getChild("arxiv:journal_ref");
    if (publishedComment != null) published = true;
  } 
  catch (Exception e) {
  }



  // arxiv category stuff
  String arxivCategoryPrimaryString = "";
  try {
    XML arxivCategoryPrimaryXML = a.getChild("arxiv:primary_category");
    if (arxivCategoryPrimaryXML != null) arxivCategoryPrimaryString = arxivCategoryPrimaryXML.getString("term");
  } 
  catch(Exception e) {
  }
  //println("arxivCategoryPrimaryString: " + arxivCategoryPrimaryString);


  XML[] categories = a.getChildren("category");
  String[] cats = new String[0];
  for (XML cat : categories) {
    String catName = cat.getString("term");
    if (!catName.equals(arxivCategoryPrimaryString)) cats = (String[])append(cats, catName);
  }
  //println(cats);

  Article newArticle = new Article(id);

  newArticle.title = title.replace("\n", " ");
  newArticle.title = newArticle.title.replace("\r", " ");
  newArticle.title = newArticle.title.replace("   ", " ");
  newArticle.title = newArticle.title.replace("  ", " ");
  newArticle.abstractString = abstractString.replace("\n", " ");
  newArticle.abstractString = newArticle.abstractString.replace("\r", " ");

  newArticle.published = published;

  // split into sentences
  newArticle.abstractSentences = RiTa.splitSentences(newArticle.abstractString);

  newArticle.subjectArea = cats;

  // save the raw xml
  newArticle.xml = a;

  // save the arxiv category stuff
  newArticle.arxivCategoryPrimaryString = arxivCategoryPrimaryString;
  newArticle.arxiveCategorySecondaryStrings = cats;

  // check the year
  XML publishedStringXML = a.getChild("published");
  String publishedString = publishedStringXML.getContent();
  //println(publishedString);
  Calendar cal = makeCalFromTime(publishedString);
  newArticle.cal = cal;
  int yearCheck = cal.get(Calendar.YEAR);
  newArticle.publishedYear = yearCheck;

  return newArticle;
} // end makeArticleFromXML



//
public void loadValidArxivCategories(String dir) {
  println("in loadValidArxivCategories");
  validArxivCategories = new String[0][2];
  String[] fileNames = OCRUtils.getFileNames(dir, false);
  for (String fileName : fileNames) {
    if (!fileName.contains(".txt")) continue;
    String[] validCategories = loadStrings(fileName);
    for (String line : validCategories) {
      String[] broken = splitTokens(line, "*");
      String cat = broken[0].trim();
      String name = broken[1].trim();
      String[] ln = {
        cat, name
      };
      validArxivCategories = (String[][])append(validArxivCategories, ln);
    }
  }
  println(" end of loadValidArxivCategories.  loaded " + validArxivCategories.length + " category strings");
} // end loadValidArxivCategories



//
// this will both assign the concepts/terms to the articles, but also the articles to the terms
public void dealOutTerms(String dir, HashMap<String, Article> articlesHMIn, HashMap<String, Term> termsHMIn) {
  int totalArticlesWithAtLeastOneTerm = 0;
  IntDict termCounts = new IntDict();
  //println("in dealOutTerms for directory " + dir);
  String[] fileNames = OCRUtils.getFileNames(dir, false);
  for (String fileName : fileNames) {
    if (!fileName.contains(".txt")) continue;
    println(" in dealOutTerms.  reading in file: " + fileName);
    JSONArray jar = loadJSONArray(fileName);
    for (int i = 0; i < jar.size (); i++) {
      JSONObject jj = jar.getJSONObject(i);
      String articleId = jj.getString("id");
      JSONArray jjarr = jj.getJSONArray("response");
      try {
        Article article = (Article)articlesHMIn.get(articleId);
        //println(article.title + " __ " + article.id);
        boolean didCount = false;
        for (int j = 0; j < jjarr.size (); j++) {
          JSONObject mini = jjarr.getJSONObject(j);
          String termName = mini.getString("text").toLowerCase().trim();
          float termScore = mini.getFloat("relevance");
          Term thisTerm = null;
          if (termsHMIn.containsKey(termName)) {
            if (didCount == false) {
              totalArticlesWithAtLeastOneTerm++;
              didCount = true;
            }
            thisTerm = (Term)termsHMIn.get(termName);
            //println("             xxxxxxxxxx: " + thisTerm.term + " -- " + termScore);
            if (!termCounts.hasKey(termName)) termCounts.set(termName, 0);
            termCounts.increment(termName);

            // assign the term to the article
            article.addTerm(thisTerm, termScore);
            // and then the article to the term
            thisTerm.addArticle(article, termScore);
          }
        }
      } 
      catch (Exception e) {
        //println("serious problem.  could not find articleId of: " + articleId);
        print("º");
      }
    }
  }
  println("_done");
  termCounts.sortValuesReverse();
  for (String key : termCounts.keys ()) {
    println(key + " -- " + termCounts.get(key));
  }
  println("total terms used: " + termCounts.size());

  println("any terms that aren't used?:");
  for (Map.Entry me : termsHMIn.entrySet ()) {
    Term t = (Term)me.getValue();
    if (!termCounts.hasKey(t.term)) {
      println(" ______" + t.term);
    }
  }

  println("end of dealOutTerms.  totalArticlesWithAtLeastOneTerm: " + totalArticlesWithAtLeastOneTerm + " print of: " + articlesHMIn.size());
} // end dealOutTerms





// do the author stuff
public void dealOutAuthors(String dir, HashMap<String, Article> articlesHMIn) {
  println("in dealOutAuthors");
  int tempCount = 0;
  String[] fileNames = OCRUtils.getFileNames(dir, false);
  for (String fileName : fileNames) {
    if (!fileName.contains(".json")) continue;
    println(" dealOutAuthors for file: " + fileName);
    try {
      JSONObject json = loadJSONObject(fileName);
      for (Object key : json.keys ()) {
        String articleId = (String)key;
        if (articlesHMIn.containsKey(articleId)) {
          Article thisArticle = (Article)articlesHMIn.get(articleId);
          tempCount++;
          //println("article: " + (String)key);
          HashMap<String, Integer> authorCounts = new HashMap();
          int authorCountsSum = 0;
          JSONArray jar = json.getJSONArray((String)key);
          for (int i = 0; i < jar.size (); i++) {
            JSONObject jj = jar.getJSONObject(i);
            for (Object jjKey : jj.keys ()) {
              String name = (String)jjKey;
              int count = 1;
              try {
                count = jj.getInt(name);
              } 
              catch (Exception e) {
                print("•");
              }
              //println("name: " + name + " count: " + count);
              authorCountsSum += count;
              authorCounts.put(name, count);
            }
          }
          // assign the authorCounts
          thisArticle.authorCounts = authorCounts;
          thisArticle.authorCountsSum = authorCountsSum;
        }
      }
    }
    catch (Exception e) {
      println("problem dealing out authors for file: " + fileName);
    }
  }
  println("done with dealOutAuthors.  total articles dealt with: " + tempCount + " out of possible: " + articlesHMIn.size());
} // end dealOutAuthors



// do the cites
public void dealOutCites(String dir, HashMap<String, Article> articlesHMIn) {
  println("in dealOutCites");
  int tempCount = 0;
  String[] fileNames = OCRUtils.getFileNames(dir, false);
  HashMap<String, ArrayList<Article>> theCited = new HashMap();
  for (String fileName : fileNames) {
    if (!fileName.contains(".json")) continue;
    println(" dealOutCites for file: " + fileName);
    try {
      JSONObject json = loadJSONObject(fileName);
      for (Object key : json.keys ()) {
        String articleId = (String)key;
        if (articlesHMIn.containsKey(articleId)) {
          Article thisArticle = (Article)articlesHMIn.get(articleId);
          HashMap<String, Integer> citerIds = new HashMap();
          JSONArray jar = json.getJSONArray(articleId);
          for (int i = 0; i < jar.size (); i++) {
            String citerId = jar.getString(i); 
            //println(citerId);
            citerIds.put(citerId, 0);
            if (!theCited.containsKey(citerId)) theCited.put(citerId, new ArrayList<Article>());
            ArrayList<Article> listOfTheCited = (ArrayList<Article>)theCited.get(citerId);
            listOfTheCited.add(thisArticle);
            //if (citerId.equals("arXiv:1412.4674")) println("_______ found arXiv:1412.4674 for article: " + thisArticle.id + " .. size: " + listOfTheCited.size());
          }
          thisArticle.citerIds = citerIds;
        }
      }
    }
    catch (Exception e) {
    }
  }

  // now go back through and find all of the other article that have the same citer
  for (Map.Entry me : articlesHMIn.entrySet ()) {
    Article article = (Article)me.getValue();
    HashMap<String, ArrayList<Article>> citerBuddies = new HashMap();
    for (Map.Entry you : article.citerIds.entrySet ()) {
      String citerId = (String)you.getKey();
      ArrayList<Article> tempBuddies = (ArrayList<Article>)theCited.get(citerId).clone();
      tempBuddies.remove(article);
      citerBuddies.put(citerId, tempBuddies);
    }
    article.citerBuddies = citerBuddies;
  }
} // end dealOutCites



// do the REFERENCES
public void dealOutReferences(String dir, HashMap<String, Article> articlesHMIn) {
  println("in dealOutReferences");
  int tempCount = 0;
  String[] fileNames = OCRUtils.getFileNames(dir, false);
  HashMap<String, ArrayList<Article>> theReferenced = new HashMap();
  for (String fileName : fileNames) {
    if (!fileName.contains(".json")) continue;
    println(" dealOutReferences for file: " + fileName);
    try {
      JSONObject json = loadJSONObject(fileName);
      for (Object key : json.keys ()) {
        String articleId = (String)key;
        if (articlesHMIn.containsKey(articleId)) {
          Article thisArticle = (Article)articlesHMIn.get(articleId);
          HashMap<String, Integer> referenceIds = new HashMap();
          JSONArray jar = json.getJSONArray(articleId);
          for (int i = 0; i < jar.size (); i++) {
            String referenceId = jar.getString(i); 
            //println(citerId);
            referenceIds.put(referenceId, 0);
            if (!theReferenced.containsKey(referenceId)) theReferenced.put(referenceId, new ArrayList<Article>());
            ArrayList<Article> listOfTheReferenced = (ArrayList<Article>)theReferenced.get(referenceId);
            listOfTheReferenced.add(thisArticle);
          }
          thisArticle.referenceIds = referenceIds;
        }
      }
    }
    catch (Exception e) {
    }
  }

  // now go back through and find all of the other article that have the same citer
  for (Map.Entry me : articlesHMIn.entrySet ()) {
    Article article = (Article)me.getValue();
    HashMap<String, ArrayList<Article>> referenceBuddies = new HashMap();
    for (Map.Entry you : article.referenceIds.entrySet ()) {
      String referenceId = (String)you.getKey();
      ArrayList<Article> tempBuddies = (ArrayList<Article>)theReferenced.get(referenceId).clone();
      tempBuddies.remove(article);
      referenceBuddies.put(referenceId, tempBuddies);
    }
    article.referenceBuddies = referenceBuddies;
  }
} // end dealOutReferences






//
String getFileName(String s) {
  String[] broken = splitTokens(s, "/\\");
  return broken[broken.length - 1];
} // end getFileName







//
public void inputTermLocations(File selection) {
  println("in inputDirectionLocations");
  try {
    termManager.readInTermPositions(selection.getAbsolutePath(), articlesHM);
  } 
  catch (Exception e) {
    println("problem loading up file: " + selection.getAbsolutePath());
  }
} // end inputTermLocations 


//
// save the raw direction locations
public void outputTermLocations(File selection) {
  println("in outputTermLocations");
  println("selection.abs path: " + selection.getAbsolutePath());
  termManager.saveTermPositions(selection.getAbsolutePath());
} // end outputTermLocations




//
// save the default Article positions
public void saveDefaultArticlePositions(String dirName) {
  saveArticlePositions(dirName + "defaultArticlePositions");
} // end saveDefaultArticlePositions 

// save the raw direction locations
public void outputArticlePositions(File selection) {
  println("in outputArticlePositions");
  println("selection.abs path: " + selection.getAbsolutePath());
  saveArticlePositions(selection.getAbsolutePath());
} // end outputArticlePositions

// 
// save the Article positions
public void saveArticlePositions(String fileName) {
  println("in saveArticlePositions");
  try {
    JSONObject json = new JSONObject();
    JSONArray jar = new JSONArray();
    for (Article a : articles) {
      JSONObject jj = new JSONObject();
      jj.setString("id", a.id);
      PVector bodyPos = a.getBox2dPosition();
      jj.setFloat("x", bodyPos.x);
      jj.setFloat("y", bodyPos.y);
      jj.setFloat("z", a.z);
      jar.setJSONObject(jar.size(), jj);
    }
    json.setJSONArray("articles", jar);
    saveJSONObject(json, fileName + ".json");
    println("wrote out article position file");
  } 
  catch (Exception e) {
    println("problem saving out article positions");
  }
} // end saveArticlePositions



//
// save the default Article positions
public void loadDefaultArticlePositions(String dirName) {
  loadArticlePositions(dirName + "defaultArticlePositions.json");
} // end loadDefaultArticlePositions
//
// save the raw direction locations
public void inputArticlePositions(File selection) {
  println("in inputArticlePositions");
  println("selection.abs path: " + selection.getAbsolutePath());
  loadArticlePositions(selection.getAbsolutePath());
} // end outputArticlePositions
// load up the Article positions
public void loadArticlePositions(String fileName) {
  println("in loadArticlePositions to fileName: " + fileName);
  try {
    JSONObject json = loadJSONObject(fileName);
    JSONArray jar = json.getJSONArray("articles");
    for (int i = 0; i < jar.size (); i++) {
      JSONObject jj = jar.getJSONObject(i);
      String id = jj.getString("id");
      float x = jj.getFloat("x");
      float y = jj.getFloat("y");
      float z = jj.getFloat("z");
      if (articlesHM.containsKey(id)) {
        Vec2 newPos = new Vec2(x, y);
        Article a = (Article)articlesHM.get(id);
        a.setExactPosition(newPos);
      }
    }
  } 
  catch (Exception e) {
    println("problem loading in article positions from file: " + fileName);
  }
} // end loadArticlePositions


//
//
//
//
//
//
//
//
//
//
//
//
//
//

