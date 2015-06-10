String fileName = "/Users/noa/github/OCR/einstein/DATA/ArxivFiles/gr-qc-2014/citations.json";
//String fileName = "/Users/noa/github/OCR/einstein/DATA/ArxivFiles/gr-qc-2014/references.json";
String type = "citations";

JSONObject json = loadJSONObject(fileName);

println(json.keys().size());

int count = 0;
IntDict id = new IntDict();
for (Object key : json.keys ()) {
  JSONArray jj = json.getJSONArray((String)key); 
  if (jj.size() > 0) {
    println(jj.size());
    String sz = "" + nf(jj.size(), 3);
    if (!id.hasKey(sz)) id.set(sz, 0);
    id.increment(sz);
    count++;
  }
}
PrintWriter output = createWriter("output.txt");
output.println("total dataset: " + json.keys().size());
output.println("total with at least one  " + type + ": " + count);
id.sortValuesReverse();
output.println("\n\n\n\nnumber of " + type + " by popularity"); 
for (String key : id.keys ()) output.println(key + " -- " + id.get(key));
id.sortKeys();
output.println("\n\n\n\nnumber of " + type + " by count ascending"); 
for (String key : id.keys ()) output.println(key + " -- " + id.get(key));
output.flush();
output.close();

