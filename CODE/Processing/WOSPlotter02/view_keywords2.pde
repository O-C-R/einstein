// 
void viewKeywords2(ArrayList<Article> articlesIn, ArrayList<Wikipedia> wikisIn) {
  // reset all temp counts
  for (Article a : articlesIn) a.temp = 0;
  ArrayList<Article> filtered = new ArrayList(); // the ones that had at least one keyword link
  ArrayList<Article> forgottenArticles = new ArrayList(); // the ones that didnt belong to a keyword link

  // find the max pulls
  int maxWikiLinkCount = 0;
  int maxArticleLinkCount = 0;
  int maxWikiYear = 0;
  int minWikiYear = 33330;

  // find all of the articles that actually have a link to a wiki
  HashMap<Article, Integer> filteredArticles = new HashMap();
  for (Wikipedia w : wikisIn) {
    for (KeywordLink l : w.links) {
      Article a = l.article;
      if (!filteredArticles.containsKey(a)) {
        filteredArticles.put(a, 0);
        filtered.add(a);
      }
      // increment count
      a.temp++;
      a.objs.add(l);
    }
  }
  // sort articles by temp value
  filtered = OCRUtils.sortObjectArrayListSimple(filtered, "temp");
  filtered = OCRUtils.reverseArrayList(filtered);
  for (int i = 0; i < filtered.size (); i++) {
    //println(nf(i, 2) + " count: " + filtered.get(i).temp + " -- " + filtered.get(i).title);
    for (Object obj : filtered.get (i).objs) {
      KeywordLink kl = (KeywordLink)obj;
      //println(" -- keyword: " + kl.keyword + " wiki: " + kl.wiki.topic);
    }
  }
  // populate the forgotten Articles
  for (Article a : articlesIn) if (!filteredArticles.containsKey(a)) forgottenArticles.add(a);
  for (Article a : filtered) maxArticleLinkCount = (maxArticleLinkCount > a.temp ? maxArticleLinkCount : a.temp);
  println("total articles in: " + articlesIn.size() + "   total used: " + filtered.size() + " and forgotten: " + forgottenArticles.size());


  // REDUX
  // sort the articles by closest tie to year of wikipedia somehow
  // use article variable temp2 for this score
  for (Article a : filtered) {
    // do this by taking the average year of each link for this article
    float avg = 0f;
    for (Object obj : a.objs) {
      KeywordLink kl = (KeywordLink)obj;
      avg += kl.wiki.year;
    }
    avg /= a.objs.size();
    //println("average year is: " + avg);
    a.temp2 = avg;
  }
  filtered = OCRUtils.sortObjectArrayListSimple(filtered, "temp2");


  // sort the wikis by number of links
  for (Wikipedia w : wikisIn) {
    w.temp = w.links.size();
    maxWikiLinkCount = (maxWikiLinkCount > w.links.size() ? maxWikiLinkCount : w.links.size());
    maxWikiYear = (maxWikiYear > w.year ? maxWikiYear : w.year);
    minWikiYear = (minWikiYear < w.year ? minWikiYear : w.year);
  }
  wikisIn = OCRUtils.sortObjectArrayListSimple(wikisIn, "temp");
  wikisIn = OCRUtils.reverseArrayList(wikisIn);
  for (int i = 0; i < wikisIn.size (); i++) {
    println("WIKI: " + wikisIn.get(i).topic + " count: " + wikisIn.get(i).temp + ", " + wikisIn.get(i).links.size());
  }
  println("____");


  /*
  // sort both from center??  sure, why not.  Most populous will be in the center of the pack and least popular will be at edges
   ArrayList<Wikipedia> centerWiki = new ArrayList();
   int count = 0;
   for (int i = 0; i < wikisIn.size (); i++) {
   if (count % 2 == 0 || i == 0) centerWiki.add(wikisIn.get(i));
   else centerWiki.add(0, wikisIn.get(i));
   count++;
   }
   wikisIn = centerWiki;
   for (int i = 0; i < wikisIn.size (); i++) {
   println("WIKI: " + wikisIn.get(i).topic + " count: " + wikisIn.get(i).temp + ", " + wikisIn.get(i).links.size());
   }
   count = 0;
   ArrayList<Article> centerArticles = new ArrayList();
   for (int i = 0; i < filtered.size (); i++) {
   if (count % 2 == 0 || i == 0) centerArticles.add(filtered.get(i));
   else centerArticles.add(0, filtered.get(i));
   count++;
   }
   filtered = centerArticles;
   */

  // sort wikis by year
  wikisIn = OCRUtils.sortObjectArrayListSimple(wikisIn, "year");

  println("maxes: maxArticleLinkCount: " + maxArticleLinkCount + " maxWikiLinkCount: " + maxWikiLinkCount);

  println("wiki year range: " + minWikiYear + " to " + maxWikiYear);


  // actually draw the links
  // strength of the bez based on maxLinkCounts
  HashMap<Article, PVector> articlePositions = new HashMap(); // on TOP
  HashMap<Wikipedia, PVector> wikiPositions = new HashMap(); // on BOTTOM
  HashMap<Wikipedia, Integer> wikiColors = new HashMap(); // simple color gradient


  // make colors
  pushStyle();
  colorMode(HSB, 360);
  //for (int i = 0; i < wikisIn.size (); i++) wikiColors.put(wikisIn.get(i), color(map(i, 0, wikisIn.size() - 1, 0, 200), 360, 180));
  for (int i = 0; i < wikisIn.size (); i++) wikiColors.put(wikisIn.get(i), color(map(wikisIn.get(i).links.size(), 0, maxWikiLinkCount, 200, 0), 360, 180));
  popStyle();


  float textHeight = 16f;
  float textSize = textHeight - 4;
  float spineHeight = 800f;
  float bezMin = .5; // how far to stretch control point, min
  float bezMax = 2.25; // how far to stretch control point, max
  PGraphics pg = createGraphics(33000, 3000);
  float yCenter = 13 * pg.height / 20;
  float lineAlpha = 3f;
  pg.beginDraw();
  pg.background(255);
  pg.textFont(createFont("Helvetica", textSize));
  // draw text and figure positions of each thing
  // first articles
  //float x = 0f;
  float x = pg.width / 2 - (filtered.size() * textHeight / 2);

  pg.textAlign(LEFT, CENTER);
  pg.fill(0);
  for (int i = 0; i < filtered.size (); i++) {
    // figure new y
    float yMin = yCenter - spineHeight / 2;
    float yMax = 340;
    float y = map(filtered.get(i).temp2, minWikiYear, maxWikiYear, yMin, yMax);
    PVector pos = new PVector(x, y);

    /*
    if (i > 0) {
     if (i % 2 == 0) {
     pos.x -= x;
     } else {
     pos.x += x;
     }
     }
     if (i >= 0 && i % 2 == 0) {
     x += textHeight;
     }
     */
    x+= textHeight;
    pg.pushMatrix();
    pg.translate(pos.x, pos.y);
    //pg.rotate(-QUARTER_PI);
    pg.rotate(-HALF_PI);
    pg.text(filtered.get(i).title, 0f, 0f);
    pg.popMatrix();
    articlePositions.put(filtered.get(i), pos);
  }
  // then wikis
  //x = 0f;
  float wikiXSpacing = 100; // spacing between wikipedia listings
  x = pg.width /2 - (wikisIn.size() * wikiXSpacing / 2);
  pg.textAlign(RIGHT, CENTER);
  pg.fill(0);
  for (int i = 0; i < wikisIn.size (); i++) {

    float yMin = yCenter + spineHeight / 2;
    float yMax = pg.height - 140;
    float y = map(wikisIn.get(i).year, minWikiYear, maxWikiYear, yMax, yMin);


    PVector pos = new PVector(x, y);

    x += wikiXSpacing;
    /*
    if (i > 0) {
     if (i % 2 == 0) {
     pos.x -= x;
     } else {
     pos.x += x;
     }
     }
     if (i >= 0 && i % 2 == 0) {
     //x += textHeight;
     x += wikiXSpacing;
     }
     */

    pg.pushMatrix();
    pg.translate(pos.x, pos.y);
    pg.rotate(-QUARTER_PI);
    pg.text(wikisIn.get(i).topic, 0f, 0f);
    pg.popMatrix();
    wikiPositions.put(wikisIn.get(i), pos);
  }

  // now that all the positions are figured out draw the beziers
  pg.noFill();
  pg.strokeWeight(1);
  float angleSkewWiki = QUARTER_PI; // just for fun I guess, makes the control points angled
  float angleSkewArticle = HALF_PI;
  for (Wikipedia w : wikisIn) {
    for (KeywordLink l : w.links) {
      Article aParent = l.article;
      Wikipedia wParent = l.wiki;

      // make stroke
      pg.stroke((Integer)wikiColors.get(wParent), lineAlpha);


      // figure the strength of each
      float aStrength = map(aParent.temp, 0, maxArticleLinkCount, bezMin, bezMax);
      float wStrength = map(wParent.links.size(), 0, maxWikiLinkCount, bezMin, bezMax);
      PVector aPos = (PVector)articlePositions.get(aParent);
      PVector wPos = (PVector)wikiPositions.get(wParent);

      PVector aControl = aPos.get();
      PVector wControl = wPos.get();
      float aDist = aStrength * spineHeight / 2;
      float wDist = wStrength * spineHeight / 2;
      aControl.x -= cos(angleSkewArticle) * aDist;
      aControl.y += sin(angleSkewArticle) * aDist;
      wControl.x += cos(angleSkewWiki) * wDist; 
      wControl.y -= sin(angleSkewWiki) * wDist;

      //pg.line(aPos.x, aPos.y, wPos.x, wPos.y);
      //pg.line(wControl.x, wControl.y, wPos.x, wPos.y);
      //pg.line(aControl.x, aControl.y, aPos.x, aPos.y);
      pg.bezier(aPos.x, aPos.y, aControl.x, aControl.y, wControl.x, wControl.y, wPos.x, wPos.y);
    }
  }


  pg.endDraw();
  pg.save("output/keywords/" + OCRUtils.getTimeStampWithDate() + ".jpg");
  println("done saving viewKeywords");
} // end viewKeywords


//
//
//
//
//
//

