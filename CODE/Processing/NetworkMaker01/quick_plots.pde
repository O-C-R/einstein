//
public void quickPlot1(PGraphics pg) {
  pg.background(255);

  int firstYear = -1;
  int lastYear = -1;
  int maxCiters = 0;
  int maxCites = 0; 
  for (Article a : allArticles) {
    if (firstYear == -1) {
      firstYear = lastYear = a.year;
    }
    firstYear = (firstYear < a.year ? firstYear : a.year);
    lastYear = (lastYear > a.year ? lastYear : a.year);
    //maxCiters = (maxCiters > a.citers.size() ? maxCiters : a.citers.size()); // by stored citer count
    maxCiters = (maxCiters > a.citations ? maxCiters : a.citations); // by recorded citation count
    maxCites = (maxCites > a.cites.size() ? maxCites : a.cites.size()); // by number that this cites
  }
  println("year range: " + firstYear + " -- " + lastYear);
  println("maxCiters: " + maxCiters);
  println("maxCites: " + maxCites);
  
  
  // override
  //firstYear = 1985;

  // do some positioning
  float sidePadding = 30f;
  float topPadding = 30f;

  for (Article a : allArticles) {
    // left to right
    a.pos.x = map(a.year, firstYear, lastYear, sidePadding, width - sidePadding);
    a.pos.x += random(-8, 8);
    a.pos.y = random(topPadding, height - topPadding);
    // top to bottom
    //a.pos.y = map(a.year, firstYear, lastYear, topPadding, height - topPadding);
    //a.pos.x = random(sidePadding, width - sidePadding);
  }

  // plot lines
  
  for (Article a : allArticles) {
    for (Map.Entry me : a.citers.entrySet()) {
      //pg.stroke(0, map(sqrt(a.cites.size()), 0, sqrt(maxCites), 30, 155));
      pg.stroke(0, 50);
      Article child = (Article)me.getValue();
      pg.line(child.pos.x, child.pos.y, a.pos.x, a.pos.y);
    }
  }

  //plot dots
  pg.noStroke();
  for (Article a : allArticles) {
    //pg.fill(0, map(a.citers.size(), 0, maxCiters, 50, 255));
    float citeColorMap = map(a.cites.size(), 0, maxCites, 0, 255);
    if (a.citers.size() > 0 && a.cites.size() > 0) pg.fill(255 - citeColorMap, citeColorMap, 100, map(a.citations, 0, maxCiters, 150, 255));
    else pg.fill(0, map(a.citations, 0, maxCiters, 50, 255));
    //float sz = map(a.citers.size(), 0, maxCiters, 8, 8);
    float sz = map(sqrt(a.citations), 0, sqrt(maxCiters), 4, 30);
    pg.pushMatrix();
    pg.translate(a.pos.x, a.pos.y);
    pg.ellipse(0, 0, sz, sz);
    pg.popMatrix();
  }
} // end quickPlot1

//
//
//
//

