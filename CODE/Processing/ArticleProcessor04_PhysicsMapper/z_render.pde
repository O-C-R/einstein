


//
// this will render everything to separate pdf frames
// by setting the renderIndex to zero it will darw out one part each frame
public void renderThings() {
  println(frameCount + " in renderThings.  starting render");
  renderDirectory = "renders/" + OCRUtils.getTimeStampWithDate() + "/";
  renderIndex = 0;
} // end renderThings

//
// this will simply draw some crosses off to the side so that the imags can be lined up
public void drawRegistration(PGraphics pg) {
  float len = 20;
  ArrayList<PVector> locs = new ArrayList();
  locs.add(new PVector(-100, -100));
  locs.add(new PVector(width + 100, height + 100));
  for (PVector p : locs) {
    pg.pushMatrix();
    pg.translate(p.x, p.y);
    pg.stroke(colorRegistration);
    pg.line(-len/2, 0, len/2, 0);
    pg.line(0, -len/2, 0, len/2);
    pg.popMatrix();
  }
} // end drawRegistration

//
//
//
//
//
//
//
//
//
//




// SVG STUFF SVG STUFF
// 
// see http://tutorials.jenkov.com/svg/text-element.html
public void saveSVGText(ArrayList<SVGText> txtIn, String writeTo) {
  if (!writeTo.contains(".svg")) writeTo += ".svg";
  PrintWriter output = createWriter(writeTo);
  output.println("<svg height=\"" + height +"\" width=\""+ width + "\">");
  for (SVGText ss : txtIn) output.println(ss.getSVGOutput());
  output.println("</svg>");
  output.flush();
  output.close();
  println("wrote out svg to " + writeTo);
} // end saveSVGText

//
public class SVGText {
  String txt = "";
  PVector pos = new PVector();

  // 
  public SVGText(String txt, PVector pos) {
    this.txt = txt;
    this.pos = pos;
  } // end constructor
  //
  public void updatePos(PVector pos) {
    this.pos.set(pos.x, pos.y);
  } // end updatePos
  //
  public String getSVGOutput() {
    String builder = "";
    builder += "<text x=\"" + pos.x + "\" y=\"" + pos.y + "\" fill=\"black\">" + txt + "</text>";
    return builder;
  } //end getSVGOutput
} // end class SVGText

//
//
//
//
//
//

