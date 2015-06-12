//
public void setupArticleSizes(ArrayList<Article> articlesIn) {
  println("in setupArticleSizes");
  // based on.. cites count?
  float minSize = 5f;
  float maxSize = 25f;
  float minArea = minSize * minSize * PI;
  float maxArea = maxSize * maxSize * PI;
  float maxCitersToUse = 100;
  float maxCitersActual = 0;
  for (Article a : articles) maxCitersActual = (a.citerIds.size() > maxCitersActual ? a.citerIds.size() : maxCitersActual);
  for (Article a : articles) {
    float targetArea = constrain(map(a.citerIds.size(), 0, maxCitersToUse, minArea, maxArea), minArea, maxArea);
    float newRadius = sqrt(targetArea / PI);
    a.radius = newRadius;
  }
} // end setupArticleSizes

//
// this will set the background colors and also the inner stuff 
public void setupArticleColorsAndStuff(ArrayList<Article> articlesIn) {
  println("in setupArticleColorsAndStuff");
  float minSize = .25f;
  float maxSize = 10f;
  float minArea = minSize * minSize * PI;
  float maxArea = maxSize * maxSize * PI;
  // ****** //
  // ****** //
  float maxAuthorsToUse = 20;
  float maxAuthorsActual = 0;
  float maxTotalAuthorCountsRatioToUse = 18; // as in total papers by all authors divided by author count
  // ****** //
  // ****** //
  for (Article a : articles) maxAuthorsActual = (a.authorCounts.size() > maxAuthorsActual ? a.authorCounts.size() : maxAuthorsActual);
  for (Article a : articles) {

    float targetArea = constrain(map(a.authorCounts.size(), 0, maxAuthorsToUse, minArea, maxArea), minArea, maxArea);
    float newRadius = sqrt(targetArea / PI);
    float innerRadius = newRadius;
    //println(" author count: " + a.authors.length + " innerRadius: " + innerRadius);
    // figure the color

    float totalAuthorCount = a.authorCountsSum; // the total papers by all authors
    float average = totalAuthorCount / a.authorCounts.size();
    //float newHue = constrain(map(average, 0, maxTotalAuthorCountsRatioToUse, hue(colorAuthorMin), hue(colorAuthorMax)), hue(colorAuthorMin), hue(colorAuthorMax));
    color innerColor = lerpColor(colorAuthorMin, colorAuthorMax, map(average, 0, maxTotalAuthorCountsRatioToUse, 0, 1));

    color innerStroke = innerColor;
    a.setInner(innerRadius, innerColor, innerStroke);
  }
} // end setupArticleColorsAndStuff


//
public void setupArticleZs(ArrayList<Article>articlesIn) {
  println("in setupArticleZs");
  float minZ = 0f;


  // do it by the number of articles around it
  float maxAddition = 1.5f; // how much is added to z?  regulate this to control overall addition
  float radiusOfInfluence = 185f; // how wide to cast the net in determining influence.  closer nodes have more inflence
  for (int i = 0; i < articlesIn.size (); i++) {
    float newZ = minZ;
    int count = 0;
    for (int j = 0; j < articlesIn.size (); j++) {
      if (j == i) continue;
      float dist = articlesIn.get(i).regPos.dist(articlesIn.get(j).regPos);
      if (dist < radiusOfInfluence) {
        newZ += map(dist, 0f, radiusOfInfluence, maxAddition, 0f);
        count++;
      }
    }
    println("total counts for article: " + articlesIn.get(i).id + " is: " + count + " with newZ of: " + newZ);
    articlesIn.get(i).setZ(newZ);
  }


  /*
  // try it by the number of shared concepts around it
   float maxAddition = 1f; // how much is added to z?  regulate this to control overall addition
   float radiusOfInfluence = 155f; // how wide to cast the net in determining influence.  closer nodes have more inflence
   for (int i = 0; i < articlesIn.size (); i++) {
   float newZ = minZ;
   int count = 0;
   for (int j = 0; j < articlesIn.size (); j++) {
   if (j == i) continue;
   float dist = articlesIn.get(i).regPos.dist(articlesIn.get(j).regPos);
   if (dist < radiusOfInfluence) {
   // count similar concepts
   int similarConcepts = 0;
   for (Term t : articlesIn.get (i).terms) {
   for (Term tt : articlesIn.get (j).terms) {
   if (t == tt) {
   similarConcepts++;
   break;
   }
   }
   }
   //newZ += map(dist, 0f, radiusOfInfluence, maxAddition, 0f);
   newZ += map(dist, 0f, radiusOfInfluence, maxAddition, 0f) * similarConcepts;
   count++;
   }
   }
   println("total counts for article: " + articlesIn.get(i).id + " is: " + count + " with newZ of: " + newZ);
   articlesIn.get(i).setZ(newZ);
   }
   */

  // try it by proximity to concept if it has that concept?
  /*
  float maxAddition = 30f; // how much is added to z?  regulate this to control overall addition
   float radiusOfInfluence = 155f; // how wide to cast the net in determining influence.  closer nodes have more inflence
   for (int i = 0; i < articlesIn.size (); i++) {
   float newZ = minZ;
   for (Term t : articlesIn.get (i).terms) {
   PVector artPos = articlesIn.get(i).regPos.get();
   PVector termPos = t.pos.get();
   float dist = artPos.dist(termPos);
   if (dist < radiusOfInfluence) {
   newZ += map(dist, 0f, radiusOfInfluence, maxAddition, 0f);
   }
   }
   articlesIn.get(i).setZ(newZ);
   }
   */
} // end setupArticleZs




//
public void drawLinesFromArticlesToConcepts(PGraphics pg, ArrayList<Article> articlesIn, boolean useArticleZIn) {
  PVector start = new PVector();
  PVector end = new PVector();
  PVector startMid = new PVector();
  PVector endMid = new PVector();
  float slideA = .8;
  float slideB = 1 - slideA;
  pg.stroke(colorConnectorLine, 25);
  pg.noFill();
  for (Article a : articles) {
    for (Term t : a.terms) {
      start.set(a.regPos.x, a.regPos.y, (useArticleZIn ? 1 : 0) * a.z);
      end.set(t.pos.x, t.pos.y, termBaseZ + t.z);

      startMid.set(slideA * start.x + slideB * end.x, slideA * start.y + slideB * end.y, start.z -.25 * abs(end.z - start.z));
      endMid.set(slideA * end.x + slideB * start.x, slideA * end.y + slideB * start.y, end.z + .35 * abs(end.z - start.z));
      pg.beginShape();
      curveVertex(start.x, start.y, start.z + 20);
      curveVertex(start.x, start.y, start.z);
      curveVertex(startMid.x, startMid.y, startMid.z);
      curveVertex(endMid.x, endMid.y, endMid.z);
      curveVertex(end.x, end.y, end.z);
      curveVertex(end.x, end.y, end.z - 20);
      pg.endShape();
    }
  }
} // end darwLinesFromArticlesToConcepts


//
//
//
//
//
//
//
//

