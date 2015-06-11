// to do list
// read in the rest of the data files = 

// figure out how to deal with articles that do not have a category connection

// assign the gravity to the terms -- also save to the json file


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

import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics.*;

// Reference to physics world
VerletPhysics2D physics;


// the arxiv directory with all 50k articles for general relativity
// not used
//String arxivDirectory = "/Users/noa/Desktop/OCR-local/Einstein/CODE/Processing/ArxivAPI/arxiv/";


// the arxivDirectory for the articles that are from 2014
String arxivDirectory2014 = "x_2014/";

// termDirectory
String termDirectory = "data/";

// article concepts directory  -- save the concepts/terms to each article  
String articleConceptsDirectory = "alchemyConceptsForArticles/";

// the author list per article
String articleAuthorDirectory = "alchemyAuthorCounts/";

// the cites list per article
String articleCitesDirectory = "arxivCites/";

// and the refrences list per article
String articleReferencesDirectory = "arxivReferences/";

// 

// ARTICLES
ArrayList<Article> articles = new ArrayList(); // what is to be queried
HashMap<String, Article> articlesHM = new HashMap();
int[] targetYears = {
  2014,
}; // years to choose from

// TERMS
TermManager termManager = new TermManager();
// setting up the term network via box2d
boolean showPhysics = true;
boolean physicsOn = false; // leave as false

// ****** //
// note that this will make it so that it will load up whatever the defaultPositions.json file is .. .which should include all physics stuff and positions regarless of how many articles are loaded
// ideally the positions of the Terms should be made when all of the Articles have been loaded -- this sets the springs correctly
// then after the default positions have been set and saved -- press 's', set this boolean to true and then relaunch the program
// that will auto load the defaults and make it so that the space can't be modified.  
boolean lockDefaultTermPositions = false; // if set to true will not save or overwrite the default nor will it do the physics stuff



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
  size(1200, 800, P3D);
  OCRUtils.begin(this);
  SimpleTween.begin(this);
  zpt = new ZoomPanTilt(this);
  randomSeed(1862);


  // Initialize the physics
  physics=new VerletPhysics2D();
  physics.setWorldBounds(new Rect(10, 10, width-20, height-20));

  // load terms
  importTerms(sketchPath("") + termDirectory);
  println("loaded: " + termManager.terms.size() + " terms");

  termManager.loadDefaultTermPositions(sketchPath("") + termDirectory);


  // make box2d
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  // No global gravity force
  box2d.setGravity(0, 0);






  // load up the simplified set within the pre-sorted years
  importArticles(sketchPath("") + arxivDirectory2014, new int[0]);

  //HashMap<String, ArrayList<Term>> articleTerms = importArticleTerms();
  // this will read in the category scores for the articles as assigned by alchemy
  dealOutTerms(sketchPath("") + articleConceptsDirectory, articlesHM, termManager.termsHM);

  // set up the authors for the articles
  dealOutAuthors(sketchPath("") + articleAuthorDirectory, articlesHM);

  // read in the cites
  dealOutCites(sketchPath("") + articleCitesDirectory, articlesHM) ;

  // and the references
  dealOutReferences(sketchPath("") + articleReferencesDirectory, articlesHM) ;


  // temp check
  //for (int i = 0; i < 10; i++) println(articles.get(i).toSimplifiedString() + " \n\n\n____");

  // setup the bodies for the articles
  for (Article a : articles) a.setupBody(10f);


  // make the 'gravity' for each term
  //termManager.assignGravities(articles.size());

  // set the initial positions
  termManager.setArticlesToExactPositions(articles);
  termManager.updateArticleTargets(articles);



  println("total startup time: " + (((float)(millis() - startTime)) / 1000) + " seconds");
} // end setup

//
void draw() {
  zpt.use();

  if (box2dOn) box2d.step();  

  if (physicsOn) {
    physics.update();
  }



  mouseLoc.set(mouseX, mouseY);
  worldLoc = zpt.getWorldCoordFromPoint(mouseLoc);

  background(0);




  noFill();
  stroke(255, 0, 0, 150);
  rect(0, 0, width, height);

  termManager.update(worldLoc, articles);
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



  // physics stuff
  // Display all points
  if (showPhysics) {
    termManager.showPhysics(g);
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

