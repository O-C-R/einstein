//Cites,Authors,Title,Year,Source,Publisher,ArticleURL,CitesURL,GSRank,QueryDate,Type
//12774,"A Einstein, B Podolsky, N Rosen","Can quantum-mechanical description of physical reality be considered complete?",1935,"Physical review","APS","http://journals.aps.org/pr/abstract/10.1103/PhysRev.47.777","http://scholar.google.com/scholar?cites=8174092782678430881&as_sdt=5,33&sciodt=0,33&hl=en&num=20",1,"2014-11-20",""


class Citation {
  
  int citeCount;
  String authors;
  String title;
  String source;
  int rank;
  int year;
  
  Citation() {
    
  }
  
  Citation fromRow(TableRow r) {
    citeCount = r.getInt("Cites");
    authors = r.getString("Authors");
    title = r.getString("Title");
    year = r.getInt("Year");
    rank = r.getInt("GSRank");
    return(this);
  }
  
  
}
