//


//
public void findEinstein(String phrase, boolean doOutput) {
  println("in findEinstein for " + articles.size() + " articles and phrase " + phrase);
  PrintWriter output = null;
  if (doOutput) output = createWriter("x_findEinstein/" + nf(articles.size(), 5) + "-" + phrase.replace("'", "-") + ".txt");

  int einsteinCount = 0;
  int articleCount = 0;

  ArrayList<Article> collected = new ArrayList();

  for (Article a : articles) {
    String[] mentions = new String[0];
    for (String s : a.abstractSentences) {
      if (s.toLowerCase().contains(phrase)) mentions = (String[])append(mentions, s);
    }
    if (mentions.length > 0) {
      if (doOutput) output.println("\n\narticle: " + a.title + "\nid: " + a.id);
      for (String s : mentions) {
        if (doOutput) output.println("   " + s);
      }
      einsteinCount += mentions.length;
      articleCount++;
      collected.add(a);
    }
  }

  println("total articles mentioning the phrase: " + phrase + " : " + articleCount);
  if (doOutput) output.println("\ntotal articles mentioning the phrase: " + phrase + " : " + articleCount);
  println("total sentences with the phrase: " + phrase + " -- " + einsteinCount);
  if (doOutput) output.println("\ntotal sentences with the phrase: " + einsteinCount);

  if (doOutput) output.flush();
  if (doOutput) output.close();


  // save the xml list of these articles
  XML xml = new XML(phrase.replace("'", "-").replace(" ", "-"));
  for (Article a : collected) xml.addChild(a.xml);
  saveXML(xml, "x_findEinstein/" + nf(articleCount, 5) + "-" + phrase.replace("'", "-") + ".xml");
} // end findEinstein


//
public class StringHelper {
  String s = "";
  int len = 0;
  StringHelper(String s) {
    this.s = s;
    this.len = (RiTa.tokenize(s)).length;
  } // end constructor
} // end class StringHelper

//
//
//
//
//

