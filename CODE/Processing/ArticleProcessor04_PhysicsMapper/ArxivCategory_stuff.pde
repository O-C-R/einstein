//
class ArxivCategory {
  String term = ""; // the id/term of the category, eg gr-qc
  String name = ""; // the long name, eg. General Relativity, Quantum Cosmology
  HashMap<String, Article> primaryArticles = new HashMap(); // a hashmap of all articles that have this category as their primary 
  HashMap<String, Article> secondaryArticles = new HashMap(); // a hashmap of all articles that have this not as their primary category
  HashMap<String, Article> noSecondaryArticles = new HashMap(); // a hashmap of all articles that don't get sorted into secondaryArticles
  boolean isUsed = false; // triggered to true when an article is assigned to it

  //
  ArxivCategory (String term) {
    this.term = term;
  } // end constructor

  //
  String toString() {
    String builder = "";
    builder += "ArxivCategory: " + term + (name.length() > 0 ? " -- name: " + name : "") + "\n  primaryCount: " + primaryArticles.size() + " -- secondaryCount: " + secondaryArticles.size() + " -- noSecondaryCount: " + noSecondaryArticles.size();
    return builder;
  } // end toString




  //display Article objects colored by their secondary categories (all have the primary category of gr-qc)
  void displaySecondaryArxivCategories(PGraphics pg, boolean useArticleZIn, color catColor) {
    for (Map.Entry me : secondaryArticles.entrySet ()) {
      Article a = (Article)me.getValue();
      a.displayCategoryView(pg, useArticleZIn, false, catColor);
      //println(term + " article: " + a.title);
    }
  }
  
  void displayPrimaryArxivCategories(PGraphics pg, boolean useArticleZIn, color catColor) {
    for (Map.Entry prime : primaryArticles.entrySet ()) {
      Article b = (Article)prime.getValue();
      b.displayCategoryView(pg, useArticleZIn, true, catColor);
    }
  }
  
} // end class ArxivCategory






// 
// assuming the Article objects have the category strings in place, make the arxiv categories from that
public void makeArxivCategories(HashMap<String, Article> articlesHMIn) {
  println("in makeArxivCategories");
  arxivCategoriesHM.clear();
  for (Map.Entry me : articlesHMIn.entrySet ()) {
    Article a = (Article)me.getValue();
    String primary = a.arxivCategoryPrimaryString;
    String[] secondary = a.arxiveCategorySecondaryStrings;
    if (primary.length() > 0) {
      if (!arxivCategoriesHM.containsKey(primary)) {
        arxivCategoriesHM.put(primary, new ArxivCategory(primary));
      }
    }
    for (String s : secondary) {
      if (s.length() > 0) {
        if (!arxivCategoriesHM.containsKey(s)) {
          arxivCategoriesHM.put(s, new ArxivCategory(s));
        }
      }
    }
  }
  //for (Map.Entry me : arxivCategoriesHM.entrySet ()) println((ArxivCategory)me.getValue());
  println(" done with makeArxivCategories.  made total of: " + arxivCategoriesHM.size() + " categories");
} // end makeArxivCategories


//
// then deal out the categories
// use a list to pick out only the categories we want and ignore all others
public void dealOutArxivCategories(HashMap<String, Article> articlesHMIn, HashMap<String, ArxivCategory> arxivCategoriesHMIn, String[][] validArxivCategoriesIn) {
  String validNames = "";
  HashMap<String, ArxivCategory> filteredArxivCategoriesHM = new HashMap(); 

  for (String[] ss : validArxivCategoriesIn) {
    validNames += ss[1] + ", ";
    try { 
      ArxivCategory ac = (ArxivCategory)arxivCategoriesHMIn.get(ss[0]);
      ac.name = ss[1];
      filteredArxivCategoriesHM.put(ss[0], ac);
    } 
    catch (Exception e) {
      System.err.println("ERROR, COULD NOT FIND ARXIV CATEGORY: " + ss[0]);
    }
  }
  println(" in dealOutArxivCategories for categories [" + validArxivCategoriesIn.length + "]: \n  " + validNames + " and hm size: " + arxivCategoriesHMIn.size() + " \n  .. double check of filter size: " + filteredArxivCategoriesHM.size());
  // actually deal out these things to the Articles
  for (Map.Entry me : articlesHMIn.entrySet ()) {
    Article a = (Article)me.getValue();
    // first the primary category
    String arxivCategoryPrimaryString = a.arxivCategoryPrimaryString;
    if (arxivCategoryPrimaryString.length() > 0) {
      try {
        ArxivCategory ac = (ArxivCategory)filteredArxivCategoriesHM.get(arxivCategoryPrimaryString);
        a.arxivCategoryPrimary = ac;
        ac.primaryArticles.put(a.id, a);
        ac.isUsed = true;
      } 
      catch (Exception e) {
        System.err.println("problem finding primary ArxivCategory category string in filteredArxivCategoriesHM: " + a.arxivCategoryPrimaryString);
      }
    } else {
      System.err.println("problem with article: " + a.id + " and arxivCategoryPrimaryString: " + a.arxivCategoryPrimaryString + " in filteredArxivCategoriesHM");
    }
    // then the secondary
    for (String acSecondaryString : a.arxiveCategorySecondaryStrings) {
      if (acSecondaryString.length() > 0) {
        try {
          if (filteredArxivCategoriesHM.containsKey(acSecondaryString.trim())) {
            ArxivCategory ac = (ArxivCategory)arxivCategoriesHMIn.get(acSecondaryString.trim());
            a.arxivCategoriesSecondary.put(ac.term, ac);
            ac.secondaryArticles.put(a.id, a);
            ac.isUsed = true;
          } else {
            //ArxivCategory ac2 = (ArxivCategory)arxivCategoriesHMIn.get(acSecondaryString.trim());
            //ac2.noSecondaryArticles.put(a.id, a);
            //continue;
          }
        } 
        catch (Exception e) {
          System.err.println("problem finding primary ArxivCategory category string: " + a.arxivCategoryPrimaryString);
        }
      } else {
        System.err.println("problem with article: " + a.id + " and arxivCategoryPrimaryString: " + a.arxivCategoryPrimaryString);
      }
    }
  }
  // print out all of the categories
  for (Map.Entry me : arxivCategoriesHMIn.entrySet ()) {
    ArxivCategory ac = (ArxivCategory)me.getValue();
    if (ac.isUsed)println(ac);
  }
} // end dealOutArxivCategories

//
//
//
//
//

