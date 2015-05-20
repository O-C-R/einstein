//
class Wikipedia {
  int year = 0;
  String topic = "";
  String[] sources = new String[0];
  String[] txt = new String[0]; // raw text
  String[] sentences = new String[0]; // hold the sentences
  String[][] words = new String[0][0]; // using RiTa.tokenize().  organized by sentence

  ArrayList<KeywordLink> links = new ArrayList();

  //HashMap<String, Integer> keywordCount = new HashMap(); // String keyword, Integer count
  HashMap<String, String[]> keywordCount = new HashMap(); // String keyword, String[] of the sentences where this occurs
  
  // temp vars for sorting
  int temp = 0;

  //
  Wikipedia(String topic, String[] sources, String[] txt, int year) {
    this.year = year;
    this.topic = topic;
    this.sources = sources;
    this.txt = txt; // the raw text
    // split the text into sentences – stripped of punctuation and in lowerCase()
    for (String s : txt) {
      String[] broken = RiTa.splitSentences(s);
      for (String ss : broken) sentences = (String[])append(sentences, cleanSentence(ss));
    }

    for (int i = 0; i < sentences.length; i++) {
      words = (String[][])append(words, RiTa.tokenize(sentences[i]));
    }
    for (int i = 0; i < words.length; i++) {
      //println(sentences[i]);
      //println("i: " + nf(i, 3) + " len: " + words[i].length);
    }
  } // end constructor

  //
  public void makeKeywordLinks(ArrayList<Article> articlesIn) {
    for (Article a : articlesIn) {
      for (String k : a.keywords) {
        String[] sentenceStore = this.hasKeyword(k);
        if (sentenceStore.length > 0) {
          KeywordLink newLink = new KeywordLink(this, a, k, sentenceStore);
          links.add(newLink);
          //println("LOOKING AT ARTICLE: " + a);
          //println("keywords as: ");
          //for (String s : a.keywords) println(s);
        }
      }
    }
    // sort
    //links = OCRUtils.sortObjec
    //for (KeywordLink kl : links) println(kl);
  } // end makeKeywordLinks

  //
  // check if a keyword/phrase is in the list of words.  if it is store the count so it doesnt have to be recounted 
  String[] hasKeyword(String keyWord) {
    keyWord = keyWord.trim();
    keyWord = keyWord.replace("-", " ");
    keyWord = keyWord.toLowerCase();

    int count = 0;
    String[] sentenceStore = new String[0];
    //if (keywordCount.containsKey(keyWord)) count = (Integer)keywordCount.get(keyWord);
    if (keywordCount.containsKey(keyWord)) sentenceStore = (String[])keywordCount.get(keyWord);
    else {
      String[] keyWordText = split(keyWord, " "); 
      for (String[] sentence : words) {
        for (int i = 0; i < sentence.length - keyWordText.length + 1; i++) {
          boolean has = true;
          for (int j = 0; j < keyWordText.length; j++) {
            //println(i + "  keywordDiff: " + keyWord + " keyWordText[" + j + "]: " + keyWordText[j] + " -- sentence[" + (j + i) + "]: " + sentence[j + i] + " -- sentence.length: " + sentence.length);
            if (!keyWordText[j].equals(sentence[j + i])) {
              has = false;
              break;
            }
          }
          if (has) {
            count++;
            sentenceStore = (String[])append(sentenceStore, join(sentence, " "));
            //println("  ****** found: \"" + keyWord + "\" in sentence at i: " + i + " -- " + join(sentence, " "));
          }
        }
      }
      //for (int i = 0; i < words.length -
      if (count > 0) {
        //println("&& count is greater than 0: " + count + " for word: " + keyWord);
        //keywordCount.put(keyWord, count);
        keywordCount.put(keyWord, sentenceStore);
      }
    }
    //return count;
    return sentenceStore;
  } // end hasKeyword



  //
  String toString () {
    String builder = ""; 
    builder += "WIKI: " + topic + " sources: "; 
    for (String s : sources) builder += s + " -- "; 
    builder += "\n  word count: " + words.length; 
    builder += "\n  sentence count: " + sentences.length;
    return builder;
  } // end toString
} // end class Wikipedia


//
//
// this is the helper class that stores the relationship between the Wikipedia things and the Articles
class KeywordLink {
  Wikipedia wiki = null; // the parent wiki
  Article article = null; // the parent article
  String keyword = ""; 
  String[] sentences = new String[0]; // a store of the sentences where this occured
  int occurancesOfKeywordInWikipedia = 0; // count of how many times this word appears in the Wikipedia article
  //
  KeywordLink(Wikipedia wiki, Article article, String keyword, String[] sentences) {
    this.wiki = wiki;
    this.article = article;
    this.keyword = keyword;
    this.sentences = sentences;
    this.occurancesOfKeywordInWikipedia = sentences.length;
  } // end constructor
  //
  String toString() {
    String builder = "";
    builder += " keywordlink: " + keyword + " count: " + occurancesOfKeywordInWikipedia + " wiki name: " + wiki.topic + " art title: " + article.title;
    for (int i = 0; i < sentences.length; i++) builder += "\n  sentence: " + sentences[i];
    return builder;
  } // end toString
} // end class KeywordLink


//
//
//
//
//

