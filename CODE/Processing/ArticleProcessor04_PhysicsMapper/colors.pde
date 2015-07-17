// all the colors used in the sketch
// author colors
color colorAuthorStroke = color(255); // stroke color for author circle
color colorAuthorMin = #3f348c; //#34348c;//#4f3489;//#6121db; //#34348c;//#e9bf1b; //#3d3aba; //#6121db; //#292a4f; //#6c36f2; //#e9bf1b;//#5123bf;//#292a4f;//#6b03ff; //#eaa200;//#00aa00; // #6E99DE; //#005555; // #6bc1b0;  // #eaa200; // or #ef847f fill color for the minimum number of authors metric
color colorAuthorMax = #f4ad31;//#f4c531;//#f7932f;//#55a097;//#aa18b5;//#f7932f;//#f9ba2d;//#f95826;//#f92626;//#f97126;//#f98a26;//#e81f1f;//#cc5126; //#dd911f; //#f9f67d;//#f23655;//#e81f1f;//#e81f58;//#ea4f1c;//#ff5003;//#eaa200;//#ea4f1c;//#FFD736; //#9375F7; // #00ffff; //#e3903a; // #fce579; // or #93cb9a fill color for the max number of authors metric
//color colorAuthorMin2 = #55a097;
color colorAuthorMax2 = #f47f31;//#f7932f;//#dd9121;
//color colorAuthorMin3 = #f7932f;
color colorAuthorMax3 = #d8301e; //#dd4400; //#cc4741;//#cc2929;//#cc5227;


// article circle fills
color colorArticleBackgroundMin =  #292a4f;//#00ffff;
color colorArticleBackgroundMax =  #4656a0;


// swirly connector lines
color colorConnectorLine = #ea4f1c;//#e81fe3; //#ffd652; //#5fffa7;//#ea4f1c;//#d9f7ad;//#ea4f1c; // curves from Article to term


// line from term down
color colorTermToGround = color(50, 200, 102); // the line from the term down to the base of the z
color colorTermNetwork = #ea4f1c; //#00cddd; //#e7ae40; //#ea4f1c; //#00cddd;//color(0, 255, 0); // color of the network below the terms 


// category stuff
color categoryBarChart = #4656a0; // 
color categoryFontColor = #a6bef4; // 


// published stuff
color colorPublished = #00dbbb;//#00cddd; //#00db92; //#00cddd;//#FFD736; //#9895FF; //#fe31f2;
color colorUnpublished = #5309aa;//#0b587a;//#0494b5;//#5309aa; //#075aad;//#235866;//#7a0ba8; //#5309aa; //#075aad;//#292a4f;//#235866;//#D8C267; //#908EC4; //#770077;// #2672f9; // #2eb5ab;


// grid
color gridColor = #d9f7ad;//color(255, 0, 0, 150);


// render
color colorRegistration = color(100, 100, 220);

//term circle
color termOutline = #ea4f1c; //#dd911f; //#00cddd; //#e7ae40;//#ea4f1c;//#00cddd;//#91e205; //color(0, 255, 0);

color[] getCategoryColors(color startColor, int divisions, float colorAngle) {
  color[] colors = Colors.getEvenDivisions(startColor, divisions, colorAngle);
  return colors;
}
