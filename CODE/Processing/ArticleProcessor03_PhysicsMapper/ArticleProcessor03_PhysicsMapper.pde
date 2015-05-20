import ocrUtils.maths.*;
import ocrUtils.*;
import ocrUtils.ocr3D.*;
import java.util.Map;
import java.util.Arrays;
import java.util.Calendar;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.TimeUnit;
import rita.*;
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;


// the arxiv directory with all 50k articles for general relativity
//String arxivDirectory = "/Users/noa/Desktop/OCR-local/Einstein/CODE/Processing/ArxivAPI/arxiv/";


// the arxivDirectory for the articles that had the word Einstein's in the abstract
String arxivDirectory2014 = "x_2014/";

// termDirectory
String termDirectory = "data/";

// ARTICLES
ArrayList<Article> articles = new ArrayList(); // what is to be queried
HashMap<String, Article> articlesHM = new HashMap();
int[] targetYears = {
  //2015,
  2014, 
  //2013,
  //2012,
  //2011,
  //2010,
}; // years to choose from

// TERMS
TermManager termManager = new TermManager();


// temp zpt stuff
ZoomPanTilt zpt;
PVector mouseLoc = new PVector();
PVector worldLoc = new PVector();

// box2d
Box2DProcessing box2d;
boolean box2dOn = true;


//
void setup() {
  long startTime = millis();
  size(500, 500, P3D);
  OCRUtils.begin(this);
  SimpleTween.begin(this);
  zpt = new ZoomPanTilt(this);
  randomSeed(1862);

  // load terms
  importTerms(sketchPath("") + termDirectory);
  termManager.loadDefaultTermPositions(sketchPath("") + termDirectory);


  // make box2d
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  // No global gravity force
  box2d.setGravity(0, 0);


  /*
  // import all 50k articles
   importArticles(arxivDirectory, targetYears);
   // temp output the articles for this year so that it doesnt need to be researched every time
   XML xml = new XML("TwentyFourteen");
   for (Article a : articles) xml.addChild(a.xml);
   saveXML(xml, "x_2014/" + nf(articles.size(), 5) + ".xml"); 
   */

  // load up the simplified set within the pre-sorted years
  importArticles(sketchPath("") + arxivDirectory2014, new int[0]);

  termManager.assignTermsToArticles(articles);
  termManager.assignArticlesToTerms(articles); // go back and assign the articles to the terms so debug lines can be drawn


  // setup the bodies for the articles
  for (Article a : articles) a.setupBody(10f);


  // make the 'gravity' for each term
  termManager.assignGravities(articles.size());

  // set the initial positions
  termManager.setArticlesToExactPositions(articles);


  println("total startup time: " + (((float)(millis() - startTime)) / 1000) + " seconds");
} // end setup

//
void draw() {

  zpt.use();

  if (box2dOn) box2d.step();  

  mouseLoc.set(mouseX, mouseY);
  worldLoc = zpt.getWorldCoordFromPoint(mouseLoc);  

  background(0);




  noFill();
  stroke(255, 0, 0, 150);
  rect(0, 0, width, height);

  termManager.update(worldLoc);
  termManager.debugDisplay(g);

  float sc = zpt.sc.value();
  for (Article a : articles) {
    a.update();
    a.debugDisplayTarget(g);
  }
  boolean doShowMouseOver = true;
  for (Article a : articles) {
    if (a.debugDisplay(g, sc, worldLoc, doShowMouseOver)) doShowMouseOver = false;
  }


  zpt.pause();
} // end draw

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
//
//
//
//
//

