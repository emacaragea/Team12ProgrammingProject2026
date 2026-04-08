// Ema Caragea, added US Interactive Map screen with choropleth, 24/03/2026
// Ema Caragea, fixed bugs with map  24/03/2026, 21:30
// Ema Caragea, added Alaska and Hawaii inserts, 26/03/2026

//TBD find out why alabama has 0 flights - FIXED!! -by Jesse 25/03/2026
import org.gicentre.geomap.*;

class USMapScreen {
  PApplet sketch;
  GeoMap geoMap48; // shapefile for the continental 48 states
  GeoMap geoMapAK; // separate shapefile for Alaska inset
  GeoMap geoMapHI; // separate shapefile for Hawaii inset
  HashMap<String, Integer> counts; // maps state name to total flight count for choropleth colouring
  int mapMax; //the highest flight count across all states, used to normalise the colour gradient

  final color LOW   = color(198, 219, 239); // lightest blue = fewest flights
  final color HIGH  = color(8,   48,  107); // darkest navy = most flights
  final color HOVER = color(255, 200,   0); //  yellow highlight on hover - stands out against blues

  // stored as fields so mousePressedInRegion can reuse the same values calculated in drawInRegion
  float akX, akY, akW, akH;
  float hiX, hiY, hiW, hiH;
  float mainX, mainY, mainW, mainH;

  //Ema Caragea, constructor finds the global max flight count so the choropleth scale is correct
  USMapScreen(PApplet sketch, HashMap<String, Integer> counts) {
    this.sketch = sketch;
    this.counts = counts;
    mapMax = 1; //start at 1 to avoid division by zero if counts is empty
    for (int v : counts.values()) {
      if (v > mapMax) mapMax = v;
    }

    //, GeoMap is initialised at full window size and scaled down in drawMap() (this is how the library works)
    geoMap48 = new GeoMap(0, 0, width, height, sketch);
    geoMap48.readFile("usContinental48");

    //Alaska inset - separate shapefile needed because AK is not in usContinental48
    geoMapAK = new GeoMap(0, 0, width, height, sketch);
    geoMapAK.readFile("alaska");

    // Hawaii inset - same reason as Alaska
    geoMapHI = new GeoMap(0, 0, width, height, sketch);
    geoMapHI.readFile("hawaii");
  }

  // Full-screen draw (kept for backwards compat)
  void draw() {
    drawInRegion(0, 0, width, height);
  }

  // draws all three maps (48 states + AK + HI) scaled into a sub-region of the screen
  //used by HomeScreen to embed the map between the title and buttons without going full-screen, 01/04/2026
  void drawInRegion(float rx, float ry, float rw, float rh) {
    float yShift    = rh * 0.12;  //  push maps down slightly to leave space for the title area
    float mainXShift = 12;        //  nudge continent right a few pixels to better centre it visually

    //main 48 states takes up most of the region
    mainX = rx + mainXShift;
    mainY = ry + yShift;
    mainW = rw;
    mainH = rh * 0.90;

    //Alaska inset sits top-left, small enough not to cover the main map
    akX = rx + rw * 0.02;
    akY = ry + yShift;
    akW = rw * 0.14;
    akH = rh * 0.25;

    //Hawaii inset sits bottom-left, next to where AK would overlap
    hiX = rx + rw * 0.16;
    hiY = ry + rh * 0.72 + yShift;
    hiW = rw * 0.10;
    hiH = rh * 0.20;

    drawMap(geoMap48, mainX, mainY, mainW, mainH);
    drawMap(geoMapAK, akX,   akY,   akW,   akH);
    drawMap(geoMapHI, hiX,   hiY,   hiW,   hiH);

    drawLegend(rx, ry, rw, rh);
  }

  //Ema Caragea, scales a GeoMap into any screen region while preserving aspect ratio, handles hover highlighting
  void drawMap(GeoMap geoMap, float rx, float ry, float rw, float rh) {
    // use the smaller of x/y scale factors so the map fits without stretching
    pushStyle();
    float scaleX  = rw / width;
    float scaleY  = rh / height;
    float s       = min(scaleX, scaleY);

    //centre the scaled map within the region
    float offsetX = rx + (rw - width  * s) / 2;
    float offsetY = ry + (rh - height * s) / 2;

    pushMatrix();
    translate(offsetX, offsetY);
    scale(s);

    strokeWeight(0.5 / s);
    for (int id : geoMap.getFeatures().keySet()) {
      String name = geoMap.getAttributeTable().findRow(str(id), 0).getString("name");
      stroke(30);
      if (counts.containsKey(name)) {
        // normalise count against global max and interpolate from light blue to dark navy
        float norm = (float) counts.get(name) / mapMax;
        fill(lerpColor(LOW, HIGH, norm));
      } else {
        fill(50); //  dark grey fallback for states with no data
      }
      geoMap.draw(id);
    }

    // Ema Caragea, unproject mouse from screen space into map space to find which state the cursor is over
    float mapMouseX = (mouseX - offsetX) / s;
    float mapMouseY = (mouseY - offsetY) / s;
    int hovId = geoMap.getID(mapMouseX, mapMouseY);
    if (hovId != -1) {
      String name = geoMap.getAttributeTable().findRow(str(hovId), 0).getString("name");
      fill(HOVER, 130); // semi-transparent yellow overlay so the choropleth color still shows through
      stroke(HOVER);
      strokeWeight(1.5 / s);
      geoMap.draw(hovId);
      popMatrix();
      drawTooltip(name); //tooltip is drawn in screen space after popMatrix so it isnt scaled
    } else {
      popMatrix();
    }
    popStyle();
  }

  //recalculates all three map regions then tries AK and HI first since they overlap the main map
  void mousePressedInRegion(float rx, float ry, float rw, float rh) {
    //these calculations must exactly mirror drawInRegion or clicks wont line up with what's drawn
    float yShift    = rh * 0.12;
    float mainXShift = 12;
    mainX = rx + mainXShift; mainY = ry + yShift;              mainW = rw;        mainH = rh * 0.90;
    akX   = rx + rw * 0.02; akY   = ry + yShift;              akW   = rw * 0.14; akH   = rh * 0.25;
    hiX   = rx + rw * 0.16; hiY   = ry + rh * 0.72 + yShift; hiW   = rw * 0.10; hiH   = rh * 0.20;

    if (!tryClick(geoMapAK, akX, akY, akW, akH)) {
      if (!tryClick(geoMapHI, hiX, hiY, hiW, hiH)) {
        tryClick(geoMap48, mainX, mainY, mainW, mainH);
      }
    }
  }

  // unprojects click into map space and navigates to the clicked state's screen
  boolean tryClick(GeoMap geoMap, float rx, float ry, float rw, float rh) {
    float scaleX  = rw / width;
    float scaleY  = rh / height;
    float s       = min(scaleX, scaleY);
    float offsetX = rx + (rw - width  * s) / 2;
    float offsetY = ry + (rh - height * s) / 2;

    if (mouseX < rx || mouseX > rx + rw || mouseY < ry || mouseY > ry + rh) {
      return false;
    }

    float mapMouseX = (mouseX - offsetX) / s;
    float mapMouseY = (mouseY - offsetY) / s;

    int id = geoMap.getID(mapMouseX, mapMouseY);
    if (id == -1) return false; // click was in the inset bounds but missed all state polygons

    String name = geoMap.getAttributeTable().findRow(str(id), 0).getString("name");
    String code = nameToCode(name);
    if (code != null) {
      // Jesse Margarites, 5PM, 24/03, updated this method so when each State is clicked on, go to its state screen
      selectedStateCode = code;
      stateName = convertStateCodeToStateName(selectedStateCode);
      thisState = new State(stateName);
      currentView = CURRENT_VIEW_STATE;
      viewHistIndex++;
      viewHistory.add(viewHistIndex, currentView);
      screen1 = new Screen(3);
    }
    return true;
  }

  // mousePressed for when map is fullscreen
  void mousePressed() {
    mousePressedInRegion(0, 0, width, height);
  }

  // tooltip shows state name and total flight count, constrained to stay inside the window
  void drawTooltip(String stateName) {
    pushStyle();
    int total = counts.containsKey(stateName) ? counts.get(stateName) : 0;
    String label = stateName + ": " + nfc(total) + " flights"; 
    textSize(13);
    float boxW = textWidth(label) + 18; //box adapts to the text width
    float boxH = 26;
    // constrain keeps the tooltip fully visible near screen edges
    float bx   = constrain(mouseX + 14, 0, width  - boxW);
    float by   = constrain(mouseY - 32, 0, height - boxH);
    fill(10, 20, 40, 220);
    stroke(0, 160, 230);
    strokeWeight(1);
    rect(bx, by, boxW, boxH, 5);
    fill(255);
    noStroke();
    textAlign(LEFT, CENTER);
    text(label, bx + 9, by + boxH / 2);
    popStyle();
  }

  // draws a horizontal gradient bar in the bottom-right corner to explain the choropleth colors
  void drawLegend(float rx, float ry, float rw, float rh) {
    pushStyle();
    int lx = (int)(rx + rw) - (int)(rw / 5) - 80; 
    int lw = (int) rw / 5;
    int lh = 14;
    int ly = (int) (ry + rh) - 44;
    noStroke();
    fill(180);
    textSize(11);
    textAlign(LEFT, BOTTOM);
    text("Fewer flights", lx, ly - 2);
    textAlign(RIGHT, BOTTOM);
    text("More flights", lx + lw, ly - 2);
    // draw the gradient pixel-by-pixel by lerping between LOW and HIGH colors
    strokeWeight(1);
    for (int i = lx; i <= lx + lw; i++) {
      float t = (float)(i - lx) / lw;
      stroke(lerpColor(LOW, HIGH, t));
      line(i, ly, i, ly + lh);
    }
    noFill();
    stroke(160);
    strokeWeight(1);
    rect(lx, ly, lw, lh); //border around the gradient bar
    noStroke();
    fill(200);
    textSize(11);
    // show 0, midpoint and max labels below the gradient bar
    textAlign(LEFT, TOP);
    text("0", lx, ly + lh + 3);
    textAlign(CENTER, TOP);
    text(nfc(mapMax / 2), lx + lw / 2, ly + lh + 3);
    textAlign(RIGHT, TOP);
    text(nfc(mapMax), lx + lw, ly + lh + 3);
    popStyle();
  }

  //reverse lookup from state name to state code using the stateCodeToName map
  String nameToCode(String stateName) {
    for (String code : stateCodeToName.keySet()) {
      if (stateCodeToName.get(code).equals(stateName)) return code;
    }
    return null; // returns null if the clicked region isn't a recognised state (e.g. water areas)
  }
}