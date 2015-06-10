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
  int manualImportLimit = -111; // set to < 0 to import all
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


  XML[] categories = a.getChildren("category");
  String[] cats = new String[0];
  for (XML cat : categories) {
    String catName = cat.getString("term");
    cats = (String[])append(cats, catName);
  }

  Article newArticle = new Article(id);

  newArticle.title = title.replace("\n", " ");
  newArticle.title = newArticle.title.replace("\r", " ");
  newArticle.title = newArticle.title.replace("   ", " ");
  newArticle.title = newArticle.title.replace("  ", " ");
  newArticle.abstractString = abstractString.replace("\n", " ");
  newArticle.abstractString = newArticle.abstractString.replace("\r", " ");

  // split into sentences
  newArticle.abstractSentences = RiTa.splitSentences(newArticle.abstractString);

  newArticle.subjectArea = cats;

  // save the raw xml
  newArticle.xml = a;

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
        println("serious problem.  could not find articleId of: " + articleId);
      }
    }
  }
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










//
String getFileName(String s) {
  String[] broken = splitTokens(s, "/\\");
  return broken[broken.length - 1];
} // end getFileName







//
public void inputTermLocations(File selection) {
  println("in inputDirectionLocations");
  try {
    termManager.readInTermPositions(selection.getAbsolutePath());
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

