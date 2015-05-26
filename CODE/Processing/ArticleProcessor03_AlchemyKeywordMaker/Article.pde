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
  int[] termCounts = new int[0]; // the count of times this term occurs... sentences and title
  boolean[] termInTitle = new boolean[0]; // if the term is in the title
  HashMap<Term, Integer> termIndex = new HashMap(); // Term, index for above arrays where the term lives

  // wos characteristics  
  public String abstractString = "";
  public String[] abstractSentences = new String[0]; // the abstract String split into sentences
  public int publishedYear = 0; // year of publication

  public boolean isValid = true; // marked as false if the basic criteria isnt met

  // alchemy stuff
  public ArrayList<Alchemy> alchemies = new ArrayList();
  public HashMap<String, Alchemy> alchemiesHM = new HashMap();

  //
  Article(String id) {
    this.id = id;
  } // end constructor

  // 
  public void addTermCount(Term t, int occurance, boolean occursInTitle) {
    terms = (Term[])append(terms, t);
    termCounts = (int[])append(termCounts, occurance);
    termInTitle = (boolean[])append(termInTitle, occursInTitle);
    termIndex.put(t, termIndex.size());
  } // end addTermCount
  
  //
  public void addAlchemy(Alchemy a) {
    alchemies.add(a);
    alchemiesHM.put(a.word, a);
  } // end addAlchemy


  //
  String toString() {
    String builder = "";
    builder += "Article " + id + ": " + title;
    return builder;
  } // end toString


  //
  String toSimplifiedString() {
    String builder = "";
    builder += id + " - " + title;
    for (String s : abstractSentences) builder += " \n    " + s;
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

