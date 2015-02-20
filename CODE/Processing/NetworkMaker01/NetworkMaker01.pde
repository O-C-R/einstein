import java.util.Map;

String mainDirectory = "../../Python/scholar.py_sikoried.py/";
ArrayList<Article> allArticles = new ArrayList();

//
void setup() {
  size(1300, 700);
  
  allArticles = loadAllArticles(sketchPath("") + mainDirectory);
  
  for (Article a : allArticles) println(a.toSimplifiedString());
  
  quickPlot1(g);
  outputGephiFiles();
} // end setup
