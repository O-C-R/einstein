
//
public ArrayList<JSONObject> makeJSONObjects(String jsonStringIn) {
  if (jsonStringIn == null || jsonStringIn.length() == 0) return null;
  ArrayList<JSONObject> newObjs = new ArrayList();
  String[] answers = split(jsonStringIn, "}{");
  for (String s : answers) {
    if (s.charAt(0) != '{') s = "{" + s;
    if (s.charAt(s.length() -1 ) != '}') s += '}';

    try { 
      JSONObject json = JSONObject.parse(s);
      //println(json);
      newObjs.add(json);
    }
    catch (Exception e) {
      println("problem making json object for string: " + s);
    }
  }
  return newObjs;
} // end makeJSONObjects


//
//
//
//
//

