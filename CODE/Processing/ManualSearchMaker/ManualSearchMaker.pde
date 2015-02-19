import java.util.Map;

//
// change these things
int generation = 3; // what generation to look into
String baseFolder = "/Applications/MAMP/htdocs/OCR/einstein/CODE/Python/scholar.py_sikoried.py/";
int pageCount = 1; // how many pages to go through

HashMap<String, Thing> labelsToMake = new HashMap(); // String Cluster ID, Integer nothing

//
void setup() {
  String folderToUse = baseFolder + generation + "/";
  String[] allFiles = OCRUtils.getFileNames(folderToUse, false);
  for (String fileName : allFiles) {
    if (fileName.contains(".json")) {
      String jsonString = join(loadStrings(fileName), "");
      ArrayList<JSONObject> jsons = makeJSONObjects(jsonString);
      println("total jsons: " + jsons.size());
      for (JSONObject json : jsons) {
        // check for nulls.  if so skip
        try {
          String thisClusterId = json.getString("Cluster ID");
          int citeCount = json.getInt("Citations");
          int year = json.getInt("Year");
          Thing newThing = new Thing(thisClusterId, citeCount, year);
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



  //String[] organizedList = new String[0];
  ArrayList<Thing> organizedThings = new ArrayList();
  for (Map.Entry me : labelsToMake.entrySet ()) {
    //String thisClusterId = ((String)me.getKey()).trim();
    Thing myThing = (Thing)me.getValue();
    //organizedList = (String[])append(organizedList, thisClusterId);
    organizedThings.add(myThing);
  }
  //organizedList = sort(organizedList);
  organizedThings = OCRUtils.sortObjectArrayListSimple(organizedThings, "citeCount");
  organizedThings = OCRUtils.reverseArrayList(organizedThings);

  //for (Map.Entry me : labelsToMake.entrySet ()) {
  //for (String thisClusterId : organizedList) {

  // output things
  String outputFolder = sketchPath("") + "output/";
  PrintWriter output = createWriter(outputFolder + (generation + 1) + "-labels.txt");
  PrintWriter checkcheck =   createWriter(outputFolder + (generation + 1) + "-checkCheck.txt");
  for (Thing t : organizedThings) { 
    for (int i = 0; i < pageCount; i++ ) {
      //output.println("python scholar.py --cites --cluster-id " + thisClusterId + " --json --start " + (i * 10) + " >> " + (generation + 1) + "/" + thisClusterId + "-" + (1 + i) + ".json");
      output.println("python scholar.py --cites --cluster-id " + t.clusterId + " --json --start " + (i * 10) + " >> " + (generation + 1) + "/" + t.clusterId + "-" + (1 + i) + ".json");
      checkcheck.println(t.clusterId + " -- cites: " + t.citeCount + " -- year: " + t.year);
    }
  }
  output.flush();
  output.close();
  checkcheck.flush();
  checkcheck.close();
  exit();
} // end setup


//
public ArrayList<JSONObject> makeJSONObjects(String jsonStringIn) {
  if (jsonStringIn == null || jsonStringIn.length() == 0) return null;
  ArrayList<JSONObject> newObjs = new ArrayList();
  String[] answers = split(jsonStringIn, "}{");
  for (String s : answers) {
    if (s.charAt(0) != '{') s = "{" + s;
    if (s.charAt(s.length() -1 ) != '}') s += '}';

    try { 
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

//
class Thing {
  String clusterId = "";
  int citeCount = 0;
  int year = 0;
  //
  Thing (String clusterId, int citeCount, int year) {
    this.clusterId = clusterId;
    this.citeCount = citeCount;
    this.year = year;
  } // end constructor
} // end class Thing

//
//
//
//

