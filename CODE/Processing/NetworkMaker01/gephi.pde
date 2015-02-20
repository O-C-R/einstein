//
void outputGephiFiles() {
  // master file
  PrintWriter output = createWriter("gephi/nodes.csv");
  output.println("clusterId,year,citations,versions,title");
  for (Article a : allArticles) {
    output.println(a.clusterId+ "," +a.year+","+a.citations+","+a.versions+","+a.title);
  }
  output.flush();
  output.close();

  // link file
  output = createWriter("gephi/links.csv");
  output.println("source,target");
  for (Article a : allArticles) {
    for (Map.Entry me : a.citers.entrySet()) {
      output.println(a.clusterId+ "," + ((Article)me.getValue()).clusterId);
    }
  }
  output.flush();
  output.close();
} // end outputGephiFiles

