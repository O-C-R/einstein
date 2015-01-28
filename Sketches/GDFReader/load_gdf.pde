//
void loadGDF(String fileNameIn) {
  nodes.clear();
  edges.clear();
  
  String[] allLines = loadStrings(fileNameIn);
  String[] broken = new String[0];
  String loadingWhat = "";

  // craete a temporary csv so the thing can be loaded into a table
  PrintWriter tempCSV = createWriter("tempCSV/temp.csv");
  for (String s : allLines) tempCSV.println(s);
  tempCSV.flush();
  tempCSV.close();
  Table table = loadTable(sketchPath("") + "tempCSV/temp.csv");

  for (int i = 0; i < allLines.length; i++) {
    if (allLines[i].contains("def>")) {
      broken = split(allLines[i], ">");
      loadingWhat = broken[0];
      println("line i: " + i + " loading: " + loadingWhat);
    } else {
      //broken = split(allLines[i]);
      if (loadingWhat.equals("nodedef")) {
        // get stuff via table -- col, row
        int id = table.getInt(i, 0);
        String name = table.getString(i, 1);
        float w = table.getFloat(i, 2);
        float h = table.getFloat(i, 3);
        float x = table.getFloat(i, 4);
        float y = table.getFloat(i, 5);
        String colorStringR = table.getString(i, 6).replace("'", "");
        String colorStringG = table.getString(i, 7).replace("'", "");
        String colorStringB = table.getString(i, 8).replace("'", "");
        color c = color(Integer.parseInt(colorStringR), Integer.parseInt(colorStringG), Integer.parseInt(colorStringB));
        //println("id: " + id + " name: " + name + " xy: " + x + ", " + y + " wh: " + w + ", " + h + " color: " + red(c) + ", " + green(c) + ", " + blue(c));
        nodes.put(id, new Node(id, name, new PVector(w, h), new PVector(x, y), c));
      } else if (loadingWhat.equals("edgedef")) {
        int fromId = table.getInt(i, 0);
        int toId = table.getInt(i, 1);
        float weight = table.getFloat(i, 2);
        boolean directed = table.getString(i, 3).equals("true");
        //println("from: " + fromId + " to: " + toId + " weight: " + weight + " directed: " + directed);
        edges.put(fromId + "-" + toId, new Edge((Node)nodes.get(fromId), (Node)nodes.get(toId)));
      }
    }
  }
  println("loaded " + nodes.size() + " nodes and " + edges.size() + " edges");
} // end loadGDF

//
//
//
//
//

