//
class Term {
  int id = 0;
  String term = "";

  // for visualizing the articles that are connected to this Term
  Article[] articles = new Article[0]; // the articles connected to this term
  float[] articleCounts = new float[0];


  //
  Term (int id, String term) {
    this.id = id;
    this.term = term;
  } // end constructor


  //
  public String toString() {
    String builder = "Term: " + id + " -- " + term;
    return builder;
  } // end toString
} // end class Term

//
//
//
//
//

