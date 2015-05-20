import java.util.Map;

String mainDirectory = "../ManualSearchMakerForGabeExtraGenerations/Generations/1/";
ArrayList<Article> allArticles = new ArrayList();

//
void setup() {
  size(1300, 700);
  
  allArticles = loadAllArticles(sketchPath("") + mainDirectory);
  
  //for (Article a : allArticles) println(a.toSimplifiedString());
  
  //quickPlot1(g);
  //outputGephiFiles();
  
  exit();
} // end setup
