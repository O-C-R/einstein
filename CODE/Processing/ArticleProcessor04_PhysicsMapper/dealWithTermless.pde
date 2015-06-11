//
public void dealWithTermless(HashMap<String, Article> articlesHM, ArrayList<Term> terms) {
  int countOfThoseWithoutTerms = 0;
  int countOfThoseWithFoundTerms = 0;
  for (Map.Entry me : articlesHM.entrySet ()) {
    Article a = (Article)me.getValue();
    boolean foundOne = false;
    if (a.isTermless) {
      countOfThoseWithoutTerms++;
      for (Term t : terms) {
        int count = countOccurances(a, t);
        if (count > 0) {
          println("looking at article: " + a.title + " total count of term: " + t.term + " is: " + count);
          foundOne = true;
          a.addHasConceptInText(t, count);
        }
      }
    }
    if (foundOne) {
      countOfThoseWithFoundTerms++;
      println("xxxxxxxxx and the title/abstract: "  + a.title + "\n   " + a.abstractString);
    }
  }
  println("end of dealWithTermless.  total without terms: " + countOfThoseWithoutTerms + " and found terms for " + countOfThoseWithFoundTerms);
} // end dealWithTermless

//
// for those that don't have a term/concept listed directly, search for it in text
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
  return occurances;
} // end countOccurances  


//
//
//
//
//
//
//

