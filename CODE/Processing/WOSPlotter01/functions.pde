//
public void sortArticlesBySomething(ArrayList<Article> articlesIn, String paramName) {
  HashMap<String, HashMap<Article, Integer>> result = (HashMap<String, HashMap<Article, Integer>>)countOccurancesFromStringArray(articlesIn, paramName);
  ArrayList<TempSort> tsal = new ArrayList();
  for (Map.Entry me : result.entrySet ()) {
    HashMap<Article, Integer> hal = (HashMap<Article, Integer>)me.getValue();
    String option = (String)me.getKey();
    tsal.add(new TempSort(option, hal));
  }
  tsal = OCRUtils.sortObjectArrayListSimple(tsal, "articleCount");
  for (TempSort ts : tsal) println(ts.name + " -- " + ts.articleCount);
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
// go ahead and sort the things 
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

public float measureCosineSimilarity(Article a, Article b) {
  // only the overlap matters for dotProduct
  float dotProduct = 0f;
  float aMag = 0f;
  float bMag = 0f;
} // end measureCosineSimilarity


//
//
//
//
//
//
//
//
//

