float w = 3000;
float h = 1200;
float sc = 0.5;

TreeNode baseNode;
ArrayList<TreeNode> allNodes = new ArrayList();

void setup() {

  size(int(sc * w), int(sc * h), P3D);
  smooth(4);
  reset();
}

void draw() {
  background(255);
  scale(sc);
  baseNode.update();
  baseNode.render();
}

void reset() {
  allNodes = new ArrayList();
  baseNode = makeTree();
  for (TreeNode n:allNodes) {
    n.setDownstream();
  }
  baseNode.setDownstream();
  baseNode.tpos.set(50, h/2);
  baseNode.realPos.set(50, h/2);
}

TreeNode makeTree() {
  TreeNode b = new TreeNode();
  b.spawn();
  return(b);
}

void keyPressed() {
  if (key == ' ') reset();
  if (key == 's') save("EinsteinTree" + hour() + "_" + minute() + "_" + second() + ".png");
}

class TreeNode {

  ArrayList<TreeNode> children = new ArrayList();
  int depth = 0;
  float tend = 0;
  int downstream = 0;
  TreeNode parent;

  PVector pos = new PVector();
  PVector tpos = new PVector();
  PVector realPos = new PVector();

  void update() {
    pos.lerp(tpos, 0.1);
    for (TreeNode c:children) {
      c.update();
    }
  }

  void render() {
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    ellipse(0, 0, 5, 5);
    fill(0);
    //textSize(18);
    //text(downstream, 0, 0);
    //stroke(0,downstream);

    colorMode(HSB);
    for (TreeNode c:children) {
      //stroke(map(c.realPos.y, 0, height, 80, 255), 255, 255);
      //stroke(map(sqrt(c.downstream), 0, sqrt(baseNode.downstream), 80, 255), 255, 255);
      stroke(0, map(sqrt(c.downstream), 0, sqrt(baseNode.downstream), 80, 255));
      strokeWeight(map(sqrt(c.downstream), 0, sqrt(baseNode.downstream), 1, 7));
      line(0, 0, c.pos.x, c.pos.y);
      c.render();
    }
    popMatrix();
  }

  int setDownstream() {
    int c = 0;
    for (TreeNode tn:children) {
      c++;
      c += tn.setDownstream();
    }
    downstream = c;
    return(c);
  }


  void spawn() {
    children = new ArrayList();
    int count = ceil(random(5));
    boolean burst = random(100) < 5;
    float bf = burst ? 0.3:1;
    if (burst) {
      count *= random(2,8);
    }
    for (int i = 0; i < count; i++) {
      TreeNode n = new TreeNode();
      n.tend = tend + random(0.1, 0.1);
      float tf = (n.tend >= 0) ? 1 + tend: -1 - tend;

      n.depth = depth + 1;
      n.parent = this;

      children.add(n); 
      if (n.depth < 10 && (!burst || random(100) < 20)  && (random(100) < (70 - (6 * n.depth)) || n.depth < 3) ) n.spawn();
      n.tpos.set(40 + (n.children.size() * random(10, 50)) * bf * tf, random(-100, 100) * bf);
      
      n.realPos = new PVector(realPos.x, realPos.y);
      n.realPos.add(n.tpos);

      allNodes.add(n);
    }
  }
}

