//Cites,Authors,Title,Year,Source,Publisher,ArticleURL,CitesURL,GSRank,QueryDate,Type
//12774,"A Einstein, B Podolsky, N Rosen","Can quantum-mechanical description of physical reality be considered complete?",1935,"Physical review","APS","http://journals.aps.org/pr/abstract/10.1103/PhysRev.47.777","http://scholar.google.com/scholar?cites=8174092782678430881&as_sdt=5,33&sciodt=0,33&hl=en&num=20",1,"2014-11-20",""


class Citation {
  
  int citeCount;
  String authors;
  String title;
  String source;
  int rank;
  int year;
  
  Circle circle;
  
  Citation() {

  }
  
  Citation fromRow(TableRow r) {
    citeCount = r.getInt("Cites");
    authors = r.getString("Authors");
    title = r.getString("Title");
    year = r.getInt("Year");
    rank = r.getInt("GSRank");
    makeCircle(year, rank, citeCount);
    return(this);
  }
  
  void makeCircle(int _year, int _rank, int _citeCount) {
   float x = map(_year, 1900, 2014, -100, width - 100);
   float y = height/2 + map(_rank, 1, 1000, -400, 200);
   float s = sqrt(_citeCount); 
   circle = new Circle(x,y,s);
  }
}
