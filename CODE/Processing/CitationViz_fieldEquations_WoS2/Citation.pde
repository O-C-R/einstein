//Publication Type,Authors,Document Title,Publication Name,Document Type,Abstract,Cited References,Cited Reference Count,Web of Science Times Cited Count,"Total Times Cited Count (WoS, BCI, CSCD)",Publication Date,Year Published,Page Count,WoS Category,Subject Area
//Journal,"Born, M",Recapitulating treatments. Einstein's theory of gravitation and general relativity.,PHYSIKALISCHE ZEITSCHRIFT,Article,,"EINSTEIN A, 1914, SITZUNGSBER KGL PREU, V46, P778; Einstein A, 1915, SITZBER K PREUSS AKA, P831; Einstein A, 1914, SITZBER K PREUSS AKA, P1030; Einstein A, 1911, ANN PHYS-BERLIN, V35, P898; EINSTEIN A, 1913, VIERTELJAHRSSCHRIFT, V58; EINSTEIN A, 1914, Z MATH PHYS, V63, P215; Einstein A, 1915, SITZBER K PREUSS AKA, P844; EINSTEIN Albert, 1913, Z MATH PHYS, V62, P225",8,2,2,,1916,9,"Physics, Multidisciplinary",Physics
class Citation {
  
  int citeCount;
  String authors;
  String title;
  String source;
  String[] citedRefs;
  ArrayList<String> sharedRefs = new ArrayList();
  int wosCount;
  int year;
  
  Circle circle;
  ArrayList <Line> lines;
  
  Citation() {
    lines = new ArrayList();
  }
  
  Citation fromRow(TableRow r) {
    citeCount = r.getInt("Cited Reference Count");
    authors = r.getString("Authors");
    title = r.getString("Document Title");
    String tempRefs = r.getString("Cited References");
    citedRefs = split(tempRefs, ';');
    year = r.getInt("Year Published");
    wosCount = r.getInt("Web of Science Times Cited Count");
    makeCircle(year, wosCount, citeCount);
    return(this);
  }
  
  void makeCircle(int _year, int _wosCount, int _citeCount) {
   float x = map(_year, 1905, 2014, -100, width - 100);
   float y = height/2 + map(_citeCount, 1, 800, -400, 200); //not using wosCount, another int to use?
   float s = _citeCount * 0.25; 
   
   circle = new Circle(x,y,s);
  }
  
  void makeLine(float _x1, float _y1, float _x2, float _y2) {
    Line l = new Line(_x1, _y1, _x2, _y2);
    lines.add(l);
  }
  
  void drawLine() {
    for(int i = 0; i < lines.size(); i++) {
      Line l = lines.get(i);
      l.display();
    }
  }
  
  void addSharedRef(String s) {
    sharedRefs.add(s);
  }

}
