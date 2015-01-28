//
class Node {
  int id = 0;
  String name = "";
  PVector dims = new PVector();
  PVector pos = new PVector();
  color c = color(255);
  
  ArrayList<Edge> edgesOut = new ArrayList(); // edges originating from this node
  ArrayList<Edge> edgesIn = new ArrayList(); // edges coming into this node
  
  //
  Node(int id, String name, PVector dims, PVector pos, color c) {
    this.id = id;
    this.name = name;
    this.dims = dims;
    this.pos = pos;
    this.c = c;
  } // end constructor
  
  //
  void addEdge(Edge e) {
    if (e.from == this) edgesOut.add(e);
    else if (e.to == this) edgesIn.add(e);
  } // end addEdge
} // end class Ndoe




//
class Edge {
  Node from = null;
  Node to = null;
  float dist = 0f; // simply distance from Node 'from' to Node 'to'
  
  //
  Edge (Node from, Node to) {
    this.from = from;
    this.to = to;
    this.dist = this.to.pos.dist(this.from.pos);
    // assign to parent Node
    this.from.addEdge(this);
    this.to.addEdge(this);
  } // end constructor
} // end class Edge

//
//
//
//
//
//

