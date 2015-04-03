ArrayList<Citation> citations = new ArrayList();
Citation currentCitation;
Circle overlayCircle;
//ArrayList<Line> commonCitationLines = new ArrayList();
boolean globalRollover;
float closestDistance;
boolean showCommonCitationLines = false;

void setup() {
  size(1400,900,P3D);
  smooth(4);
  loadCitations("WoS_CitationsTrail_OriginalPaper_lessInfo.csv");
  
  for(int i=0; i < citations.size(); i++) {
    for(int j=0; j < citations.size(); j++) {
      
      String[] sharedCites1 = citations.get(i).citedRefs;
      String[] sharedCites2 = citations.get(j).citedRefs;
      println("Amount of Cited References " + sharedCites1.length);

      for(int k=0; k < sharedCites1.length; k++) {
        for(int l= k+1; l < sharedCites2.length; l++) {
           if(sharedCites1[k].equals(sharedCites2[l])) {
              println("Shared Reference:" + " " +sharedCites1[k]);
              
              float x1 = citations.get(i).circle.x;
              float y1= citations.get(i).circle.y;
              float x2 = citations.get(j).circle.x;
              float y2= citations.get(j).circle.y;
              
//              color lineColor = 
              
              citations.get(i).makeLine(x1, y1, x2, y2);
              citations.get(i).addSharedRef(sharedCites2[l]); //try to add shared reference to Citation obj
         }
        }
      }

    }
    println("Amount of Shared References: " + citations.get(i).sharedRefs.size());
  }

  //println("amount of shared citations: " + sameCitationLines.size());
  
  //for each cited references you need to get each circle out
  //make a hashmap for the citation - so that when you're loading them in, each time you check a citation references
  //see if that reference name exists, if it does, then append it.
}

void draw() {
  globalRollover = false;
  background(255);

  for (Citation c:citations) {
    
   c.circle.display(false);
   c.circle.rollover(mouseX, mouseY, c.circle.diam);
   
   if(c.circle.rollover) {
     closestDistance = 100;
     //if this is the closest one set it to currentCitation
     float distance = c.circle.distanceToCenter(mouseX, mouseY);
     if (distance < closestDistance) {
       closestDistance = distance;
       println(closestDistance);
       currentCitation = c;
       overlayCircle = c.circle;
       globalRollover = true;

     }
    }
  }
  //Press 'A' to see articles written by same authors
//  if(showCommonCitationLines) {
//    for(Line ln: commonCitationLines) {
//       ln.display();
//      }
//    }

  if(globalRollover){
    
     overlayCircle.display(true);  
     currentCitation.drawLine();
      
     fill(0, 100);
     text(currentCitation.authors, 100, 100);
     text(currentCitation.title, 100, 120);
     text(currentCitation.year, 100, 140);
     text("Total Citation Count: "+ currentCitation.citeCount, 100, 160); 
     text("Common Citations: " + currentCitation.sharedRefs.size(), 100, 180);
     
     ArrayList<String> cleanRefs = new ArrayList();
     int cnt = 0;
     for(int i = 0; i < currentCitation.sharedRefs.size(); i++) {
         String tempRef1 = currentCitation.sharedRefs.get(i);
       for(int j = i+1; j < currentCitation.sharedRefs.size(); j++) {
         String tempRef2 = currentCitation.sharedRefs.get(j);
         if(tempRef1.equals(tempRef2)) {
             cnt += 1;
         }
       }
       if(cnt < 1) {
        cleanRefs.add(tempRef1); 
       }
       cnt = 0;
     }
     
     for(int k=0; k<cleanRefs.size(); k++) {
       text(cleanRefs.get(k), 100, 200 + 15*k);
     }
  }
}

void keyPressed() {
  if(key == 'a' || key == 'A') {
    showCommonCitationLines = !showCommonCitationLines;
  }
}

void loadCitations(String url) {
  Table t = loadTable(url, "header");
  for (TableRow r:t.rows()) {
    Citation c= new Citation().fromRow(r);
    if (c.citeCount > 10) { 
     citations.add(c); 
     //println(c.citedRefs);
    }
  }
}


