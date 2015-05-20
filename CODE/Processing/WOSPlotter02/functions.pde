//
// this will sort the list of Articles by the count of things in the paramName variable.
// eg sorting by "keywords" will generate a list of TempSort objects which will each have a name, eg the keyword, and a listing of articles that belong to this name
public ArrayList<TempSort> sortArticlesBySomething(ArrayList<Article> articlesIn, String paramName) {
  HashMap<String, HashMap<Article, Integer>> result = (HashMap<String, HashMap<Article, Integer>>)countOccurancesFromStringArray(articlesIn, paramName);
  ArrayList<TempSort> tsal = new ArrayList();
  for (Map.Entry me : result.entrySet ()) {
    HashMap<Article, Integer> hal = (HashMap<Article, Integer>)me.getValue();
    String option = (String)me.getKey();
    tsal.add(new TempSort(option, hal));
  }
  tsal = OCRUtils.sortObjectArrayListSimple(tsal, "articleCount");
  for (TempSort ts : tsal) println(ts.name + " -- " + ts.articleCount);
  return tsal;
} // end sortArticlesBySomething
public class TempSort {
  public String name = "";
  HashMap<Article, Integer> articles = new HashMap();
  public int articleCount = 0;
  TempSort(String name, HashMap<Article, Integer> articles) {
    this.name = name;
    this.articles = articles;
    articleCount = articles.size();
  } // end constructor
} // end class TempSort



//
// this will return a HashMap of <String, HashMap<Class, Int count>>
//  this is a measure of how many objects of Class t have one of the options within the String[] of the paramName
public <T> HashMap<String, HashMap<T, Integer>>  countOccurancesFromStringArray(ArrayList<T> objs, String paramName) {
  HashMap<String, HashMap<T, Integer>> count = new HashMap();
  for (Object a : objs) {
    try {
      T t = (T)a;
      Class cls = t.getClass();
      Field field = cls.getField(paramName);
      String[] options = (String[])field.get(t);
      //println(join(options, " -- " ));
      for (String option : options) {
        if (!count.containsKey(option)) {
          count.put(option, new HashMap<T, Integer>());
        }
        HashMap<T, Integer> forThisThing = (HashMap<T, Integer>)count.get(option);
        if (!forThisThing.containsKey(t)) forThisThing.put(t, 1);
        else {
          forThisThing.put(t, (Integer)forThisThing.get(t) + 1);
        }
      }
    }
    catch (Exception e) {
    }
  }
  return count;
} // end countOccurancesFromStringArray




//
// see http://www.ir-facility.org/scoring-and-ranking-techniques-tf-idf-term-weighting-and-cosine-similarity
// or this: https://janav.wordpress.com/2013/10/27/tf-idf-and-cosine-similarity/
// maybe this one: http://blog.christianperone.com/?p=1589
public void measureCosineSimilarity(ArrayList<Article> baseArticles, ArrayList<Article> comparisonArticles) {
  //println("in measureCosineSimilarity for " + baseArticles.size() + " against " + comparisionArticles.size() + " comparison articles");
} // end measureCosineSimilarity

//
// between two articles

/*
public float measureCosineSimilarity(Article a, Article b) {
 // only the overlap matters for dotProduct
 float dotProduct = 0f;
 float aMag = 0f;
 float bMag = 0f;
 } // end measureCosineSimilarity
 */


//
public void outputTempSorts(ArrayList<TempSort> tsal, String to) {
  PrintWriter output = createWriter(to);
  for (TempSort ts : tsal) output.println(ts.name + " -- count: " + ts.articleCount);
  output.flush();
  output.close();
} // end outputTempSorts



//
public String cleanSentence(String s) {
  // get rid of external links/footnotes [123]
  // see http://stackoverflow.com/questions/1138552/replace-string-in-parentheses-using-regex for regular expressions
  // and http://www.ocpsoft.org/opensource/guide-to-regular-expressions-in-java-part-1/
  s = s.replaceAll("\\[.+?\\]", "");
  // replace dashes with spaces
  s = s.replace("-", " "); // en
  s = s.replace("–", " "); // em
  // get rid of punctuation
  s = RiTa.stripPunctuation(s.toLowerCase());
  return s;
} // end cleanSentence




//
public void makeKeywordLinks(ArrayList<Article> articlesIn, ArrayList<Wikipedia> wikisIn) {
  println("in makeKeywordLinks");
  // assign keywordLinks to Wikipedias
  ArrayList<Article> temp = new ArrayList();
  for (int i = 0; i < 150; i++) temp.add(articles.get(i)); // ****** MANUAL LIMIT ****** //
  for (int i = 0; i < wikisIn.size (); i++) {
    //wikis.get(i).makeKeywordLinks(temp); // use limited version
    wikis.get(i).makeKeywordLinks(articlesIn); // use all
    println("made keywordLinks for wiki: " + wikis.get(i).topic + " -- " + (i + 1) + "/" + (wikisIn.size()));
  }
} // end makeKeywordLinks







//
//
//
//
//
//
//
//
//

