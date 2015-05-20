import rita.*;
import java.lang.reflect.Field;
import java.util.Map;



String dataDirectory = "/Users/noa/Desktop/OCR-local/Einstein/DATA/Reboot/Top10PhysicsJournalsof2014/";
String articleRawNGramDirectory = dataDirectory + "rawNGrams/"; // files may contain several articles' worth if info
String articleScoreNGramDirectory = dataDirectory + "scoreNGrams/"; //

String wikiDirectory = "/Users/noa/Desktop/OCR-local/Einstein/DATA/WikipediaScrapesTimeline/"; // where the wikipedia scrapes live 

// should this be used?
// will filter out articles that do not contain any of these terms
// seems to go a bit overboard
String[] keyTerms = {
  //"general relativity", // all papers must have at least one of these terms to be counted as valid
};

// if specific files to load, add them here
// note to include extension
// if empty will load all files in directoryx
String[] targetFiles = {
  "2014_AdvancedEnergyMaterials_WoS.txt", 
  "2014_AdvancedMaterials_WoS_1.txt", 
  "2014_AdvancedMaterials_WoS_2.txt", 
  "2014_AdvancedMaterials_WoS_3.txt", 
  "2014_AdvancesInPhysics_WoS.txt", 
  "2014_LivingReviewsInRelativity_WoS.txt", 
  "2014_NatureMaterials_WoS.txt", 
  "2014_NaturePhotonics_WoS.txt", 
  "2014_NaturePhysics_WoS.txt", 
  "2014_ReportsOnProgressInPhysics_WoS.txt", 
  "2014_ReviewsOfModernPhysics_WoS.txt", 
  "2014_SurfaceScienceReports_WoS.txt"
};

ArrayList<Article> articles = new ArrayList(); // in arrayList form
HashMap<String, Article> articlesHM = new HashMap(); // id, Article   -    keep it in hm form too

// wikipedia objects
ArrayList<Wikipedia> wikis = new ArrayList();
HashMap<String, Wikipedia> wikisHM = new HashMap(); // String topic, Wikipedia

// ngram stuff.  
int ngramMax = 2; // from 1 to this number will be made

// 
void setup() {
  loadAllArticles(dataDirectory, targetFiles, keyTerms);

  loadWikipediaArticles(wikiDirectory);

  // assign keywordLinks to Wikipedias
  makeKeywordLinks(articles, wikis);
  // draw it
  //viewKeywords(articles, wikis);
  //viewKeywords2(articles, wikis);
  viewKeywords3(articles, wikis);


  // temp get rid of all but a few of the Articles for ngram testing purposes
  /*
  int toSave = 3;
   ArrayList<Article> saved = new ArrayList();
   for (int i = 0; i < min (toSave, articles.size ()); i++) saved.add(articles.get(i));
   articlesHM.clear();
   for (Article a : saved) articlesHM.put(a.id, a);
   */



  /*
// LOADING/MAKING THE NGRAMS
   loadRawNGrams(articlesHM, articleRawNGramDirectory, ngramMax); // load all raw ngrams for this article.  if the file doesnt exist then make a new one
   //a.loadReducedNGrams(articles, articleRawNGramDirectory); // load all reduced ngrams for this article - where they are reduced based on the idf.  if the file doesnt exist then make a new one
   // 
   // loading/making the ngram scores
   loadNGramScores(articlesHM, articleScoreNGramDirectory);
   */

  //for (Article a : saved) println("____________\n____________\n" + a.toSimplifiedString());  


  // sort the articles by something
  /*
  ArrayList<TempSort> tsal = sortArticlesBySomething(articles, "keywords");
   outputTempSorts(OCRUtils.reverseArrayList(tsal), sketchPath("") + "sorts/keywords.txt");
   tsal = sortArticlesBySomething(articles, "subjectArea");
   outputTempSorts(OCRUtils.reverseArrayList(tsal), sketchPath("") + "sorts/subject.txt");
   */


  IntDict byYear = OCRUtils.countOccurrences(articles, "publishedYear");
  //println(byYear);

  //for (Article a : articles) println(a.title + " -- " + a.publishedYear + "\n" + a.abstractString + "\n\n");

  // also temp output the top keywords
  /*
  HashMap<String, Integer> keyWordsHash = new HashMap();
   for (Article a : articles) {
   a.ngrams = OCRUtils.sortObjectArrayListSimple(a.ngrams, "score");
   a.ngrams = OCRUtils.reverseArrayList(a.ngrams);
   for (String s : a.keywords) {
   if (!keyWordsHash.containsKey(s)) keyWordsHash.put(s, 0);
   keyWordsHash.put(s, ((Integer)keyWordsHash.get(s)) + 1);
   }
   println("ARTICLE: " + a.title);
   for (NGram ngram : a.ngrams) {
   if (ngram.score > .04) println(ngram);
   }
   //break;
   }
   */



  /*
  // temp output the top keywords
   ArrayList<NGram> temp = new ArrayList();
   for (Map.Entry me : keyWordsHash.entrySet ()) {
   temp.add(new NGram((String)me.getKey(), (Integer)me.getValue()));
   }
   
   temp = OCRUtils.sortObjectArrayListSimple(temp, "count");
   temp = OCRUtils.reverseArrayList(temp);
   PrintWriter output = createWriter("keywordsList/keywords.txt");
   for (NGram ng : temp) output.println(ng.term + " -- " + ng.count);
   output.flush();
   output.close();
   */


  println("total articles: " + articles.size());

  exit();
} // end setup

//
void draw() {
} // end draw

//
//
//
//
//
//
//

