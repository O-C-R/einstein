ArrayList<Citation> citations = new ArrayList();
ArrayList<Line> sameAuthorLines = new ArrayList();
ArrayList<Line> authorInCommonLines = new ArrayList();
Citation currentCitation;
Circle overlayCircle;
boolean globalRollover;
float closestDistance;
boolean showSameAuthorLines = false;
boolean showCommonAuthorLines = false;

void setup() {
  size(1400,900,P3D);
  smooth(4);
  loadCitations("FieldEquations.csv");
  
  for(int i=0; i < citations.size(); i++) {
    for(int j=0; j < citations.size(); j++) {
      String author1 = citations.get(i).authors;
      String author2 = citations.get(j).authors;
      if (author1.equals(author2)) {
        println(author1);
        float x1 = citations.get(i).circle.x;
        float y1= citations.get(i).circle.y;
        float x2 = citations.get(j).circle.x;
        float y2= citations.get(j).circle.y;
        Line l2 = new Line(x1,y1,x2,y2);
        sameAuthorLines.add(l2);
      } else if (author2.indexOf(author1) != -1) {
        println(author1);
        float x1 = citations.get(i).circle.x;
        float y1= citations.get(i).circle.y;
        float x2 = citations.get(j).circle.x;
        float y2= citations.get(j).circle.y;
        Line l = new Line(x1,y1,x2,y2);
        authorInCommonLines.add(l);
        //println("x1: "+ x1 + ", y1: "+ y1 +", x2: "+ x2 + ", y2: "+ y2);
      }
    }
  }
  
  println("amount of same authors: " + sameAuthorLines.size());
  println("amount of common authors: " + authorInCommonLines.size());
  
}

void draw() {
  globalRollover = false;
  background(255);

  for (Citation c:citations) {
    
   c.circle.display(false);
   c.circle.rollover(mouseX, mouseY, c.circle.diam);
   
   if(c.circle.rollover) {
     closestDistance = 100;
     //if this is the closest one set it to currentCitation
     float distance = c.circle.distanceToCenter(mouseX, mouseY);
     if (distance < closestDistance) {
       closestDistance = distance;
       println(closestDistance);
       currentCitation = c;
       overlayCircle = c.circle;
       globalRollover = true;
       //c.circle.display(true);
     }  
    }
  }
  //Press 'A' to see articles written by same authors
  if(showSameAuthorLines) {
    for(Line line:sameAuthorLines) {
      stroke(0,0,0, 50);
      line.display();
    }
  }
  
  if(showCommonAuthorLines) {
    for(Line l:authorInCommonLines) {
      stroke(255,0,0,80);
      l.display();
    }
  }

  if(globalRollover){
     overlayCircle.display(true);
     fill(0, 100);
     text(currentCitation.authors, 100, 700);
     text(currentCitation.title, 100, 720);
     text(currentCitation.year, 100, 740);
     text("Rank: "+ currentCitation.rank, 100, 760);
     text("Citations: "+ currentCitation.citeCount, 100, 780); 
  
  }
  
}

void keyPressed() {
  if(key == 'a' || key == 'A') {
    showSameAuthorLines = !showSameAuthorLines;
  }
  
  if(key == 's' || key == 'S') {
    showCommonAuthorLines = !showCommonAuthorLines;
    println(showCommonAuthorLines);
  }
}

void loadCitations(String url) {
  Table t = loadTable(url, "header");
  for (TableRow r:t.rows()) {
    Citation c= new Citation().fromRow(r);
    if (c.citeCount > 200) { //removed Einstein to compare other authors
     citations.add(c); 
     println("added citation");
    }
  }
}


