ArrayList<Citation> citations = new ArrayList();
Citation currentCitation;
Circle overlayCircle;
boolean globalRollover;
float closestDistance;

void setup() {
  size(1400,900,P3D);
  smooth(4);
  loadCitations("FieldEquations.csv");
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


