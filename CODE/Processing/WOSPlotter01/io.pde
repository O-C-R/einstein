//
public void loadAllArticles(String directoryName, String[] targetFiles, String[] keyTermsIn) {
  ArrayList<Article> newArticles = new ArrayList(); // in arrayList form
  HashMap<String, Article> newArticlesHM = new HashMap(); // keep it in hm form too

  long startTime = millis();

  //String[] allDirectories = OCRUtils.getDirectoryNames(directoryName, false);

  String[] allFileNames = OCRUtils.getFileNames(directoryName, false);
  String[] filesToUse = new String[0];
  if (targetFiles.length == 0) filesToUse = allFileNames;
  else {
    for (String fn : allFileNames) {
      String end = split(fn, "/")[split(fn, "/").length - 1];
      for (String o : targetFiles) {
        if (o.equals(end)) filesToUse = (String[])append(filesToUse, fn);
      }
    }
  }
  println("using options: " );
  //for (String o : filesToUse) println(o);
  int counter =0;
  int didNotContainTerm = 0; // temp for counting the articles that don't contain a key term
  for (String fileName : filesToUse) {
    try {
      Table table = loadTable(fileName, "header, tsv");
      println("loaded table for file: " + (split(fileName, "/")[split(fileName, "/").length - 1]) + ".  Has: " + table.getRowCount() + " rows");
      for (TableRow row : table.rows ()) {
        // check that it has keyterms
        boolean hasKeyTerms = false;


        String utString = row.getString("UT"); // actual wos id?

        String auString = row.getString("AU"); // authors
        String tiString = row.getString("TI"); // document title
        String soString = row.getString("SO"); // publication name
        String deString = row.getString("DE"); // author keywords
        String idString = row.getString("ID"); // keywords plus
        String abstractString = row.getString("AB"); // abstract
        String crString = row.getString("CR"); // cited references
        String nrString = row.getString("NR"); // cited reference count
        String tcString = row.getString("TC"); // wos times cited count
        String z9String = row.getString("Z9"); // total times cited
        String pyString = row.getString("PY"); // published year
        String vlString = row.getString("VL"); // volume
        String isString = row.getString("IS"); // issue
        String pgString = row.getString("PG"); // page count
        String wcString = row.getString("WC"); // wos category
        String scString = row.getString("SC"); // subject area



        /*
        String puString = row.getString("PU"); // publisher?
         String piString = row.getString("PI"); // publisher location?
         String pdString = row.getString("PD"); // publish date?  // some as months, some as actual days        
         String diString = row.getString("DI"); // id?      
         String snString = row.getString("SN"); // publisher id?
         
         */
        // check for article's existence using DI
        if (!newArticlesHM.containsKey(utString)) {
          Article newArticle = new Article(utString);

          newArticle.id = utString;



          // for now assume that all authors aren't stored.  it's all in the article
          // authors
          String[] broken = split(auString, ";");
          String[] authors = new String[0];
          for (String a : broken) authors = (String[])append(authors, a.trim()); 
          newArticle.authors = authors;

          newArticle.title = tiString;

          newArticle.publicationName = soString;

          // keywords
          broken = split(idString, ";");
          String[] keywords = new String[0];
          for (String a : broken) keywords = (String[])append(keywords, a.trim()); 
          newArticle.keywords = keywords;

          newArticle.abstractString = abstractString;

          broken = split(crString, ";");
          String[] citesList = new String[0];
          for (String a : broken) citesList = (String[])append(citesList, a.trim()); 
          newArticle.citesList = citesList;

          int citesCount = 0;
          try {
            citesCount = Integer.parseInt(nrString);
          }
          catch (Exception ee) {
          }
          newArticle.citesCount = citesCount;
          int wosCitesCount = 0;
          try {
            wosCitesCount = Integer.parseInt(tcString);
          }
          catch (Exception ee) {
          }
          newArticle.wosCitesCount = wosCitesCount;
          int totalCitesCount = 0;
          try {
            totalCitesCount = Integer.parseInt(z9String);
          }
          catch (Exception ee) {
          }
          newArticle.totalCitesCount = totalCitesCount;

          int publishedYear = 0;
          try {
            publishedYear = Integer.parseInt(pyString);
          }
          catch (Exception ee) {
          }
          newArticle.publishedYear = publishedYear;

          int pageCount = 0;
          try {
            pageCount = Integer.parseInt(pgString);
          }
          catch (Exception ee) {
          }
          newArticle.pageCount = pageCount;

          broken = split(wcString, ";");
          String[] wosCategories = new String[0];
          for (String a : broken) wosCategories = (String[])append(wosCategories, a.trim()); 
          newArticle.wosCategories = wosCategories;

          broken = split(scString, ";");
          String[] subjectArea = new String[0];
          for (String a : broken) subjectArea = (String[])append(subjectArea, a.trim()); 
          newArticle.subjectArea = subjectArea;

          // check that this artical has key terms either in the title or abstract
          if (keyTermsIn.length == 0) {
            hasKeyTerms = true;
          } else {
            for (String thisTerm : keyTermsIn) {
              if (newArticle.title.toLowerCase().contains(thisTerm) || newArticle.abstractString.toLowerCase().contains(thisTerm)) {
                hasKeyTerms = true;
                break;
              }
            }
          }



          // if it has the terms then add it to the hm and array
          if (hasKeyTerms) {
            newArticles.add(newArticle);
            newArticlesHM.put(utString, newArticle);
          } else {
            println("does not contain the key term");
            println(" title: " + newArticle.title + " \n abstract: " + newArticle.abstractString);
            didNotContainTerm++;
          }
        } else {
          //println("already has id: " + utString);
        }


        // if it is valid and has a key term 
        if (hasKeyTerms) {
          Article target = (Article)newArticlesHM.get(utString);
          // add this reference or whatever to it
          // add this reference or whatever to it
          // add this reference or whatever to it
          // add this reference or whatever to it
        }
        counter++;
      }
    } 
    catch (Exception e) {
      println("problem loading file: " + fileName);
    }
  } 


  for (Article a : newArticles) {
    //println(a + " \n\n\n");
    //println(a.toSimplifiedString());
  }

  //println("finished looking at: " + counter + " resources");
  println("done loading: " + newArticles.size() + " new articles in " + (((float)millis() - startTime) / 1000) + " seconds");
  println("total items not containing any of the " + keyTermsIn.length + " key terms: " + didNotContainTerm + " [out of total of: " + counter + "]");
  articles = newArticles;
  articlesHM = newArticlesHM;
} // end loadAllArticles

//
public ArrayList<processing.data.JSONObject> makeJSONObjects(String jsonStringIn) {
  if (jsonStringIn == null || jsonStringIn.length() == 0) return null;
  ArrayList<processing.data.JSONObject> newObjs = new ArrayList();
  String[] answers = split(jsonStringIn, "}{");
  for (String s : answers) {
    if (s.charAt(0) != '{') s = "{" + s;
    if (s.charAt(s.length() -1 ) != '}') s += '}';

    try { 
      // replace any stray \\ marks because the db is weird sometimes
      s = s.replace("\\\"", "");

      processing.data.JSONObject json = processing.data.JSONObject.parse(s);
      //println(json);
      newObjs.add(json);
    }
    catch (Exception e) {
      println("problem making json object for string: " + s);
    }
  }
  return newObjs;
} // end makeJSONObjects



//
// actually all of the raw text split into ngrams
// save into a few files?  Maybe set a limit
public void loadRawNGrams(HashMap<String, Article> articlesIn, String rawNGramDirectory, int ngramMaxIn) {
  println("_\n_in loadRawNGrams");
  long startTime = millis();
  int articlesPerFile = 50; // how many articles to save per file?
  String[] allRawFiles = OCRUtils.getFileNames(rawNGramDirectory, false);
  HashMap<String, Article> articlesWithExistingRawNGrams = new HashMap(); // keep track of those which have gotten the ngrams loaded
  ArrayList<Article> articlesToMakeRawNGrams = new ArrayList(); // these articles werent found, so must make new 
  HashMap<String, Integer> existingFileNames = new HashMap(); // so new file names can be come up with
  //HashMap<String, HashMap<String, Integer>> articleNGrams = new HashMap(); // article id, HashMap<Term, count>

  // go through all files
  for (String fileName : allRawFiles) {
    existingFileNames.put(getFileName(fileName), 0);


    try {
      // load up the json for this file
      processing.data.JSONObject json = loadJSONObject(fileName);
      processing.data.JSONArray jar = json.getJSONArray("articles");
      // go through all articles in the file
      for (int i = 0; i < jar.size (); i++) {
        processing.data.JSONObject jsonArticle = jar.getJSONObject(i);
        String id = jsonArticle.getString("id");
        if (articlesIn.containsKey(id)) {
          Article targetArticle = (Article)articlesIn.get(id);
          articlesWithExistingRawNGrams.put(id, targetArticle);
          targetArticle.ngrams.clear();
          targetArticle.ngramsHM.clear();
          processing.data.JSONArray ngar = jsonArticle.getJSONArray("ngrams");
          // go through all ngrams for this article
          for (int j = 0; j < ngar.size (); j++) {
            processing.data.JSONObject ngr = ngar.getJSONObject(j);
            String ngramTerm = ngr.getString("term");
            int ngramRawCount = ngr.getInt("count");
            NGram ngram = new NGram(ngramTerm, ngramRawCount);
            // assign the ngram to the article
            targetArticle.addNGram(ngram);
          }
        } else {
          println("does not contain Article " + id + " for ngrams");
        }
      }
    }
    catch (Exception e) {
    }
  }

  println("finished loading: " + articlesWithExistingRawNGrams.size() + " articles worth of ngrams in " + (((float)(millis() - startTime)) / 1000) + " seconds");



  // mark those which need their ngrams made
  for (Map.Entry me : articlesIn.entrySet ()) {
    Article a = (Article)me.getValue();
    if (!articlesWithExistingRawNGrams.containsKey(a.id)) articlesToMakeRawNGrams.add(a);
  }
  startTime = millis();
  println("going to make " + articlesToMakeRawNGrams.size() + " articles worth of new ngrams");
  //for (Article a : articlesToMakeRawNGrams) println("MAKE: " + a.id);


  // make the rawNGrams for these articles
  for (int i = 0; i < articlesToMakeRawNGrams.size (); i++) {
    articlesToMakeRawNGrams.get(i).makeRawNGrams(ngramMaxIn);
    if (i % 100 != 0) print("x");
    else print(i);
  }
  println("_done");

  // save out the new ngram files
  processing.data.JSONObject json = new processing.data.JSONObject();
  processing.data.JSONArray jar = new processing.data.JSONArray(); 
  for (int i = 0; i < articlesToMakeRawNGrams.size (); i++) {
    jar.setJSONObject(jar.size(), articlesToMakeRawNGrams.get(i).getRawNGramJSON());


    if (i > 0 && i % articlesPerFile  == 0 || i == articlesToMakeRawNGrams.size () - 1) {
      String newFileName = makeNewFileName(existingFileNames);
      println("saving out ngram file with file name: " + newFileName + " -- " + floor((i == articlesToMakeRawNGrams.size () - 1 ? 1 : 0) + (float)(i) / articlesPerFile) + " of " + ceil((float)(articlesToMakeRawNGrams.size ()) / articlesPerFile));
      existingFileNames.put(newFileName, 0);
      newFileName += ".json";
      // add the json array to the json object
      json.setJSONArray("articles", jar);
      // then save it here
      saveJSONObject(json, rawNGramDirectory + newFileName);
      // reset it
      json = new processing.data.JSONObject();
      jar = new processing.data.JSONArray();
    }
  }
  println("finished making: " + articlesToMakeRawNGrams.size() + " articles worth of NEW ngrams in " + (((float)(millis() - startTime)) / 1000) + " seconds");
} // end loadRawNGrams



// 
public void loadNGramScores(HashMap<String, Article> articlesIn, String scoreNGramDirectory) {
  println("_\n_in loadNGramScores");
  long startTime = millis();
  int articlesPerFile = 50; // how many articles to save per file?
  String[] allRawFiles = OCRUtils.getFileNames(scoreNGramDirectory, false);
  HashMap<String, Article> articlesWithExistingScoreNGrams = new HashMap(); // keep track of those which have gotten the ngrams loaded
  ArrayList<Article> articlesToMakeScoreNGrams = new ArrayList(); // these articles werent found, so must make new 
  HashMap<String, Integer> existingFileNames = new HashMap(); // so new file names can be come up with

  // if the count of existing scores doesnt match the articles in then redo the scores for al

  // go through all files
  for (String fileName : allRawFiles) {
    existingFileNames.put(getFileName(fileName), 0);
    try {
      // load up the json for this file
      processing.data.JSONObject json = loadJSONObject(fileName);
      processing.data.JSONArray jar = json.getJSONArray("articles");
      // go through all articles in the file
      for (int i = 0; i < jar.size (); i++) {
        processing.data.JSONObject jsonArticle = jar.getJSONObject(i);
        String id = jsonArticle.getString("id");
        if (articlesIn.containsKey(id)) {
          Article targetArticle = (Article)articlesIn.get(id);
          articlesWithExistingScoreNGrams.put(id, targetArticle);          
          processing.data.JSONArray ngar = jsonArticle.getJSONArray("ngrams");
          // go through all ngram scores for this article
          for (int j = 0; j < ngar.size (); j++) {
            processing.data.JSONObject ngr = ngar.getJSONObject(j);
            String ngramTerm = ngr.getString("term");
            //int ngramRawCount = ngr.getInt("count");
            float ngramScore = ngr.getFloat("score");
            // assign the score to the ngram
            try {
              NGram targetNGram = (NGram) targetArticle.ngramsHM.get(ngramTerm);
              targetNGram.assignScore(ngramScore);
            } 
            catch (Exception ee) {
              println("gram does not exist for term: " + ngramTerm);
            }
          }
        } else {
          println("does not contain Article " + id + " for ngrams");
        }
      }
    }
    catch (Exception e) {
    }
  }

  // if all articles have scores assigned, cool, otherwise REDO IT ALL with the current set of articles
  println("finished loading: " + articlesWithExistingScoreNGrams.size() + " articles worth of ngram SCORES in " + (((float)(millis() - startTime)) / 1000) + " seconds");
  if (articlesWithExistingScoreNGrams.size() == articlesIn.size()) {
    println(" that was all of them.  done");
  } else {
    println(" mismatch in scores.  will redo scoring with input set"); 
    startTime = millis();

    // make the actual scores
    makeNGramScores(articlesIn);

    println("_done");

    // save out the new ngram score files
    processing.data.JSONObject json = new processing.data.JSONObject();
    processing.data.JSONArray jar = new processing.data.JSONArray();
    int outputCounter = 0; 
    for (Map.Entry me : articlesIn.entrySet ()) {
      Article thisArticle = (Article)me.getValue();
      jar.setJSONObject(jar.size(), thisArticle.getScoreNGramJSON());
      if (outputCounter > 0 && outputCounter % articlesPerFile  == 0 || outputCounter == articlesIn.size () - 1) {
        String newFileName = makeNewFileName(existingFileNames);
        println("saving out ngram SCORES file with file name: " + newFileName + " -- " + floor((outputCounter == articlesIn.size () - 1 ? 1 : 0) + (float)(outputCounter) / articlesPerFile) + " of " + ceil((float)(articlesIn.size ()) / articlesPerFile));
        existingFileNames.put(newFileName, 0);
        newFileName += ".json";
        // add the json array to the json object
        json.setJSONArray("articles", jar);
        // then save it here
        saveJSONObject(json, scoreNGramDirectory + newFileName);
        // reset it
        json = new processing.data.JSONObject();
        jar = new processing.data.JSONArray();
      }
      outputCounter++;
    }

    println("finished making an entirely new set of ngram scores for " + articlesIn.size() + " articles worth of NEW ngrams in " + (((float)(millis() - startTime)) / 1000) + " seconds");
  } // end else to recalculate the scores
} // end loadNGramScores









// make the tf idf scores 
// see https://code.google.com/p/java-intelligent-tutor/source/browse/trunk/itjava/src/itjava/model/TFIDF.java?r=353
// http://nlp.stanford.edu/IR-book/html/htmledition/tf-idf-weighting-1.html
// see http://www.tfidf.com/
public void makeNGramScores(HashMap<String, Article> articlesIn) {
  // keep track of how many documents this ngram appears in
  HashMap<String, Integer> ngramDocCount = new HashMap();
  int temp = 0;
  for (Map.Entry me : articlesIn.entrySet ()) {
    Article target = (Article)me.getValue();
    for (NGram thisNGram : target.ngrams) {
      // count how many times it appears in all docs
      if (!ngramDocCount.containsKey(thisNGram.term)) {
        int count = 0;
        for (Map.Entry you : articlesIn.entrySet ()) {
          Article aa = (Article)you.getValue();
          if (aa.ngramsHM.containsKey(thisNGram.term)) count++;
        }
        ngramDocCount.put(thisNGram.term, count);
      }
      int documentCount = (Integer)ngramDocCount.get(thisNGram.term);
      // find the term frequency
      int totalTerms = 0;
      for (NGram ng : target.ngrams) totalTerms += ng.count;
      thisNGram.tf = ((float)thisNGram.count) / totalTerms;
      thisNGram.idf = 1 + (float)Math.log(articlesIn.size() / (Float.MIN_VALUE + documentCount));
      thisNGram.score = thisNGram.tf * thisNGram.idf;
      if (temp < 10) {
        //println("term: " + thisNGram.term + " total count: " + thisNGram.count + " tf: " + thisNGram.tf + " appearing in docs: " + documentCount + " with idf: " + thisNGram.idf + " and score: " + thisNGram.score);
      } 
      temp++;
    }
  }

  // sort all of the terms by score. temp print top 30 terms for each article
  for (Map.Entry me : articlesIn.entrySet ()) {
    Article a = (Article)me.getValue();
    //println("a.title: " + a.title);
    a.ngrams = OCRUtils.sortObjectArrayListSimple(a.ngrams, "score");
    a.ngrams = OCRUtils.reverseArrayList(a.ngrams);
    //for (int i = 0; i < min (10, a.ngrams.size ()); i++) {
    //println(a.ngrams.get(i));
    //}
  }
} // end makeNGramScores








//
// just come up with a random number
public String makeNewFileName(HashMap<String, Integer> existingFileNames) {
  String newName = "";
  while (true) {
    newName = System.currentTimeMillis() + "";
    if (!existingFileNames.containsKey(newName)) break;
  }
  return newName;
} // end makeNewFileName





//
String getFileName (String s) {
  String[] broken = splitTokens(s, "/.");
  return broken[broken.length - 2];
} // end getFileName

//
//
//
//
//
//
//
//
//

