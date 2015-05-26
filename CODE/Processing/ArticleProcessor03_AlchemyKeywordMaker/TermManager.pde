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

