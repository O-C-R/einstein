// This will read the .gdf file that is exported from Gephi
import java.util.Map;

//String dataFile = "AirlinesGDF.gdf";
String dataFile = "HeidlerExport01GDF.gdf";
//String dataFile = "jazz.gdf";

HashMap<Integer, Node> nodes = new HashMap();
HashMap<String, Edge> edges = new HashMap();





// movement control
ZoomPanSimple zps;
PVector mouseLoc = new PVector();
PVector worldLoc = new PVector();


//
void setup() {
  size(1000, 800);
  background(24);
  smooth(4);



  // load up the actual gdf data
  loadGDF(dataFile);



  zps = new ZoomPanSimple(this);
} // end setup



//
void draw() {
  background(0);
  zps.use();
  mouseLoc.set(mouseX, mouseY);
  worldLoc = zps.getWorldCoordFromPoint(mouseLoc);


  // temporary function to display the Edges and Nodes
  tempDisplayStuff(g);



  zps.pause();
} // end draw



//
void mouseDragged() {
  zps.dealWithMouseDragged();
} // end mouseDragged

//
void mouseWheel(MouseEvent event) {
  zps.dealWithMouseWheel(event);
} // end mouseWheel

//
//
//
//
//

