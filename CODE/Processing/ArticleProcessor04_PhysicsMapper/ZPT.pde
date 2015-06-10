// to do: 
// use eye and target instead of offset and z and rotx and rotz
// pan by plane
//
class ZoomPanTilt {
  final int ZOOM_OUT = 4;
  final int ZOOM_IN = 5;

  String name = "";

  PApplet parent = null;

  // global scale and offset
  PVector zoomTarget = new PVector();
  float zoomTracker = 0f;
  float zoomTrackerFriction = .7;
  float zoomTrackerMax = .3;
  float zoomTrackerIncrement = .03;
  PVector currentWorldLoc = new PVector();
  float durationQuick = 23f;
  float durationSlow = 300f;
  FSTween sc = new FSTween(durationQuick, 0, 1f, 1f); 
  PVSTween offset = new PVSTween(durationQuick, 0, new PVector(), new PVector()); // note that this is essentially the target point point

  PVector eye = new PVector();
  PVector target = new PVector();

  float minZ = -100000f; // the limits to the offset.z
  float maxZ = 100000f; 
  boolean zRangeSet = false;

  // tilt variables
  boolean ignoreRotX = false;
  FSTween rotX = new FSTween(durationQuick, 0f, 0f, 0f);
  float minRotateX = -PI;//(float)Math.PI / 2f;
  float maxRotateX = PI;//(float)Math.PI / 2f;
  boolean rotateRangeXSet = false;
  boolean orbitingWorld = false; // whether or not the user is rotating the world

  // rotate vars -- to do
  boolean ignoreRotZ = false;
  FSTween rotZ = new FSTween(durationQuick, 0f, 0f, 0f);
  float minRotateZ = -PI;
  float maxRotateZ = PI;
  boolean rotateRangeZSet = false;

  // view variables
  private float aspect = 0f;
  private float fov = (float)Math.PI / 3f; // 60 degree view of vertical default
  private float dist100 = 0f; // the distance from the 'eye' to the view plane at a scale of 1

  PVector screenDims = new PVector();

  // dragging vars
  boolean draggingWorld = false; // keep track of when the last time there was a drag
  PVector dragStart = new PVector(); // keep track of where the mouse first started dragging on the screen
  PVector dragWorldOffsetStart = new PVector(); // keep track of where the original offset was
  PVector draggingBoundsLower = null; // if setting bounds for the dragging area so that the user won't click somewhere crazy far away
  PVector draggingBoundsUpper = null;
  float dragginZAmt = 2f; // when manually going up and down this will be the increment



  int matrixCounter = 0;

  // debug vars
  boolean printStats = false;
  boolean printStats2 = false;

  //
  ZoomPanTilt(PApplet parent) {
    this.parent = parent;
    dist100 = ((float)parent.height / 2) / ((float)Math.tan(fov / 2));
    //screenDims = new PVector(width, height);
    //init();
  } // end constructor

  /*
  //
   ZoomPanTilt(PApplet parent, PVector screenDims) {
   this.parent = parent;
   this.screenDims = screenDims;
   init();
   } // end constructor
   */

  /*
  //
   private void init() {
   dist100 = ((float)screenDims.y / 2) / ((float)Math.tan(fov / 2));
   } // end init
   */

  //
  void setDraggingBounds(PVector draggingBoundsLower, PVector draggingBoundsUpper) {
    this.draggingBoundsLower = draggingBoundsLower;
    this.draggingBoundsUpper = draggingBoundsUpper;
  } // end setDraggingBounds

  //
  void setRotateXRange(float minRotateX, float maxRotateX) {
    this.minRotateX = minRotateX;
    this.maxRotateX = maxRotateX;
    rotateRangeXSet = true;
  } // end setRotateXRange

    //
  void setRotateZRange(float minRotateZ, float maxRotateZ) {
    this.minRotateZ = minRotateZ;
    this.maxRotateZ = maxRotateZ;
    rotateRangeZSet = true;
  } // end setRotateZRange

    //
  void setZRange(float minZ, float maxZ) {
    this.minZ = minZ;
    this.maxZ = -maxZ;
    zRangeSet = true;
  } // end setZRange

    //
  void use() {
    use(parent.g);
  } // end use

  // 
  void use(PGraphics pg) {
    // reset the vars based on the pg
    dist100 = ((float)parent.height / 2) / ((float)Math.tan(fov / 2));
    screenDims.set(pg.width, pg.height);

    pg.perspective(fov, screenDims.x / screenDims.y, .000001, 1000000);


    matrixCounter++;
    pg.pushMatrix();
    pg.translate(screenDims.x / 2, screenDims.y / 2);
    pg.rotateX(rotX.value());
    pg.rotateZ(rotZ.value());    
    pg.translate(offset.value().x, offset.value().y, offset.value().z);
    pg.scale(sc.value());

    //currentWorldLoc = getWorldCoordFromPoint(new PVector(mouseX, mouseY));

    if (zoomTracker != 0) {
      zoomTracker = constrain(zoomTracker, -zoomTrackerMax, zoomTrackerMax);
      zoomTracker *= zoomTrackerFriction;
      if (abs(zoomTracker) < zoomTrackerIncrement / 10) zoomTracker = 0f;
      if (zoomTracker < 0) zoomWorld(ZOOM_IN, zoomTarget.get());
      else if (zoomTracker > 0) zoomWorld(ZOOM_OUT, zoomTarget.get());
    }

    // store the eye and target
    target = offset.value().get();
    target.z *= -1;
  } // end use


  // 
  void pause() {
    pause(parent.g);
  } // end pause

  //
  void pause(PGraphics pg) {
    if (matrixCounter == 1) {
      pg.popMatrix();
      matrixCounter = 0;
    }
  } // end pause

  // for simple zooming to the center
  void zoomWorld(int whereTo) {
    zoomWorld(whereTo, new PVector(width/2, height/2));
  } // end zoomWorld

  // for zooming to a specific spot
  void zoomWorld(int whereTo, PVector screenLocation) {
    screenLocation.x -= screenDims.x / 2;
    screenLocation.y -= screenDims.y / 2;
    // fix up the zoom here to make it zoom to the right spot when angled
    float scaleAmt = .33;
    float newScale = sc.value();
    switch(whereTo) {
    case ZOOM_IN:
      newScale = sc.value() * (1 + scaleAmt);
      sc.playLive(newScale, durationQuick, 0f);
      offset.playLive(new PVector(offset.value().x + (offset.value().x - screenLocation.x) * scaleAmt, offset.value().y + (offset.value().y - screenLocation.y) * scaleAmt, offset.getEnd().z), durationQuick, 0f);
      break;
    case ZOOM_OUT:
      newScale = sc.value() * (1 - scaleAmt);
      sc.playLive(newScale, durationQuick, 0f);
      offset.playLive(new PVector(offset.value().x - (offset.value().x - screenLocation.x) * scaleAmt, offset.value().y - (offset.value().y - screenLocation.y) * scaleAmt, offset.getEnd().z), durationQuick, 0f);
      break;
    } // end switch
    /*
    PVector newTargetPosition = getWorldCoordFromPoint(screenLocation, newScale); // with new scale
     if (newTargetPosition == null) return;
     PVector newScreenPos = getScreenCoordFromPoint(newTargetPosition, newScale);
     if (newScreenPos == null) return;
     PVector currentPosition = getWorldCoordFromPoint(newScreenPos); // with current scale
     if (currentPosition == null) return;
     moveWorld(currentPosition, newTargetPosition, screenLocation, newScale);
     */
  } // end zoomWorld

  // this will simply zoom the desired amount in the center of the screen
  void zoomScale(float scaleIn) {
    //println("in zoomScale for new scale : " + scaleIn + " from old scale: " + sc.value());
    PVector newTargetPosition = getWorldCoordFromPoint(new PVector(screenDims.x / 2, screenDims.y / 2), scaleIn); // with new scale
    newTargetPosition.z = offset.value().z;
    if (newTargetPosition == null) return;
    PVector newScreenPos = getScreenCoordFromPoint(newTargetPosition, scaleIn);
    if (newScreenPos == null) return;
    PVector currentPosition = getWorldCoordFromPoint(newScreenPos); // with current scale
    if (currentPosition == null) return;
    actuallyMoveWorld(currentPosition, newTargetPosition, new PVector(screenDims.x/2, screenDims.y/2), scaleIn, durationQuick, rotX.value(), rotZ.value());
  } // end zoomScale

    //
  void centerScreenOn(PVector targetLocation) {
    moveWorld(targetLocation, new PVector(screenDims.x/2, screenDims.y/2), sc.getEnd(), durationQuick);
  } // end centerScreenOn

  //
  void centerScreenOn(PVector targetLocation, float zoomLevel, float duration) {
    moveWorld(targetLocation, new PVector(screenDims.x/2, screenDims.y/2), zoomLevel, duration);
  } // end centerScreenOn

    //
  // this will move the world target to the center of the screen at the desired zoomLevel
  void moveWorld(PVector worldTarget, float zoomLevel) {
    centerScreenOn(worldTarget, zoomLevel, durationQuick);
  } // end moveWorld

  //
  void moveWorld(PVector worldTarget, float zoomLevel, float duration) {
    centerScreenOn(worldTarget, zoomLevel, duration);
  } // end moveWorld

  //
  void moveWorld(PVector worldTarget, PVector screenTarget, float zoomLevel) {
    moveWorld(worldTarget, screenTarget, zoomLevel, durationQuick);
  } // end moveWorld

  //
  void moveWorld(PVector worldTarget, PVector screenTarget, float zoomLevel, float duration) {
    moveWorld(worldTarget, screenTarget, zoomLevel, duration, rotX.value(), rotZ.value());
  } // end move world with new target

  //
  void moveWorld(PVector worldTarget, PVector screenTarget, float zoomLevel, float rotXToUse, float rotZToUse) {
    moveWorld(worldTarget, screenTarget, zoomLevel, durationQuick, rotXToUse, rotZToUse);
  } // end moveWorld without duration but with rotations

  //
  void moveWorld(PVector worldTarget, PVector screenTarget, float zoomLevel, float duration, float rotXToUse, float rotZToUse) {
    // find the screen point of that current location, then move the offset to match that location
    //PVector currentWorldPositionAtScreenTarget = getWorldCoordFromPoint(screenTarget, worldTarget.z);
    //PVector currentWorldPositionAtScreenTarget = getWorldCoordFromPoint(screenTarget, worldTarget.z, zoomLevel);
    PVector currentWorldPositionAtScreenTarget = getWorldCoordFromPoint(screenTarget, worldTarget.z, zoomLevel, rotXToUse, rotZToUse);
    if (currentWorldPositionAtScreenTarget == null) {
      // set ht back to 0 and return
      moveVertical(0f);
      return;
    }
    actuallyMoveWorld(worldTarget, currentWorldPositionAtScreenTarget, screenTarget, zoomLevel, duration, rotXToUse, rotZToUse);
  } // end moveWorld with currentPositionAtScreenTarget

  // this will move a world target to the screen target at the desired zoomLevel
  private void actuallyMoveWorld(PVector worldTarget, PVector currentWorldPositionAtScreenTarget, PVector screenTarget, float zoomLevel, float duration, float rotXToUse, float rotZToUse) {
    sc.playLive(zoomLevel, duration, 0f);
    rotX.playLive(rotXToUse, duration, 0f);
    rotZ.playLive(rotZToUse, duration, 0f);
    //println("currentWorldPositionAtScreenTarget at " + screenTarget + " is " + currentWorldPositionAtScreenTarget);
    //println("current offset as: " + offset.getEnd());
    //currentWorldPositionAtScreenTarget.z = -offset.value().z;
    PVector difference = PVector.sub(currentWorldPositionAtScreenTarget, worldTarget);

    //difference.mult(sc.value());
    difference.mult(zoomLevel);

    println("difference.z: " + difference.z);
    //println("difference as: " + difference);
    PVector newOffset = PVector.add(offset.getEnd(), difference);
    //println("newOffset as: " + newOffset);
    offset.playLive(newOffset, duration, 0f);
  } // end moveWorld for world target to screen target


  //
  void moveVertical(float targetAmount) {
    moveVertical(targetAmount, durationQuick);
  } // end moveVertical

  //
  void moveVertical(float targetAmount, float duration) {
    if (!zRangeSet || (targetAmount <= minZ && targetAmount >= maxZ)) {
      offset.playLive(new PVector(offset.getEnd().x, offset.getEnd().y, targetAmount), duration, 0f);
    }
  } // end moveVertical


  //
  PVector getWorldCoordFromPoint(PVector point) {
    return getWorldCoordFromPoint(point, 0f, sc.value(), rotX.value(), rotZ.value());
  } // end getWorldCoordFromPoint

  //
  PVector getWorldCoordFromPoint(PVector point, float zPLaneIn) {
    return getWorldCoordFromPoint(point, zPLaneIn, sc.value(), rotX.value(), rotZ.value());
  } // end getWorldCoordFromPoint  

  //
  //PVector getWorldCoordFromPoint(PVector point, float zPlaneIn, float scaleToUse) {
  PVector getWorldCoordFromPoint(PVector point, float zPlaneIn, float scaleToUse, float rotXIn, float rotZIn) {
    if (printStats) println("in getWorldCoordFromPoint");
    PVector worldCoord = new PVector();

    float userScreenY = point.y - (screenDims.y / 2);

    float userScreenX = point.x - (screenDims.x / 2);



    if (printStats) println(frameCount + " userScreenY: " + userScreenY);
    if (printStats) println(frameCount + " sc.value(): " + nf(sc.value(), 0, 2));
    if (printStats) println(frameCount + " scaleToUse: " + nf(scaleToUse, 0, 2));
    float sideC = dist100 / scaleToUse;
    if (printStats) println(frameCount + " sideC: " + nf(sideC, 0, 2));

    // modify sideC based on offset.value().z
    float zOffset = 0f;
    float zAddition = 0f;
    if (offset.value().z != 0 || zPlaneIn != 0f) {
      //float angleZ = rotX.value();
      float angleZ = rotXIn;
      if (printStats) println(frameCount + " angleZ: " + degrees(angleZ) + " degrees");
      zOffset = (offset.value().z + zPlaneIn * scaleToUse) / (float)Math.cos(-angleZ);
      if (printStats) println(frameCount + " zOffset: " + zOffset);
      sideC -= zOffset / scaleToUse;
      if (printStats) println(frameCount + " sideC: " + nf(sideC, 0, 2));
      zAddition = (float)Math.tan(angleZ) * (offset.value().z + zPlaneIn * scaleToUse);
      zAddition /= scaleToUse;
    }

    // figure y coord
    // angle A is the eye point
    // angle B is the pivot at the origin
    // and angle C is the other one
    // sides a, b, and c are opposite the angle
    float angleA = abs((float)Math.atan(userScreenY / dist100));
    if (printStats) println(frameCount + " angleA: " + degrees(angleA) + " degrees");

    // deal with the rotation of the rotX value.  based on where the user pointer is above or below the midline as well as the degree
    //float rotXToUse = rotX.value();
    float rotXToUse = rotXIn;

    if (rotXToUse >= -PI / 2 && rotXToUse <= PI / 2) {
      if (rotXToUse <= 0) {
        if (userScreenY > 0) {
          rotXToUse *= -1;
        } else {
          angleA *= -1;
        }
      } else {
        if (userScreenY > 0) {
          rotXToUse *= -1;
        } else {
          angleA *= -1;
        }
      }
    } else if (rotXToUse > (float)Math.PI/2) {
      if (userScreenY > 0) {
        rotXToUse = 2 * (float)Math.PI - rotXToUse % (2 * (float)Math.PI);
      } else { 
        angleA *= -1;
      }
    } else {
      if (userScreenY > 0) {
        rotXToUse = 2 * (float)Math.PI - rotXToUse % (2 * (float)Math.PI);
      } else {
        rotXToUse = (2 * (float)Math.PI) - abs(rotXToUse % (2 * (float)Math.PI));
        angleA *= -1;
      }
    }



    //float angleB = (float)Math.PI * .5 + (userScreenY < 0 ? 1 : -1) * (rotX.value());
    float angleB = (float)Math.PI * .5 + rotXToUse;

    if (printStats) println(frameCount + " angleB: " + degrees(angleB) + " degrees");
    float angleC = (float)Math.PI - abs(angleA) - abs(angleB);
    if (printStats) println(frameCount + " angleC: " + degrees(angleC) + " degrees");

    float sideA = sideC * (float)Math.sin(angleA) / (float)Math.sin(angleC); 
    if (printStats) println(frameCount + " sideA: " + sideA);
    float sideB = sideC * (float)Math.sin(angleB) / (float)Math.sin(angleC);
    if (printStats) println(frameCount + " sideB: " + sideB);

    //float offsetY = sideA - offset.value().y / scaleToUse + zAddition;
    //float rotZOffsetY = (offset.value().y * (float)Math.cos(rotZ.value()) + offset.value().x * (float)Math.sin(rotZ.value()));
    float rotZOffsetY = (offset.value().y * (float)Math.cos(rotZIn) + offset.value().x * (float)Math.sin(rotZIn));
    float offsetY = sideA - rotZOffsetY / scaleToUse + zAddition;

    if (printStats) println(frameCount + " offsetY: " + offsetY);
    worldCoord.y = offsetY;

    // figure x coord
    if (printStats) println(frameCount + " userScreenX: " + userScreenX);
    float angleO = (float)Math.PI - angleB;
    if (printStats) println(frameCount + " angleO: " + degrees(angleO) + " degrees");
    float shiftBack = (userScreenY > 0 ? 1 : -1) * (angleO != (float)Math.PI * .5 ? (float)Math.cos(angleO) * sideA : 0f);
    if (printStats) println(frameCount + " shiftBack: " + shiftBack);

    angleA = abs((float)Math.atan(userScreenX / (dist100)));
    if (printStats) println(frameCount + " angleA: " + degrees(angleA) + " degrees");
    angleB = (float)Math.PI;
    sideC = sideC + shiftBack;
    sideA = sideC * (float)Math.tan(angleA);
    if (printStats) println(frameCount + " sideA: " + sideA);

    //float offsetX = (userScreenX < 0 ? -1 : 1) * sideA - offset.value().x / scaleToUse;
    //float rotZOffsetX = (offset.value().x * (float)Math.cos(rotZ.value()) - offset.value().y * (float)Math.sin(rotZ.value()));
    float rotZOffsetX = (offset.value().x * (float)Math.cos(rotZIn) - offset.value().y * (float)Math.sin(rotZIn));
    float offsetX = (userScreenX < 0 ? -1 : 1) * sideA - rotZOffsetX / scaleToUse;

    if (printStats) println(frameCount + " offsetX: " + offsetX);

    worldCoord.x = offsetX;

    //worldCoord.x = ((offsetX + 0) / 1) * (float)Math.cos(rotZ.value()) + ((offsetY + 0) / 1) * (float)Math.sin(rotZ.value());
    worldCoord.x = ((offsetX + 0) / 1) * (float)Math.cos(rotZIn) + ((offsetY + 0) / 1) * (float)Math.sin(rotZIn);
    //worldCoord.y = ((offsetY + 0) / 1) * (float)Math.cos(rotZ.value()) - ((offsetX + 00) / 1) * (float)Math.sin(rotZ.value());
    worldCoord.y = ((offsetY + 0) / 1) * (float)Math.cos(rotZIn) - ((offsetX + 00) / 1) * (float)Math.sin(rotZIn);

    worldCoord.z = zPlaneIn;

    if (printStats) println("final worldCoord from point: " + point + " as: " + worldCoord);

    if (printStats) println("___");

    if (sideC < 0) return null;
    else return worldCoord;
  } // end getWorldCoordFromPoint

  //
  PVector getScreenCoordFromPoint(PVector worldPoint) {
    return getScreenCoordFromPoint(worldPoint, sc.value());
  } // end getScreenCoordFromPoint

  //
  PVector getScreenCoordFromPoint(PVector worldPoint, float scaleToUse) {
    if (printStats2) println(frameCount + " in getScreenCoordFromPoint for point : " + worldPoint.x + ", " + worldPoint.y);
    float distToUse = dist100;

    PVector offsetShift = offset.value().get();



    // do it again for the z value
    // modify sideC based on offset.value().z
    float zAddition = 0f;
    if (offsetShift.z != 0f || worldPoint.z != 0f) {
      float angleZ = rotX.value();

      if (printStats2) println(frameCount + " angleZ: " + degrees(angleZ) + " degrees");
      float zOffset = (worldPoint.z * scaleToUse + offsetShift.z) / (float)Math.cos(-angleZ);

      if (printStats2) println(frameCount + " zOffset: " + zOffset);
      zAddition = (float)Math.tan(angleZ) * (offsetShift.z + worldPoint.z * scaleToUse);


      if (printStats2) println(frameCount + " zAddition: " + zAddition);
      distToUse -= zOffset;

      if (printStats2) println(frameCount + " distToUse: " + distToUse);
    }

    PVector screenCoord = worldPoint.get();
    //sc
    screenCoord.mult(scaleToUse);

    //trans
    if (printStats2) println(frameCount + " basic offset: " + nf(offset.value().x, 0, 2) + ", " + nf(offset.value().y, 0, 2));
    //screenCoord.add(offset.value());

    screenCoord.add(offsetShift);

    //screenCoord.y -= zAddition;
    screenCoord.y -= zAddition * (float)Math.cos(rotZ.value());
    screenCoord.x += zAddition * (float)Math.cos(HALF_PI + rotZ.value());

    //rot for y
    if (printStats2) println(frameCount + " rotX.value(): " + degrees(rotX.value()) + " degrees");
    //float yDistFromCenter = screenCoord.y;
    //float xDistFromCenter = screenCoord.x;

    /*
    float angularDist = (float)Math.sqrt(screenCoord.y * screenCoord.y + screenCoord.x * screenCoord.x); 
     //float yDistFromCenter = angularDist * (float)Math.cos(rotZ.value()) + angularDist * (float)Math.sin(rotZ.value());
     //float xDistFromCenter = angularDist * (float)Math.cos(rotZ.value()) - angularDist * (float)Math.sin(rotZ.value());
     */
    float yDistFromCenter = screenCoord.y * (float)Math.cos(rotZ.value()) + screenCoord.x * (float)Math.sin(rotZ.value());
    float xDistFromCenter = screenCoord.x * (float)Math.cos(rotZ.value()) - screenCoord.y * (float)Math.sin(rotZ.value());
    screenCoord.y = yDistFromCenter;
    screenCoord.x = xDistFromCenter;


    if (printStats2) println(frameCount + " yDistFromCenter: " + yDistFromCenter);
    if (printStats2) println(frameCount + " xDistFromCenter: " + xDistFromCenter);
    //float yRotChange = 
    float angleY = atan(yDistFromCenter / (distToUse)); // eye angle
    if (printStats2) println(frameCount + " angleY: " + degrees(angleY) + " degrees");
    // http://www.mathsisfun.com/algebra/trig-solving-asa-triangles.html
    // assume angle B is the pivot at the origin
    // angle A is the eye point
    // and angle C is the other one
    // sides a, b, and c are opposite the angle
    float angleB = (float)Math.PI * .5 + (screenCoord.y < 0 ? 1 : -1) * (rotX.value());

    // known are sides c -- which is the distToUse
    // and side a -- which is the same as the yDistFromCemter
    // first find side b using the law of cosines
    float sideC = distToUse;
    float sideA = yDistFromCenter; //(float)Math.tan(angleY) * sideC; //;
    float sideB = (float)Math.sqrt(sideC * sideC + sideA * sideA - 2 * sideC * abs(sideA) * (float)Math.cos((angleB)));

    // then use the law of sines to find angle A
    float angleA = (float)Math.asin(sideA * (float)Math.sin(angleB) / sideB);
    float angleC = (float)Math.PI - (angleA) - (angleB);

    if (printStats2) println(frameCount + " angleA: " + degrees(angleA) + " degrees");
    if (printStats2) println(frameCount + " angleB: " + degrees(angleB) + " degrees");
    if (printStats2) println(frameCount + " angleC: " + degrees(angleC) + " degrees");
    if (printStats2) println(frameCount + " sideA: " + sideA);
    if (printStats2) println(frameCount + " sideB: " + sideB);
    if (printStats2) println(frameCount + " sideC: " + sideC);

    // then find the height of the point from corner B up to sideB
    float yOffset = (float)Math.tan(angleA) * dist100;


    screenCoord.y = yOffset;


    if (printStats2) println(frameCount + " yOffset: " + yOffset);


    // rot for x
    // assume angle B is the pivot at the origin
    // angle A is the eye point
    // and angle C is the other one
    // sides a, b, and c are opposite the angle
    sideA = yDistFromCenter * (float)Math.cos(rotX.value());
    if (printStats2) println(frameCount + " sideA: " + sideA);
    angleB = (float)Math.PI;
    float shiftBack = sideA * (float)Math.tan(rotX.value()); 
    if (printStats2) println(frameCount + " shiftBack: " + shiftBack);
    sideC = distToUse - shiftBack;
    if (printStats2) println(frameCount + " sideC: " + sideC);
    //angleA = atan(sideA / sideC);
    angleA = atan(xDistFromCenter / sideC);
    if (printStats2) println(frameCount + " angleA: " + degrees(angleA) + " degrees");
    float xOffset = (float)Math.tan(angleA) * dist100;
    if (printStats2) println(frameCount + " xOffset: " + xOffset);
    screenCoord.x = xOffset;

    //trans
    screenCoord.x += screenDims.x / 2;
    screenCoord.y += screenDims.y / 2;
    if (printStats2) println(frameCount + " screenCoord : " + screenCoord.x + ", " + screenCoord.y);

    if (printStats2) println("___");
    if (sideC < 0) return null;
    else return screenCoord;
  } // end getScreenCoordFromPoint

  //
  void setRotationX(float amt) {
    if (!rotateRangeXSet || (amt >= minRotateX && amt <= maxRotateX)) {
      rotX.setCurrent(amt);
    }
  } // end setRotation


  //
  void setRotationXAnimated(float amt, float duration) {
    if (!rotateRangeXSet || (amt >= minRotateX && amt <= maxRotateX)) {
      rotX.playLive(amt, duration, 0f);
    }
  } // end setRotation

  //
  void setRotationZ(float amt) {
    if (!rotateRangeZSet || (amt >= minRotateZ && amt <= maxRotateZ)) {
      rotZ.setCurrent(amt);
    }
  } // end setRotation

  // 
  void setRotationZAnimated(float amt, float duration) {
    rotZ.playLive(amt, duration, 0f);
  } // end setRotation

  //
  void reset() {
    reset(durationQuick);
  } // end reset

  //
  void reset(float duration) {
    offset.playLive(new PVector(), duration, 0f);
    rotX.playLive(0f, duration, 0f);
    rotZ.playLive(0f, duration, 0f);
    sc.playLive(1f, duration, 0f);
  } // end reset

  //
  void setParams(ZoomPanTilt zpa) {
    setParams(zpa, durationQuick);
  } // end setParams

  //
  void setParams(ZoomPanTilt zpa, float duration) {
    offset.playLive(zpa.offset.value(), duration, 0f);
    rotX.playLive(zpa.rotX.value(), duration, 0f);
    rotZ.playLive(zpa.rotZ.value(), duration, 0f);
    sc.playLive(zpa.sc.value(), duration, 0f);
  } // end setParams

  //
  void setParams(PVector offset, float rotX, float rotZ, float sc) {
    setParams(offset, rotX, rotZ, sc, durationQuick);
  } // end setParams

  //
  void setParams(PVector offset, float rotX, float rotZ, float sc, float duration) {
    this.offset.playLive(offset, duration, 0f);
    this.rotX.playLive(rotX, duration, 0f);
    this.rotZ.playLive(rotZ, duration, 0f);
    this.sc.playLive(sc, duration, 0f);
  } // end setParams

  // 
  void drag(PVector mouseLoc, PVector mouseOffset) {
    if (!draggingWorld) {
      PVector dragWorldOriginal = getWorldCoordFromPoint(mouseLoc);
      if ((draggingBoundsUpper == null && draggingBoundsLower == null) || (dragWorldOriginal != null && (dragWorldOriginal.x >= draggingBoundsLower.x && dragWorldOriginal.x <= draggingBoundsUpper.x && dragWorldOriginal.y <= draggingBoundsUpper.y && dragWorldOriginal.y >= draggingBoundsLower.y))) {
        dragStart = mouseLoc.get();
        dragWorldOffsetStart = offset.value().get();
        draggingWorld = true;
      }
    } else {
      PVector dragWorldOriginal = getWorldCoordFromPoint(dragStart);
      PVector dragWorldNow = getWorldCoordFromPoint(mouseLoc);
      PVector difference = PVector.sub(dragWorldNow, dragWorldOriginal);
      difference.mult(sc.value());
      difference.add(dragWorldOffsetStart);
      offset.setCurrent(difference);
      offset.setEnd(difference);
    }
  } // end darag

  // 
  // MOUSE INTERACTIONS
  void dealWithMouseDragged(PVector mouseLoc, PVector mouseOffset) {
    try {
      drag(mouseLoc, mouseOffset);
      /*
      if (parent.keyPressed && parent.keyCode == parent.SHIFT) {
       drag(mouseLoc, mouseOffset);
       orbitingWorld = false;
       } else if (parent.keyPressed && (parent.keyCode == 157 || parent.keyCode == CONTROL)) {
       moveVertical(offset.getEnd().z + dragginZAmt * mouseOffset.y);
       orbitingWorld = false;
       } else {
       float rotAmt = .01;
       // deal with rotX
       float newAmt = rotX.value() + mouseOffset.y * rotAmt;
       if (!ignoreRotX) setRotationX(newAmt);
       
       // deal with rotZ
       rotAmt = .01;
       newAmt = rotZ.value() + mouseOffset.x * rotAmt;
       if (!ignoreRotZ) setRotationZ(newAmt);
       
       draggingWorld = false;
       orbitingWorld = true;
       }
       */
    }
    catch (Exception e) {
      // cannot get point to drag, probably point off world
    }
  } // end dealWithMouseDragged

  //
  void dealWithMouseReleased() {
    if (draggingWorld) draggingWorld = false;
  } // end dealWithMouseReleased

  //
  void dealWithMouseWheel(float amt, PVector zoomTarget) {
    this.zoomTarget = zoomTarget;
    zoomTracker += (amt < 0 ? -1 : 1) * zoomTrackerIncrement;
  } // end dealWithMouseWheel
} // end class ZoomPan





//
//
//
//
//
//
//
