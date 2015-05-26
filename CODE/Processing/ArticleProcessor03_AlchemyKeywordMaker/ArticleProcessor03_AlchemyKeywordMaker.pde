import ocrUtils.maths.*;
import ocrUtils.*;
import ocrUtils.ocr3D.*;
import java.util.Map;
import java.util.Arrays;
import rita.*;

// the arxivDirectory for the articles in 2014
String arxivDirectory2014 = "x_2014/";

// termDirectory
String termDirectory = "data/";

// alchemyDirectory
String alchemyDirectory = "alchemy/";

// ARTICLES
ArrayList<Article> articles = new ArrayList(); // what is to be queried
HashMap<String, Article> articlesHM = new HashMap();
int[] targetYears = {
}; // years to choose from

// TERMS
TermManager termManager = new TermManager();

// ALCHEMY WORDS
ArrayList<Alchemy> alchemyKeywords = new ArrayList();


//
void setup() {
  long startTime = millis();
  size(500, 500, P3D);
  OCRUtils.begin(this);
  randomSeed(1862);

  // load terms
  importTerms(sketchPath("") + termDirectory);

  // load up the simplified set within the pre-sorted years
  importArticles(sketchPath("") + arxivDirectory2014, new int[0]);

  termManager.assignTermsToArticles(articles);
  termManager.assignArticlesToTerms(articles); // go back and assign the articles to the terms so debug lines can be drawn

  // get the alchemy words
  importAlchemy(sketchPath("") + alchemyDirectory, articlesHM);



  HashMap<Term, ArrayList<AGroup>> termGroups = new HashMap();
  HashMap<Term, HashMap<String, AGroup>> termGroupsHM = new HashMap();

  // sort by each keyword
  for (Term t : termManager.terms) {
    ArrayList<Article> termArticles = findEinstein(t.term, false);
    println("total articles for term " + t.term + " is " + termArticles.size());
    ArrayList<AGroup> groups = new ArrayList();
    HashMap<String, AGroup> groupsHM = new HashMap();
    // find most common alchemy keywords per sort.  save in a group
    for (Article a : termArticles) {
      for (Alchemy aa : a.alchemies) {
        if (!groupsHM.containsKey(aa.word)) {
          AGroup newag = new AGroup(aa.word);
          groupsHM.put(aa.word, newag);
          groups.add(newag);
        }
        AGroup ag = (AGroup)groupsHM.get(aa.word);
        ag.addAlchemy(aa);
      }
    }

    // sort the groups descnding based on count
    groups = OCRUtils.sortObjectArrayListSimple(groups, "count");
    groups = OCRUtils.reverseArrayList(groups);
    for (AGroup ag : groups) ag.makeAverage();

    // save to overallgroup hm 
    termGroups.put(t, groups);
  }

  // figure which alchemy keywords are unique to only that category
  for (Map.Entry me : termGroups.entrySet ()) {
    ArrayList<AGroup> groups = (ArrayList<AGroup>)me.getValue();
    Term groupTerm = (Term)me.getKey();
uniqueLoop:
    for (AGroup ag : groups) {
      for (Map.Entry you : termGroupsHM.entrySet ()) {
        Term otherTerm = (Term)you.getKey();
        HashMap<String, AGroup> otherGroups = (HashMap<String, AGroup>) you.getValue();
        if (otherTerm == groupTerm)continue;
        if (otherGroups.containsKey(ag.word)) {
          ag.isUnique = false;
          break uniqueLoop;
        }
      }
    }
  }

  // print out a listing of that keyword along with count and average score and unique status
  for (Term t : termManager.terms) {
    PrintWriter output = createWriter("alchemyScores/" + t.term + ".txt");
    ArrayList<AGroup> groups = (ArrayList<AGroup>)termGroups.get(t);
    for (AGroup ag : groups) output.println(ag);
    output.flush();
    output.close();
  }





  println("total startup time: " + (((float)(millis() - startTime)) / 1000) + " seconds");

  exit();
} // end setup


//
class AGroup {
  String word = "";
  Alchemy[] as = new Alchemy[0];
  float highR = 0f; // highest relevance
  int count = 0;
  float avg = 0f; // the average relevance score
  boolean isUnique = true;
  AGroup(String word) {
    this.word = word;
  } // end constructor
  void addAlchemy(Alchemy a) {
    as = (Alchemy[])append(as, a);
    if (a.relevance > highR) highR = a.relevance;
    count++;
  } // end addAlchemy
  void makeAverage() {
    avg = 0f;
    for (Alchemy a : as) avg += a.relevance;
    avg/=as.length;
  } // end makeAverage
  String toString() {
    return "count: " + nf(count, 5) + TAB + "high: " + nf(highR, 0, 4) + TAB + " avg: " + nf(avg, 0, 4) + TAB + "   word: " + word;
  } // end toString
} // end class AGroup


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
//

