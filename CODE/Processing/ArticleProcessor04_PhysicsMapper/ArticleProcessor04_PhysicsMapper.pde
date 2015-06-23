// to do list
// read in the rest of the data files = 

// figure out how to deal with articles that do not have a category connection

// assign the gravity to the terms -- also save to the json file


// notes on how to run this thing:
/*
  ºº  HOW TO RUN IT ALL
 ºº Assuming a fresh start.
 
 ºº First adjust the category network.
 
 ºº Any modifications to the strength and/or lengths of the edges can be done in termManager.makeTermNetwork() .. go there and change the vars
 
 ºº Changing the repulsion strength and all that will affect how big/small the network is
 
 ºº If you want to manually pull the terms into positions make sure the termDebug is set to on [see below]
 
 ºº To lock everything into place set lockDefaultTermPositions to true and/or lockDefaultArticlePositions to true;
 ºººº This should... make it so that it loads the default positions and you can't overwrite it nor recalculate it.  but, with the Articles you still have to recalc the height by pressing '8'
 
 
 
 
 Assuming the locations have all been saved
 
 
 ººControls
 
 ºº FILES
 ºººº TERMS
 ºººººº 'q' to save the term positions as default == this should load up the next time the program starts
 ºººººº 'w' to load the default positions if that file exists
 ºººººº 'e' to save the term positions to a file 
 ºººººº 'r' to load a term positions file
 ºº note that when a term file is loaded the physicsOn will/should be turned to false
 
 ºººº ARTICLES
 ºººººº '1' to save the term positions as default == this should load up the next time the program starts
 ºººººº '2' to load the default positions if that file exists
 ºººººº '3' to save the term positions to a file
 ºººººº '4' to load a term positions file
 
 
 
 ºº TERMS
 ºººº 'p' to toggle the term physics engine on or off - note that when a TermLocation file is loaded this will/should be set to false
 ºººº 'd' to toggle termDebug.  This will allow you to move around the term positions
 ºººº 't' to toggle term display.
 ºººººº  press SPACE when dragging or right click on a term to make it ignore physics [aka lock it]
 ºººº '\' to rebuild the physics behind the terms
 ºººº '=' to randomize the starting locations of the terms
 
 ºº ARTICLES
 ºººº 'b' to toggle box2dOn.  this will control whether or not the article nodes actually wiggle around or not
 ºººº '-' to make the Articles jump to around where they are trying to go.  do this after Term positions are set.  this way they get really close to where they want to be.
 ºººº '8' calculate the heights.  this is done a the end [and via a keystroke] because it has to calculate it based off of its neighbors, etc.
 ºººº 'z' toggle whether or not to use the z height of the Articles
 
 ºº OTHER
 ºººº 'c' toggle on/off the connecting curves that go from the Articles to the Terms
 ºººº '.' and ',' make the Term positions go up and down
 ºººº '`' -- the weird accent key -- use to save out a frame
 ºººº 'g' gridOn toggler
 ºººº '6' to save out the different images in pdf format.  this will save the layers to the renders/[todays date and time]/fileName.pdf
 
 
 ºº VIEW
 ºº pan around by RIGHT clicking and dragging
 ºº zoom with scroll wheel
 ºº 'a' toggle between top view and angled ortho view
 ºººº when in ortho:
 ºººº UP/DOWN to change viewing angle
 ºººº LEFT/RIGHT to rotate
 
 
 
 
 ººAll COLORS can be changed in the colors tab
 ººººThe inner circle describes the authorship of the article
 ººººººthe size is related to the number of authors
 ººººººthe color is based on the ratio of total papers written by all authors divided by the total number of authors.  eg if a bunch of people wrote a bunch of papers then they have a higher value than a bunch of people who have written only this paper
 ººººººthis is what colorAuthorMin and colorAuthorMax are for.  min lerps to max based on this ratio
 
 ººººThe outer stroke of the circle is whether or not the article was published
 ººººººcolorPublished and colorUnpublished control this
 
 ªªªªThe stroke of the lines connecting the Articles to the concepts below are controlled with colorConnectorLine
 
 
 
 */




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
import processing.pdf.*;

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

// article positions
String articlePositionsDirectory = "articlePositions/";

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
boolean articlesOn = true; // whether or not show the articles and do the box2d stuff
boolean useArticleZ = true; // will eitehr use the z factor in displaying the Articles or not
boolean drawConnectingLines = false; // will draw lines from the articles to their concepts

// TERMS
TermManager termManager = new TermManager();
// setting up the term network via box2d
boolean showPhysics = false; // if true will show the 'physics' lines between the terms
boolean physicsOn = false; // leave as false
// basez level of the terms
float termBaseZ = -1900f; // where the base is for all Terms


boolean termDebug = false; // if true will allow you to manually drag around the term positions.  toggle with 'd'
boolean termDisplay = true; // for displaying or not displaying the terms


// ****** //
// note that this will make it so that it will load up whatever the defaultPositions.json file is .. .which should include all physics stuff and positions regarless of how many articles are loaded
// ideally the positions of the Terms should be made when all of the Articles have been loaded -- this sets the springs correctly
// then after the default positions have been set and saved -- press 's', set this boolean to true and then relaunch the program
// that will auto load the defaults and make it so that the space can't be modified.  
boolean lockDefaultTermPositions = false; // if set to true will not save or overwrite the default nor will it do the physics stuff

boolean lockDefaultArticlePositions = false; // if set to true will not save or overwrite the article positions.  nor will it do box2d stuff



// temp zpt stuff
ZoomPanTilt zpt;
PVector mouseLoc = new PVector();
PVector worldLoc = new PVector();
// rotation/axo stuff
float xAngle = 9 * PI/32;
float zAngle = -11 * PI/32;
boolean useAngles = false;


// box2d
Box2DProcessing box2d;
boolean box2dOn = false;

// other stuff
boolean gridOn = true;
boolean movieSave = false;
String movieSaveDirectory = "";

// rendering vars
String renderDirectory = "";
String[] renderSteps = {
  "articles", 
  "gridLower", 
  "gridUpper", 
  "connectingLines", 
  "termLines", 
  "termText", 
  "termNetwork"
};
int renderIndex = renderSteps.length; // increments when rendering




//
void setup() {
  long startTime = millis();
  //size(1200, 800, P3D);
  //size(1200, 800, OPENGL);
  //size(1625, 1075, P3D); // page ratio titlted
  size(585, 774, P3D);
  //size(1075, 1625, P3D); // page ratio
  OCRUtils.begin(this);
  SimpleTween.begin(this);
  zpt = new ZoomPanTilt(this);
  randomSeed(1862);
  //smooth(3);


  // Initialize the physics
  physics=new VerletPhysics2D();
  physics.setWorldBounds(new Rect(10, 10, width-20, height-20));

  // load terms
  importTerms(sketchPath("") + termDirectory);
  println("loaded: " + termManager.terms.size() + " terms");




  // make box2d
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  // No global gravity force
  box2d.setGravity(0, 0);






  // load up the simplified set within the pre-sorted years
  importArticles(sketchPath("") + arxivDirectory2014, new int[0]);

  // this needs to happen after articles are imported
  termManager.loadDefaultTermPositions(sketchPath("") + termDirectory, articlesHM);

  //HashMap<String, ArrayList<Term>> articleTerms = importArticleTerms();
  // this will read in the category scores for the articles as assigned by alchemy
  dealOutTerms(sketchPath("") + articleConceptsDirectory, articlesHM, termManager.termsHM);

  // set up the authors for the articles
  dealOutAuthors(sketchPath("") + articleAuthorDirectory, articlesHM);

  // read in the cites
  dealOutCites(sketchPath("") + articleCitesDirectory, articlesHM);

  // and the references
  dealOutReferences(sketchPath("") + articleReferencesDirectory, articlesHM);


  // and finally deal with the termless articles
  dealWithTermless(articlesHM, termManager.terms);


  // setup the term z's
  termManager.setZs();


  // temp check
  //for (int i = 0; i < 10; i++) println(articles.get(i).toSimplifiedString() + " \n\n\n____");

  // setup the sizes of each article based on something
  if (articlesOn) setupArticleSizes(articles); // note that this requires the citers to be set

  // setup the color factors and inner circles and all that
  if (articlesOn) setupArticleColorsAndStuff(articles);


  // setup the bodies for the articles
  //for (Article a : articles) a.setupBody(10f);
  if (articlesOn) for (Article a : articles) a.setupBody();


  // make the 'gravity' for each term
  termManager.assignGravities(articlesHM);

  // set the initial positions
  if (articlesOn) termManager.setArticlesToExactPositions(articles);
  if (articlesOn) termManager.updateArticleTargets(articles);

  if (articlesOn) {
    loadDefaultArticlePositions(sketchPath("") + articlePositionsDirectory);
  }

  // do the height check
  if (articlesOn) setupArticleZs(articles); 



  println("total startup time: " + (((float)(millis() - startTime)) / 1000) + " seconds");
} // end setup

//
void draw() {
  if (renderIndex < renderSteps.length) {
    beginRaw(PDF, renderDirectory + renderSteps[renderIndex] + ".pdf");
  }




  zpt.use();

  if (useAngles) {
    ortho(0, width, 0, height, -23400, 3000); // overmanage the clipping plane
    rotateX(xAngle); // angles it to the side
    rotateZ(zAngle); // rotates it around z axis
  }


  if (lockDefaultArticlePositions) box2dOn = false;
  if (box2dOn) box2d.step();  


  if (lockDefaultTermPositions) physicsOn = false;
  if (physicsOn) {
    physics.update();
  }



  mouseLoc.set(mouseX, mouseY);
  worldLoc = zpt.getWorldCoordFromPoint(mouseLoc);

  background(0);


  // draw the grid
  // public void drawGrid(ArrayList<Float> zs, PVector centerXY, float extents, color col)
  if ((gridOn && renderIndex >= renderSteps.length) || (renderIndex < renderSteps.length && (renderSteps[renderIndex].equals("gridLower") || renderSteps[renderIndex].equals("gridUpper")))) {
    ArrayList<Float> gridZs = new ArrayList();
    gridZs.add(termBaseZ);
    if (renderIndex < renderSteps.length && (renderSteps[renderIndex].equals("gridUpper"))) gridZs.clear(); // if supposed to be saving out grid, if this is upper round, take out lower
    float lowZ = 300000;
    for (Article a : articles) lowZ = (a.z < lowZ ? a.z : lowZ);
    gridZs.add(lowZ);
    if (renderIndex < renderSteps.length && (renderSteps[renderIndex].equals("gridLower"))) gridZs.remove(gridZs.size() - 1); // if supposed to be saving out grid, if this is upper round, take out lower

    PVector center = new PVector();
    for (Term t : termManager.terms) center.add(t.pos);
    center.div(termManager.terms.size());
    float xExtents = 1000;
    float yExtents = 1000;
    drawGrid(g, gridZs, center, xExtents, yExtents, gridColor);
  } // end pdf check



  //noFill();
  //stroke(255, 0, 0, 150);
  //rect(0, 0, width, height);

  termManager.update(worldLoc, articles, !articlesOn);
  if (termDebug) termManager.debugDisplay(g);
  if ((termDisplay && renderIndex >= renderSteps.length) || (renderIndex < renderSteps.length && renderSteps[renderIndex].equals("termText"))) {
    boolean getSVGTexts = (renderIndex < renderSteps.length && renderSteps[renderIndex].equals("termText"));
    termManager.displayText(g, termBaseZ);
    if (getSVGTexts) {
      // save it out
      ArrayList<SVGText> svgTexts = termManager.getSVGTexts();
      saveSVGText(svgTexts, renderDirectory + renderSteps[renderIndex] + ".svg");
    }
  }
  if ((termDisplay && renderIndex >= renderSteps.length) || (renderIndex < renderSteps.length && renderSteps[renderIndex].equals("termLines"))) {
    termManager.displayLines(g, termBaseZ);
  }
  if ((termDisplay && renderIndex >= renderSteps.length) || (renderIndex < renderSteps.length && renderSteps[renderIndex].equals("termNetwork"))) {
    termManager.displayNetwork(g, termBaseZ);
  }

  float sc = zpt.sc.value();


  if (articlesOn || renderIndex < renderSteps.length) {
    if ((drawConnectingLines && renderIndex >= renderSteps.length) || (renderIndex < renderSteps.length && renderSteps[renderIndex].equals("connectingLines"))) {
      drawLinesFromArticlesToConcepts(g, articles, useArticleZ);
    }



    for (Article a : articles) {
      a.update();
      //a.debugDisplayTarget(g);
    }
    boolean doShowMouseOver = true;

    if (renderIndex >= renderSteps.length || (renderIndex < renderSteps.length && renderSteps[renderIndex].equals("articles"))) {
      for (Article a : articles) {
        //if (a.debugDisplay(g, sc, worldLoc, doShowMouseOver)) doShowMouseOver = false;
        a.display(g, useArticleZ);
      }
    }
  }



  // physics stuff
  // Display all points
  if (showPhysics && renderIndex >= renderSteps.length) {
    termManager.showPhysics(g);
  }




  zpt.pause();




  // 
  if (renderIndex >= renderSteps.length) {
    fill(255);
    textAlign(LEFT, TOP);
    if (useAngles) {
      text("xAngle: " + xAngle, 20, 20);
      text("zAngle: " + zAngle, 20, 40);
    }
    text("termBaseZ: "+ termBaseZ, 20, 60);
    text("offset: " + zpt.offset.value().x+ ", " + zpt.offset.value().y, 20, 80);
  }

  if (movieSave) {
    saveFrame(movieSaveDirectory + "#####.tif");
  }


  // end any render
  if (renderIndex < renderSteps.length) {
    drawRegistration(g);
    println("finished making pdf for render step: " + renderSteps[renderIndex]);
    endRaw();
    renderIndex++;
  }
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

