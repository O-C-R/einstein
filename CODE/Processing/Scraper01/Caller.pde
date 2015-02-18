class Caller {
  String folderTree = ""; // main folder for the top Caller??


  String clusterId = "";
  int maxPageCount = -1; // -1 to ignore.  otherwise go until this page count is reached
  int minCiteCount = -1; // -1 to ignore.  when the cite count is less than this stop

  long inception = millis(); // when this caller was born


  int startIndex = 0;
  int indexJump = 10; // default number of items for the page thing
  int pageCounter = 0; // each time the index jumps this should increment

  Article thisArticle = null; // the article made from this thing??

  // holder vars
  Runtime run;
  Process p;
  BufferedReader input;
  String line;


  String[] params; // the line that gets called to run the scholar.py
  String jsonString = ""; // the buildup string for the scholar.py call
  ArrayList<JSONObject> totalObjects = new ArrayList(); // the json format of the articles for this caller
  ArrayList<Article> totalArticles = new ArrayList(); // a listing of all of the articles that cite this caller/clusterId

  //
  Caller(String clusterId, int maxPageCount, int minCiteCount) {
    this.clusterId = clusterId;
    this.maxPageCount = maxPageCount;
    this.minCiteCount = minCiteCount;

    // to do -- 
    // check whether or not this article exists.  if not then make up an article file for it??
  } // end constructor

  //
  public void run() {
    long startTime = millis();
    // do a while loop of sorts to cycle through for this clusterId

    while (true) {
      try {
        params = makeParams();
        jsonString = makeCall();
        ArrayList<JSONObject> newObjects = makeJSONObjects(jsonString);

        println("after makeJSONObjects.  made total of: " + newObjects.size() + " objects");
        for (JSONObject json : newObjects) println(json);

        totalObjects.clear();
        if (newObjects.size() == 0) {
        } else {
          totalObjects.addAll(newObjects);
        }
        println("BEFORE MAKEARTICLES");
        ArrayList<Article> newArticles = makeArticles(totalObjects);

        println("after makeArticles.  made: " + newArticles.size() + " new articles");

        if (newArticles.size() == 0) {
          println("ran out of articles, breaking");
          break;
        }
        pageCounter++;

        // check for cite count
        if (minCiteCount != -1) {
          boolean minCiteMet = true;
          // assume that the articles are in order of citations
          for (int i = 0; i < newArticles.size (); i++) {
            if (newArticles.get(i).citations >= minCiteCount && newArticles.get(i).isValid) { // only add valid articles
              totalArticles.add(newArticles.get(i));
            } else {
              println("at minCite for article with cite of: " + newArticles.get(i).citations + " which is less than " + minCiteCount);
              minCiteMet = false;
              break;
            }
          }
          if (!minCiteMet) {
            println("breaking because of minCiteCount");
            break;
          }
        } else {
          for (Article ar : newArticles) if (ar.isValid) totalArticles.add(ar); // only add valid articles
        }

        // check for page break;
        if (pageCounter >= maxPageCount && maxPageCount != -1) {
          println("at pageCounter page of " + pageCounter);
          break;
        }

        // add to the start point for the page
        startIndex += indexJump;

        // optional: delay
        if (useDelay) {
          delay((int)random(minDelayInMS, maxDelayInMS));
        }
      } 
      catch (Exception e) {
        println("Exception when doing run.  stopping here");
        break;
      }
    } // end while
    println("make a total of: " + totalArticles.size() + " total articles");
    //for (Article a : totalArticles) println(a);


    outputCaller();
    println("done with run for cluster: " + clusterId + " .. took " + (((float)millis() - startTime) / 1000) + " seconds and made a total of " + totalArticles.size() + " articles");
    println( " and ran though " + pageCounter + " pages");
  } // end run

  //
  String[] makeParams() {
    String[] newParams = {
      "python", 
      sketchPath("") + mainDirectory + scriptName, 
      "--cites", 
      "--cluster-id", 
      clusterId, 
      "-S", 
      startIndex + "", 
      "--json"
    };
    return newParams;
  } // end makeParams

    //
  public String makeCall() {
    println("in makeCall for line: " );
    println(" " + join(params, " "));

    String newJSONString = ""; 

    try {
      run = Runtime.getRuntime();
      p = run.exec(params);

      input = new BufferedReader(new InputStreamReader(p.getInputStream()));

      while ( (line = input.readLine ()) != null) {
        newJSONString += line;
      }
      input.close();
    }
    catch (Exception e) {
      println("problem with exec");
    }
    return newJSONString;
  } // end makeCall

  //
  public ArrayList<JSONObject> makeJSONObjects(String jsonStringIn) {
    if (jsonStringIn == null || jsonStringIn.length() == 0) return null;
    ArrayList<JSONObject> newObjs = new ArrayList();
    String[] answers = split(jsonStringIn, "}{");
    for (String s : answers) {
      if (s.charAt(0) != '{') s = "{" + s;
      if (s.charAt(s.length() -1 ) != '}') s += '}'; 
      JSONObject json = JSONObject.parse(s);
      //println(json);
      newObjs.add(json);
    }
    return newObjs;
  } // end makeJSONObjects

    //
  // use all of the json objects to make objs
  public ArrayList<Article> makeArticles(ArrayList<JSONObject> totalObjectsIn) {
    ArrayList<Article> newArticles = new ArrayList();
    for (JSONObject json : totalObjectsIn) {
      Article article = new Article(json);
      newArticles.add(article);
    }
    return newArticles;
  } // end makeArticles

    //
  public void outputCaller() {
    // output the file associated with this call
    // should be titled by the clusterId and simply list all of the other clusterIds that cite this one
    PrintWriter output = createWriter("output/" + masterSeedClusterId + "/cites/" + clusterId + ".txt");
    for (Article ar : totalArticles) {
      output.println(ar.clusterId);
    }
    output.flush();
    output.close();

    // also output the each one of the child article's pages

    for (Article ar : totalArticles) {
      output = createWriter("output/" + masterSeedClusterId + "/article/" + ar.clusterId + ".json");
      output.println(ar.toJSON());
      output.flush();
      output.close();
      //println(ar);
    }
  } // end outputCaller
} // end class Caller

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

