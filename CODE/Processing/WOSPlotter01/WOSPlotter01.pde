import java.lang.reflect.Field;
import java.util.Map;


String dataDirectory = "/Applications/MAMP/htdocs/OCR/einstein/DATA/WebOfScience/";
String articleRawNGramDirectory = dataDirectory + "rawNGrams/"; // files may contain several articles' worth if info
String articleScoreNGramDirectory = dataDirectory + "scoreNGrams/"; //

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
  "principle_of_general_relativity_byCitations.txt",
};

ArrayList<Article> articles = new ArrayList(); // in arrayList form
HashMap<String, Article> articlesHM = new HashMap(); // id, Article   -    keep it in hm form too

// ngram stuff.  
int ngramMax = 2; // from 1 to this number will be made

// 
void setup() {
  loadAllArticles(dataDirectory, targetFiles, keyTerms);

  // temp get rid of all but one.. three Article

  int toSave = 3;
  ArrayList<Article> saved = new ArrayList();
  for (int i = 0; i < min (toSave, articles.size ()); i++) saved.add(articles.get(i));
  articlesHM.clear();
  for (Article a : saved) articlesHM.put(a.id, a);


  loadRawNGrams(articlesHM, articleRawNGramDirectory, ngramMax); // load all raw ngrams for this article.  if the file doesnt exist then make a new one
  //a.loadReducedNGrams(articles, articleRawNGramDirectory); // load all reduced ngrams for this article - where they are reduced based on the idf.  if the file doesnt exist then make a new one
  // 
  loadNGramScores(articlesHM, articleScoreNGramDirectory);

  //for (Article a : saved) println("____________\n____________\n" + a.toSimplifiedString());  

  //sortArticlesBySomething(articles, "keywords");
  //sortArticlesBySomething(articles, "subjectArea");
  IntDict byYear = OCRUtils.countOccurrences(articles, "publishedYear");
  //println(byYear);

  //for (Article a : articles) println(a.title + " -- " + a.publishedYear + "\n" + a.abstractString + "\n\n");
  /*
  // also temp output the top keywords
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

