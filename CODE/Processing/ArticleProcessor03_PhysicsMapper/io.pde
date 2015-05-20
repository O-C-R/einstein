//
void importTerms(String dir) {
  // make the terms and termsHM from the given list
  String[] fileNames = OCRUtils.getFileNames(dir, false);
  for (String fileName : fileNames) {
    if (!fileName.contains(".txt")) continue;
    String[] rawWords = loadStrings(fileName);
    for (String word : rawWords) {
      Term t = new Term (termManager.terms.size(), word);
      termManager.addTerm(t);
    }
  }
} // end loadTerms



//
void importArticles(String dir, int[] targetYears) {
  println("in importArticles");
  // ****** MANUAL LIMIT MANUAL LIMIT ****** // 
  // ****** MANUAL LIMIT MANUAL LIMIT ****** // 
  // ****** MANUAL LIMIT MANUAL LIMIT ****** // 
  int manualImportLimit = 11; // set to < 0 to import all
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

