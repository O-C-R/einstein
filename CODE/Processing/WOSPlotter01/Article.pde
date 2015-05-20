//

class Article {

  public String id = "";
  public String title = "";
  public String[] authors = new String[0];
  //String url = "";
  //String citationsList = "";



  // wos characteristics  
  public String publicationName = "";
  public String[] keywords = new String[0];
  public String abstractString = "";
  public String[] citesList = new String[0]; // listing of the things this article cites
  public int citesCount = 0; // how many items this thing is cited
  public  int wosCitesCount = 0; // how many times this thing is cited within wos?
  public int totalCitesCount = 0; // how many times it was cited in total?  same as wosCited?
  public int publishedYear = 0; // year of publication
  public int pageCount = 0; // number of pages in this thing?
  public String[] wosCategories = new String[0];
  public String[] subjectArea = new String[0];



  public boolean isValid = true; // marked as false if the basic criteria isnt met

  public PVector pos = new PVector();

  HashMap<String, Article> citers = new HashMap(); // articles that cite this one
  HashMap<String, Article> cites = new HashMap(); // articles that this one is recorded as citing

  ArrayList<NGram> ngrams = new ArrayList();
  HashMap<String, NGram> ngramsHM = new HashMap(); // hashed version for easy counting
  HashMap<Integer, HashMap<String, NGram>> ngramsHMByLength = new HashMap(); // just separate hashmaps bylength


  // term stuff
  //ArrayList<Term> terms = new ArrayList();
  //HashMap<String, Term> termsHM = new HashMap();

  //
  Article(String id) {
    this.id = id;
  } // end constructor


  //
  // articles that cite this thing
  public void addCiter(Article a) {
    if (!citers.containsKey(a.id)) citers.put(a.id, a);
  } // end addCiter

  //
  // articles that this thing cites
  public void addCites(Article a) {
    if (!cites.containsKey(a.id)) cites.put(a.id, a);
  } // end addCite


  //
  processing.data.JSONObject toJSON() {
    processing.data.JSONObject json = new processing.data.JSONObject();
    json.setString("id", id);
    json.setString("title", title);
    json.setString("publicationName", publicationName);
    //json.setString("Version list", versionsList);
    //json.setInt("Versions", versions);
    //json.setString("Citation link", citationsList);
    json.setInt("citesCount", citesCount);
    json.setInt("wosCitesCount", wosCitesCount);
    json.setInt("totalCitesCount", totalCitesCount);
    json.setInt("publishedYear", publishedYear);
    json.setInt("pageCount", pageCount);



    //json.setString("URL", url);
    //json.setString("Citations list", citationsList);

    // authors
    processing.data.JSONArray ar = new processing.data.JSONArray();
    for (int i = 0; i < authors.length; i++) {
      ar.setString(i, authors[i]);
    }
    json.setJSONArray("authors", ar);

    // keywords
    processing.data.JSONArray kar = new processing.data.JSONArray();
    for (int i = 0; i < keywords.length; i++) {
      kar.setString(i, keywords[i]);
    }
    json.setJSONArray("keywords", kar);

    // citesList
    ar = new processing.data.JSONArray();
    for (int i = 0; i < citesList.length; i++) {
      ar.setString(i, citesList[i]);
    }
    json.setJSONArray("citesList", ar);


    // wosCategories
    ar = new processing.data.JSONArray();
    for (int i = 0; i < wosCategories.length; i++) {
      ar.setString(i, wosCategories[i]);
    }
    json.setJSONArray("wosCategories", ar);

    // subjectArea
    ar = new processing.data.JSONArray();
    for (int i = 0; i < subjectArea.length; i++) {
      ar.setString(i, subjectArea[i]);
    }
    json.setJSONArray("subjectArea", ar);

    return json;
  } // end toJSON

  //
  // return the json format of the raw ngram jsons
  processing.data.JSONObject getRawNGramJSON() {
    processing.data.JSONObject json = new processing.data.JSONObject();
    json.setString("id", id);
    processing.data.JSONArray jar = new processing.data.JSONArray();
    for (int i = 0; i < ngrams.size (); i++) {
      jar.setJSONObject(i, ngrams.get(i).getJSON());
    }
    json.setJSONArray("ngrams", jar);
    return json;
  } // end getRawNGram JSON

  //
  // return the json format of the scored ngram jsons
  processing.data.JSONObject getScoreNGramJSON() {
    processing.data.JSONObject json = new processing.data.JSONObject();
    json.setString("id", id);
    processing.data.JSONArray jar = new processing.data.JSONArray();
    for (int i = 0; i < ngrams.size (); i++) {
      jar.setJSONObject(i, ngrams.get(i).getJSON());
    }
    json.setJSONArray("ngrams", jar);
    return json;
  } // end getScoreNGramJSON

  //
  public void makeRawNGrams(int ngramMaxIn) {    
    // plan of attack:
    // use RiTa 
    // split into sentences
    // http://www.rednoise.org/rita/reference/RiTa/RiTa.splitSentences/index.html
    String[] allSentences = new String[0];
    String[] splitt = RiTa.splitSentences(title);
    for (String s : splitt) allSentences = (String[])append(allSentences, s);
    splitt = RiTa.splitSentences(abstractString);
    for (String s : splitt) allSentences = (String[])append(allSentences, s);
    // then tokenize && add counts
    // http://www.rednoise.org/rita/reference/RiTa/RiTa.tokenize/index.html
    for (int i = 0; i < allSentences.length; i++) {
      String thisSentence = RiTa.stripPunctuation(allSentences[i].toLowerCase());
      String[] thisSentenceBroken = split(thisSentence, " ");
      //println("Sentence: " + i);
      //println("  " + thisSentence);
      for (int j = 0; j < thisSentenceBroken.length; j++) {
        String thisTerm = "";
        for (int k = 0; k < ngramMaxIn; k++) {
          if (k + j >= thisSentenceBroken.length) break;
          thisTerm += " " + thisSentenceBroken[k + j];
          //println("j, k: " + j + ", " + k + " -- " + thisTerm);
          if (!ngramsHM.containsKey(thisTerm.trim())) {
            NGram newGram = new NGram(thisTerm.trim(), 0);
            //ngrams.add(newGram);
            //ngramsHM.put(thisTerm, newGram);
            addNGram(newGram);
          }
          ((NGram)ngramsHM.get(thisTerm.trim())).incrementRaw();
        }
      }
    }
    ngrams = OCRUtils.sortObjectArrayListSimple(ngrams, "count");
    ngrams = OCRUtils.reverseArrayList(ngrams);
    //println("made a total of " + ngrams.size() + " ngrams");
    //println("top ngrams:");
    //for (int i = 0; i < min(100, ngrams.size()); i++) println(ngrams.get(i));
  } // end makeRawNGrams

    //
  public void addNGram(NGram ngram) {
    ngrams.add(ngram);
    ngramsHM.put(ngram.term, ngram);
    // add by length
    if (!ngramsHMByLength.containsKey(ngram.length)) {
      ngramsHMByLength.put(ngram.length, new HashMap<String, NGram>());
    }
    HashMap<String, NGram> lengthGram = (HashMap<String, NGram>)ngramsHMByLength.get(ngram.length);
    lengthGram.put(ngram.term, ngram);
    //println("adding term: __" + ngram.term + "__ of length: " + ngram.length + " to hm of length: " + lengthGram.size());
  } // end addNGram

  //
  public ArrayList<NGram> getNGramsOfLength(int lengthIn) {
    ArrayList<NGram> grams = new ArrayList();
    for (NGram ng : ngrams) if (ng.length == lengthIn) grams.add(ng);
    return grams;
  } // end getNGramsOfLength

  //
  String toString() {
    String builder = "";
    builder += toJSON();
    return builder;
  } // end toString

  //
  String toSimplifiedString() {
    String builder = "";
    builder += id + " - " + title + "\n  abstract: " + abstractString + "\n  publishedYear " + publishedYear + " citesCount: " + citesCount + "\n   keywords: " + join(keywords, ", ") + "\n   wosCategories: " + join(wosCategories, ", ");
    builder += "\n  ngram sizes total: " + ngramsHMByLength.size();
    Integer len = 1;
    while (true) {
      if (ngramsHMByLength.containsKey(len)) {
        HashMap<String, NGram> byLen = (HashMap<String, NGram>) ngramsHMByLength.get(len);
        builder += "-  " + len + "_" + byLen.size() + "   ";
        len++;
      } else {
        break;
      }
    }
    return builder;
  } // end toSimplifiedString
} // end class Article






//
// ngram terms
public class NGram {
  String term = "";
  int count = 0;
  int length = 0;
  // see http://www.tfidf.com/
  float tf = 0; // in this case it will be this count divided by the sum of all terms for the parent document... ??  so sum of all counts
  float idf = 0; // IDF(t) = log_e(Total number of documents / Number of documents with term t in it).
  float score = 0; // tf * idf
  NGram(String term, int count) {
    this.term = term;
    this.count = count;
    this.length = (split(term, " ")).length;
  } // end constructor
  //
  void incrementRaw() {
    count++;
  } // end incrementRaw
  //
  void assignScore(float score) {
    this.score = score;
  } // end assignScore
  // 
  processing.data.JSONObject getJSON() {
    processing.data.JSONObject json = new processing.data.JSONObject();
    json.setString("term", term);
    json.setInt("count", count);
    json.setFloat("score", score);
    return json;
  } // end getJSON
  //
  String toString() {
    return " ngram: __" + term + "__ count: " + count + " score: " + score;
  } // end toString
} // end class NGram

//
//
//
//
//
//

