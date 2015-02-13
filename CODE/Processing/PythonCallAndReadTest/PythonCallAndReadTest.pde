//https://processing.org/discourse/beta/num_1244736039.html
import java.io.*;

OutputStream stdin = null;



String mainDirectory = "/Applications/MAMP/htdocs/OCR/einstein/CODE/Python/Scholar/sikoriedMod/";
String scriptName = "scholar.py";
//String scriptName = "test.py";


String[] params = {
 "python",
 mainDirectory + scriptName,

 "--cites", 
 "--cluster-id", 
 "\"8987828492054530436\"", 
 "-S", 
 "10", 
 "--citation", 
 "en", 
 
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
  String line;
  
  try {
    Runtime run = Runtime.getRuntime();
    Process p = run.exec(params);

    BufferedReader input = new BufferedReader(new InputStreamReader(p.getInputStream()));

    while ( (line = input.readLine ()) != null) {
      println(line);
    }
    input.close();
  }
  catch (Exception e) {
    println("problem with exec");
  }
  println("done");
  exit();
} // end setup

