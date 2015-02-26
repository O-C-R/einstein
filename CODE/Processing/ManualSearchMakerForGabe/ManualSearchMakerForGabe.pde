String[] clusterIds = {
  "6260380372219921579", 
  "8066420215978626200", 
  "426412038412359390", 
  "10181864712941716750"
};

String[] clusterNames = {
  "Relativity: The special and general theory", 
  "Die feldgleichungen der gravitation", 
  "Zur allgemeinen Relativitätstheorie", 
  "The Foundation of the Generalised Theory of Relativity",
};

// base query:
// python scholar.py --cites -C 6260380372219921579 --start 0 --after 1940 --before 1950 >> 6260380372219921579_1940-1950_1.json

//
void setup() {
  OCRUtils.begin(this);

  int pagesToDo = 2;
  int startingYear = 1900;
  int yearAddition = 10; // howmany
  int endingYear = 2015; 

  // more static things
  int countPerPage = 10;


  PrintWriter output = createWriter("output/lookupList-" + OCRUtils.getTimeStampWithDate() + ".txt");
  for (int clusterIndex = 0; clusterIndex < clusterIds.length; clusterIndex++) {
    String clusterId = clusterIds[clusterIndex];
    String clusterName = clusterNames[clusterIndex];
    int currentStartYear = startingYear;

    output.println("******** -- " + clusterName + " -- " + clusterId + " -- *********");
    while (currentStartYear < endingYear) {
      int currentEndYear = currentStartYear + yearAddition;
      output.println("_");
      for (int pageNumber = 0; pageNumber < pagesToDo; pageNumber++) {
        int startIndex = pageNumber * countPerPage;
        output.println("python scholar.py --cites -C " + clusterId + " --start " + startIndex + " --after " + 
          currentStartYear + " --before " + currentEndYear + " --json >> " + clusterId + "_" + currentStartYear + "-" + 
          currentEndYear + "_" + (pageNumber + 1) + ".json");
      }

      currentStartYear = currentEndYear;
    }
    
    output.println("_");
    output.println("_");
    output.println("_");
  }

  output.flush();
  output.close();

  exit();
} // end setup

