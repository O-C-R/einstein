//
public ArrayList<Article> loadAllArticles(String directoryName) {
  ArrayList<Article> newArticles = new ArrayList(); // in arrayList form
  HashMap<String, Article> newArticlesHM = new HashMap(); // keep it in hm form too

  long startTime = millis();

  String[] allDirectories = OCRUtils.getDirectoryNames(directoryName, false);
  // assume only traversing the numbered directories
  for (String folderFullName : allDirectories) {
    String folderName = split(folderFullName, "/")[split(folderFullName, "/").length - 1];
    try {
      int folderNumber = Integer.parseInt(folderName);

      String[] allFiles = OCRUtils.getFileNames(folderFullName, false);
      println("folderNumber: " + folderNumber + " has: " + allFiles.length + " files");
      for (String fileName : allFiles) {
        String parentCluster = splitTokens(fileName, "/.\\")[splitTokens(fileName, "/.\\").length - 2];
        parentCluster = split(parentCluster, "-")[0];
        Article parentArticle = null;
        if (newArticlesHM.containsKey(parentCluster)) {
          parentArticle = (Article)newArticlesHM.get(parentCluster);
        }

        // try catch for null file
        try {
          String jsonString = join(loadStrings(fileName), "");
          ArrayList<JSONObject> jsons = makeJSONObjects(jsonString);
          //println("total jsons for fileName: " + fileName + " is " + jsons.size());
          // make articles from jsons
          for (JSONObject json : jsons) {
            try {
              Article newArticle = new Article(json);
              if (newArticle.isValid) {
                // save this new article to the overall list
                if (!newArticlesHM.containsKey(newArticle.clusterId)) {
                  newArticlesHM.put(newArticle.clusterId, newArticle);
                  newArticles.add(newArticle);
                  // assign cite children if parent exists
                }

                // switch to childArticle to ensure that the same article is used
                Article childArticle = (Article)newArticlesHM.get(newArticle.clusterId);
                if (parentArticle != null) {
                  parentArticle.addCiter(childArticle);
                  childArticle.addCites(parentArticle);
                } else {
                  //println("PARENT ARTICLE IS NULL FOR CLUSTER: " + parentCluster);
                }
              }
            }
            catch (Exception ee) {
              println("exception when making new Article from json");
            }
          }
        } 
        catch (Exception aa) {
          println("exception when loading file: " + fileName);
        }
      }
    }
    catch (Exception e) {
      println("exception for folder: " + folderName);
    }
  }

  println("done loading: " + newArticles.size() + " new articles in " + (((float)millis() - startTime) / 1000) + " seconds");
  return newArticles;
} // end loadAllArticles

//
public ArrayList<JSONObject> makeJSONObjects(String jsonStringIn) {
  if (jsonStringIn == null || jsonStringIn.length() == 0) return null;
  ArrayList<JSONObject> newObjs = new ArrayList();
  String[] answers = split(jsonStringIn, "}{");
  for (String s : answers) {
    if (s.charAt(0) != '{') s = "{" + s;
    if (s.charAt(s.length() -1 ) != '}') s += '}';

    try { 
      // replace any stray \\ marks because the db is weird sometimes
      s = s.replace("\\\"", "");
      
      JSONObject json = JSONObject.parse(s);
      //println(json);
      newObjs.add(json);
    }
    catch (Exception e) {
      println("problem making json object for string: " + s);
    }
  }
  return newObjs;
} // end makeJSONObjects

