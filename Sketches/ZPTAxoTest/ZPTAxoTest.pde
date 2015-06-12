import simpleTween.*;
import ocrUtils.maths.*;
import ocrUtils.*;
import ocrUtils.ocr3D.*;
import java.util.Map;
import java.util.Arrays;
import java.util.Calendar;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.TimeUnit;



// temp zpt stuff
ZoomPanTilt zpt;
PVector mouseLoc = new PVector();
PVector worldLoc = new PVector();

ArrayList<PVector> starts = new ArrayList();
ArrayList<ArrayList<PVector>> pts = new ArrayList();
float extents = 200f;
float zStart = -300f;
float zVariation = 50f;
ArrayList<PVector> targets = new ArrayList();

float rotAngle = 0;
float zAngle = PI/8;



//
void setup() {
  long startTime = millis();
  size(1200, 800, P3D);
  OCRUtils.begin(this);
  SimpleTween.begin(this);
  zpt = new ZoomPanTilt(this);
  randomSeed(1862);

  for (int i = 0; i < 60; i++) {
    float thisZ = zStart + random(zVariation * 2);
    float x = random(-extents, extents);
    float y = random(-extents, extents);
    PVector pt = new PVector(x, y, thisZ);
    targets.add(pt);
  }

  for (int i = 0; i < 2700; i++) {
    ArrayList<PVector> lps = new ArrayList();
    float x = random(-extents, extents);
    float y = random(-extents, extents);
    float z = zVariation * noise(.05 * x, .05 * y);
    PVector start = new PVector(x, y, z);
    starts.add(start);
    //PVector target = targets.get((int)random(targets.size()));
    // pick targets that are closest
    ArrayList<PVector> targetOptions = new ArrayList();
    ArrayList<Float> targetDists = new ArrayList();
    for (int j = 0; j < targets.size (); j++) {
      boolean foundSpot = false;
      float thisDist = sqrt((x - targets.get(j).x) * (x - targets.get(j).x) + (y - targets.get(j).y) * (y - targets.get(j).y));
      for (int k = 0; k < targetDists.size (); k++) {
        if (thisDist < targetDists.get(k)) {
          targetDists.add(k, thisDist);
          targetOptions.add(k, targets.get(j));
          foundSpot = true;
          break;
        }
      }
      if (!foundSpot) {
        targetDists.add(thisDist);
        targetOptions.add(targets.get(j));
      }
    }




    int toMake = (int)random(1, 8);
    for (int j = 0; j < toMake; j++) {
      PVector target = targetOptions.get(j);
      if (random(1) < .4) target = targetOptions.get(toMake + (int)random(targetOptions.size() - 1 - toMake));
      PVector startA = start.get();
      startA.z -= random(.5, .6) * (start.z - target.z);
      PVector targetA = target.get();
      targetA.z += random(.5, .6) * (start.z - target.z);
      lps.add(start);
      lps.add(startA);
      lps.add(targetA);
      lps.add(target);
      pts.add(lps);
    }
  }
} // end setup


// 
void draw() {
  background(0);  
  zpt.use();
  
  
  
  // this is the key to ortho
  // this is the key to ortho
  // this is the key to ortho
  // this is the key to ortho
  ortho(0, width, 0, height, -1300, 1300);
  
  if (keyPressed && keyCode == SHIFT) {
    rotAngle += PI * (float)(pmouseY - mouseY) / height;
    rotAngle = constrain(rotAngle, 0, HALF_PI);
    zAngle += PI * (float)(pmouseX - mouseX) / width;
  }
  
  rotateX(rotAngle); // angles it to the side
  rotateZ(zAngle); // rotates it
  // this is the key to ortho
  // this is the key to ortho
  // this is the key to ortho
  // this is the key to ortho
  
  
  
  
  
  mouseLoc.set(mouseX, mouseY);
  worldLoc = zpt.getWorldCoordFromPoint(mouseLoc);

  OCR3D.drawGrid(extents, 20, color(255));
  //OCR3D.drawOrigin();
  fill(0, 5);
  noFill();
  stroke(255, 50);
  rect(-extents, -extents, 2 * extents, 2 * extents);

  // draw curves
  noFill();
  strokeWeight(.5);
  stroke(250, 255, 0,4);
  for (ArrayList<PVector> pps : pts) {
    beginShape();
    curveVertex(pps.get(0).x, pps.get(0).y, pps.get(0).z + 20 + 2.5 * abs(pps.get(1).z - pps.get(0).z));
    curveVertex(pps.get(0).x, pps.get(0).y, pps.get(0).z);
    //curveVertex(pps.get(1).x, pps.get(1).y, pps.get(1).z);
    //curveVertex(pps.get(2).x, pps.get(2).y, pps.get(2).z);
    curveVertex(pps.get(3).x, pps.get(3).y, pps.get(3).z);
    curveVertex(pps.get(3).x, pps.get(3).y, pps.get(3).z - 2.5 * abs(pps.get(3).z - pps.get(2).z));
    endShape();
  }

  // draw circles
  fill(0, 127, 255, 127);
  for (PVector p : starts) {
    stroke(map(p.z, 0, zVariation, 127, 0));
    pushMatrix();
    translate(p.x, p.y, p.z);
    ellipse(0, 0, 10, 10);
    popMatrix();
  }

  zpt.pause();
  fill(255);
  textAlign(LEFT, TOP);
  text(degrees(rotAngle), 20, 20);
} // end draw

