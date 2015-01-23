ArrayList<Citation> citations = new ArrayList();


void setup() {
  size(1400,900,P3D);
  smooth(4);
  loadCitations("FieldEquations.csv");
}

void draw() {
  background(255);

  for (Citation c:citations) {
   float x = map(c.year, 1900, 2014, -100, width - 100);
   float y = height/2 + map(c.rank, 1, 1000, -400, 200);
   float s = sqrt(c.citeCount); 
   Circle circ = new Circle(x,y,s);
   circ.rollover(mouseX, mouseY, s);
   circ.display();
   
   if(circ.rollover) {
     text(c.authors, 100, 700);
     text(c.title, 100, 720);
     text(c.year, 100, 740);
     text("Rank: "+ c.rank, 100, 760);
     text("Citations: "+ c.citeCount, 100, 780);
   }
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


