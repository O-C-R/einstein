//https://processing.org/discourse/beta/num_1244736039.html
import java.io.*;

OutputStream stdin = null;



String mainDirectory = "/Applications/MAMP/htdocs/OCR/einstein/CODE/Python/scholar.py_sikoried.py/";
String scriptName = "scholar.py";
//String scriptName = "test.py";


String[] params = {
  "python", 
  mainDirectory + scriptName, 


  "--cites", 
  "--cluster-id", 
  "8987828492054530436", 
  "-S", 
  "10", 
  "--json"
    //"--citation", 
  //"en", 

  //">>", 
  //"testtesttest.txt"
};

/*
String[] params = {
 "python", 
 mainDirectory + scriptName, 
 "hello",
 "this is my voice on tv" 
 //">>", 
 //mainDirectory + "testPrint.txt"
 };
 */




//
void setup() {
  println(join(params, " "));
  String line ;
  String jsonString = "";

  try {
    Runtime run = Runtime.getRuntime();
    Process p = run.exec(params);

    BufferedReader input = new BufferedReader(new InputStreamReader(p.getInputStream()));

    while ( (line = input.readLine ()) != null) {
      //println(line);
      jsonString += line;
    }
    input.close();
  }
  catch (Exception e) {
    println("problem with exec");
  }

  //jsonString = jsonString.replace("null", "\"\"");
  //jsonString = jsonString.replace("null}", "null,}");
  //jsonString = jsonString.replace("null", "\"_\"");
  //jsonString = "{\"values\":[" + jsonString + "]}";
  String[] answers = split(jsonString, "}{");

  for (String s : answers) {
    if (s.charAt(0) != '{') s = "{" + s;
    if (s.charAt(s.length() -1 ) != '}') s += '}'; 
    //println(jsonString);
    JSONObject json = JSONObject.parse(s);
    //JSONArray jsonAr = JSONArray.parse(jsonString);;
    //println(jsonString);
    println(json);
  }

  println("done");
  exit();
} // end setup

