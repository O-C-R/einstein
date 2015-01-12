ArrayList<Citation> citations = new ArrayList();


void setup() {
  size(1000,1000,P3D);
  smooth(4);
  loadCitations("popcites.csv");
}

void draw() {
  background(255);
  noStroke();
  fill(255,0,0,30);
  for (Citation c:citations) {
   float x = map(c.year, 1900, 2014, 100, width - 100);
   float y = height/2 + map(c.rank, 1, 1000, -400, 0);
   float s = sqrt(c.citeCount); 
   ellipse(x,y,s,s);
  }
}

void loadCitations(String url) {
  Table t = loadTable(url, "header");
  for (TableRow r:t.rows()) {
    Citation c= new Citation().fromRow(r);
    if (c.authors.indexOf("A Einstein") != -1 && c.citeCount > 100) {
     citations.add(c); 
    }
  }
}
