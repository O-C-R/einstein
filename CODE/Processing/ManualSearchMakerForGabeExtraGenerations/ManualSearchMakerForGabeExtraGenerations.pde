import java.util.Map;

//
// change these things
int generation = 1; // what generation to look into
String baseFolder = "Generations/";

HashMap<String, Thing> labelsToMake = new HashMap(); // String Cluster ID, Integer nothing


String[] clusterIds = {
  "6260380372219921579", 
  "8066420215978626200", 
  "426412038412359390", 
  "10181864712941716750"
};

String[] clusterNames = {
  "Relativity: The special and general theory", 
  "Die feldgleichungen der gravitation", 
  "Zur allgemeinen Relativitätstheorie", 
  "The Foundation of the Generalised Theory of Relativity",
};

// base query:
// python scholar.py --cites -C 6260380372219921579 --start 0 --after 1940 --before 1950 >> 6260380372219921579_1940-1950_1.json

//
void setup() {
  OCRUtils.begin(this);


  String folderToUse = baseFolder + generation + "/";
  String[] allFiles = OCRUtils.getFileNames(sketchPath("") + folderToUse, false);

  for (String fileName : allFiles) {
    if (fileName.contains(".json")) {
      String jsonString = join(loadStrings(fileName), "");
      ArrayList<JSONObject> jsons = makeJSONObjects(jsonString);

      if (jsons == null) continue;

      //println("total jsons: " + jsons.size());
      for (JSONObject json : jsons) {
        // check for nulls.  if so skip
        try {

          int citeCount = json.getInt("Citations");
          int year = json.getInt("Year");
          String title = json.getString("Title");
          String thisClusterId = json.getString("Title").replace(" ", "");
          boolean isValid = false;
          try {
            thisClusterId = json.getString("Cluster ID");
            isValid = true;
          } 
          catch( Exception ggg) {
            // invalid clusterID
            println("invalid cluster id");
          }

          Thing newThing = new Thing(thisClusterId, title, citeCount, year, isValid);
          labelsToMake.put(thisClusterId, newThing);
        }
        catch (Exception e) {
          println("exception when making newThing for json:");
          println(json);
        }
      }
    }
  }

  println("total labelsToMake: " + labelsToMake.size());




  ArrayList<Thing> organizedThings = new ArrayList();
  for (Map.Entry me : labelsToMake.entrySet ()) {
    //String thisClusterId = ((String)me.getKey()).trim();
    Thing myThing = (Thing)me.getValue();
    //organizedList = (String[])append(organizedList, thisClusterId);
    organizedThings.add(myThing);
  }
  //organizedThings = OCRUtils.sortObjectArrayListSimple(organizedThings, "year");
  
  organizedThings = OCRUtils.sortObjectArrayListSimple(organizedThings, "citeCount");
  organizedThings = OCRUtils.reverseArrayList(organizedThings);









  int pagesToDo = 2;
  int startingYear = 1900;
  int yearAddition = 10; // howmany
  int endingYear = 2015; 

  // more static things
  int countPerPage = 10;

  int totalLinesPrinted = 0;


  PrintWriter output = createWriter("output/lookupList-" + OCRUtils.getTimeStampWithDate() + ".txt");


  //for (int clusterIndex = 0; clusterIndex < clusterIds.length; clusterIndex++) {
  for (int clusterIndex = 0; clusterIndex < organizedThings.size (); clusterIndex++) {


    //String clusterId = clusterIds[clusterIndex];
    //String clusterName = clusterNames[clusterIndex];
    Thing thing = organizedThings.get(clusterIndex);
    String clusterId = thing.clusterId;
    String clusterName = thing.title;
    int currentStartYear = startingYear;

    output.println("******** -- " + clusterName + " -- " + clusterId + " -- year: " + thing.year + " -- citeCount: " + thing.citeCount + " *********");

    // SKIP THE NON VALID CLUSTER.  ONLY OUTPUT THE VALID CLUSTER
    if (thing.isValid) {
      while (currentStartYear < endingYear) {
        int currentEndYear = currentStartYear + yearAddition;
        output.println("_");
        for (int pageNumber = 0; pageNumber < pagesToDo; pageNumber++) {
          int startIndex = pageNumber * countPerPage;
          output.println("python scholar.py --cites -C " + clusterId + " --start " + startIndex + " --after " + 
            currentStartYear + " --before " + currentEndYear + " >> " + clusterId + "_" + currentStartYear + "-" + 
            currentEndYear + "_" + (pageNumber + 1) + ".json");
          totalLinesPrinted++;
        }

        currentStartYear = currentEndYear;
      }
    } else {
      output.println(" invalid invalid invalid");
    }

    output.println("_");
    output.println("_");
    output.println("_");
  }

  output.flush();
  output.close();

  println("total lines printed: " + totalLinesPrinted);

  exit();
} // end setup

