//https://processing.org/discourse/beta/num_1244736039.html
import java.io.*;

OutputStream stdin = null;

String mainDirectory = sketchPath("") + "../../Python/scholar.py_sikoried.py/";
String scriptName = "scholar.py";

String masterSeedClusterId = "8987828492054530436";

boolean useDelay = true; // whether or not to delay it a bit
float minDelayInMS = 14000f;
float maxDelayInMS = 60000f;

//
void setup() {
} // end setup


//
void draw() {
} // end draw

//
void keyReleased() {
  if (key == ' ') {
    String thisCaller = "8987828492054530436";
    int maxPageCount = 30; // -1 to ignore
    int minCiteCount = -1; // -1 to ignore
    Caller c = new Caller(thisCaller, maxPageCount, minCiteCount);
    c.run();
  }
} // end keyReleased

