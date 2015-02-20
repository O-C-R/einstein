//

class Article {
  String clusterId = "";
  String title = "";
  String[] authors = new String[0];
  String url = "";
  String citationsList = "";
  int citations = 0; // count
  int versions = 0;
  String versionsList = "";
  int year = 0;

  boolean isValid = true; // marked as false if the basic criteria isnt met
  
  PVector pos = new PVector();

  HashMap<String, Article> citers = new HashMap(); // articles that cite this one
  HashMap<String, Article> cites = new HashMap(); // articles that this one is recorded as citing

  //
  Article(JSONObject json) {
    if (json.hasKey("Cluster ID")) {
      try {
        clusterId = json.getString("Cluster ID");
      }
      catch (Exception e) {
        isValid = false;
      }
    }
    if (json.hasKey("Title")) {
      try {
        title = json.getString("Title");
      }
      catch (Exception e) {
        isValid = false;
      }
    }
    if (json.hasKey("Citations")) {
      try {
        citations = json.getInt("Citations");
      }
      catch (Exception e) {
        isValid = false;
      }
    }
    if (json.hasKey("Versions")) {
      try {
        versions = json.getInt("Versions");
      }
      catch (Exception e) {
      }
    }
    if (json.hasKey("Citations list")) {
      try {
        citationsList = json.getString("Citations list");
      }
      catch (Exception e) {
      }
    }
    if (json.hasKey("URL")) {
      try {
        url = json.getString("URL");
      }
      catch (Exception e) {
      }
    }
    if (json.hasKey("Versions list")) {
      try {
        versionsList = json.getString("Versions list");
      }
      catch (Exception e) {
      }
    }
    if (json.hasKey("Year")) {
      try {
        year = Integer.parseInt(json.getString("Year"));
      }
      catch (Exception e) {
      }
    }
    // deal with author
    if (json.hasKey("Authors")) {
      try {
        String authorList = json.getString("Authors");
        String[] authorSplit = split(authorList, ",");
        for (String s : authorSplit) {
          authors = (String[])append(authors, s.trim());
        }
      }
      catch (Exception e) {
      }
    }
  } // end constructor

  //
  // articles that cite this thing
  public void addCiter(Article a) {
    if (!citers.containsKey(a.clusterId)) citers.put(a.clusterId, a);
  } // end addCiter
  
  //
  // articles that this thing cites
  public void addCites(Article a) {
    if (!cites.containsKey(a.clusterId)) cites.put(a.clusterId, a);
  } // end addCite

  //
  JSONObject toJSON() {
    JSONObject json = new JSONObject();
    json.setString("Cluster ID", clusterId);
    json.setString("Version list", versionsList);
    json.setInt("Versions", versions);
    json.setString("Citation link", citationsList);
    json.setInt("Citations", citations);
    json.setString("URL", url);
    json.setString("Citations list", citationsList);
    json.setString("Title", title);
    // authors
    JSONArray ar = new JSONArray();
    for (int i = 0; i < authors.length; i++) {
      ar.setString(i, authors[i]);
    }
    json.setJSONArray("Authors", ar);
    return json;
  } // end toJSON

  //
  String toString() {
    String builder = "";
    builder += toJSON();
    return builder;
  } // end toString
  
  //
  String toSimplifiedString() {
    String builder = "";
    builder += clusterId + " - " + year + " citers: " + citers.size() + " cites: " + cites.size();
    return builder;
  } // end toSimplifiedString
} // end class Article

