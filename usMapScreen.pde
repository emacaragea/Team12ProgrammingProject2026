// Ema Caragea, added US Interactive Map screen with choropleth, 24/03/2026
// Ema Caragea, fixed bugs with map  24/03/2026, 21:30
// Ema Caragea, added Alaska and Hawaii inserts, 26/03/2026

//TBD find out why alabama has 0 flights - FIXED!! -by Jesse 25/03/2026
import org.gicentre.geomap.*;

class USMapScreen {
  PApplet sketch;
  GeoMap geoMap48;
  GeoMap geoMapAK;
  GeoMap geoMapHI;
  HashMap<String, Integer> counts;
  int mapMax;

  final color LOW   = color(198, 219, 239);
  final color HIGH  = color(8,   48,  107);
  final color HOVER = color(255, 200,   0);

  // Regions for AK and HI insets (in screen space, before scaling)
  float akX, akY, akW, akH;
  float hiX, hiY, hiW, hiH;
  float mainX, mainY, mainW, mainH;

  USMapScreen(PApplet sketch, HashMap<String, Integer> counts) {
    this.sketch = sketch;
    this.counts = counts;
    mapMax = 1;
    for (int v : counts.values()) {
      if (v > mapMax) mapMax = v;
    }

    // Main 48 states fills full window (scaled later)
    geoMap48 = new GeoMap(0, 0, width, height, sketch);
    geoMap48.readFile("usContinental48");

    // Alaska inset
    geoMapAK = new GeoMap(0, 0, width, height, sketch);
    geoMapAK.readFile("alaska");

    // Hawaii inset
    geoMapHI = new GeoMap(0, 0, width, height, sketch);
    geoMapHI.readFile("hawaii");
  }

  // Full-screen draw (kept for backwards compat)
  void draw() {
    drawInRegion(0, 0, width, height);
  }

  // Draw choropleth clipped to a sub-region of the screen
  void drawInRegion(float rx, float ry, float rw, float rh) {
    float yShift    = rh * 0.12;  // shift everything down
    float mainXShift = 12;        // shift continent a few pixels right

    // Main 48 states
mainX = rx + mainXShift;
mainY = ry + yShift;
mainW = rw;
mainH = rh * 0.90;

// Alaska inset
akX = rx + rw * 0.02;
akY = ry + yShift;
akW = rw * 0.14;
akH = rh * 0.25;

// Hawaii inset
hiX = rx + rw * 0.16;
hiY = ry + rh * 0.72 + yShift;
hiW = rw * 0.10;
hiH = rh * 0.20;
    drawMap(geoMap48, mainX, mainY, mainW, mainH);
    drawMap(geoMapAK, akX,   akY,   akW,   akH);
    drawMap(geoMapHI, hiX,   hiY,   hiW,   hiH);

    drawLegend(rx, ry, rw, rh);
  }

  // Draws a single GeoMap into a given screen region, preserving aspect ratio
  void drawMap(GeoMap geoMap, float rx, float ry, float rw, float rh) {
    // Scale the full-size map down to fit the region, preserving aspect ratio
    pushStyle();
    float scaleX  = rw / width;
    float scaleY  = rh / height;
    float s       = min(scaleX, scaleY);

    // Centre within the region
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
        float norm = (float) counts.get(name) / mapMax;
        fill(lerpColor(LOW, HIGH, norm));
      } else {
        fill(50);
      }
      geoMap.draw(id);
    }

    // Hover — unproject mouse into map space
    float mapMouseX = (mouseX - offsetX) / s;
    float mapMouseY = (mouseY - offsetY) / s;
    int hovId = geoMap.getID(mapMouseX, mapMouseY);
    if (hovId != -1) {
      String name = geoMap.getAttributeTable().findRow(str(hovId), 0).getString("name");
      fill(HOVER, 130);
      stroke(HOVER);
      strokeWeight(1.5 / s);
      geoMap.draw(hovId);
      popMatrix();
      drawTooltip(name); // draw tooltip in screen space
    } else {
      popMatrix();
    }
    popStyle();
  }

  void mousePressedInRegion(float rx, float ry, float rw, float rh) {
    // Recalculate regions (must match drawInRegion exactly)
    float yShift    = rh * 0.12;
    float mainXShift = 12;
    mainX = rx + mainXShift; mainY = ry + yShift;              mainW = rw;        mainH = rh * 0.90;
    akX   = rx + rw * 0.02; akY   = ry + yShift;              akW   = rw * 0.14; akH   = rh * 0.25;
    hiX   = rx + rw * 0.16; hiY   = ry + rh * 0.72 + yShift; hiW   = rw * 0.10; hiH   = rh * 0.20;

    // Try insets first (they're drawn on top), then the main map
    if (!tryClick(geoMapAK, akX, akY, akW, akH)) {
      if (!tryClick(geoMapHI, hiX, hiY, hiW, hiH)) {
        tryClick(geoMap48, mainX, mainY, mainW, mainH);
      }
    }
  }

  // Checks if mouse click hits a state in the given map/region, navigates if so
  boolean tryClick(GeoMap geoMap, float rx, float ry, float rw, float rh) {
  float scaleX  = rw / width;
  float scaleY  = rh / height;
  float s       = min(scaleX, scaleY);
  float offsetX = rx + (rw - width  * s) / 2;
  float offsetY = ry + (rh - height * s) / 2;

  // Check mouse is actually within this inset region first
  if (mouseX < rx || mouseX > rx + rw || mouseY < ry || mouseY > ry + rh) {
    return false;
  }

  float mapMouseX = (mouseX - offsetX) / s;
  float mapMouseY = (mouseY - offsetY) / s;

  int id = geoMap.getID(mapMouseX, mapMouseY);
  if (id == -1) return false;

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

  void drawTooltip(String stateName) {
    pushStyle();
    int total = counts.containsKey(stateName) ? counts.get(stateName) : 0;
    String label = stateName + ": " + nfc(total) + " flights";
    textSize(13);
    float boxW = textWidth(label) + 18;
    float boxH = 26;
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
    strokeWeight(1);
    for (int i = lx; i <= lx + lw; i++) {
      float t = (float)(i - lx) / lw;
      stroke(lerpColor(LOW, HIGH, t));
      line(i, ly, i, ly + lh);
    }
    noFill();
    stroke(160);
    strokeWeight(1);
    rect(lx, ly, lw, lh);
    noStroke();
    fill(200);
    textSize(11);
    textAlign(LEFT, TOP);
    text("0", lx, ly + lh + 3);
    textAlign(CENTER, TOP);
    text(nfc(mapMax / 2), lx + lw / 2, ly + lh + 3);
    textAlign(RIGHT, TOP);
    text(nfc(mapMax), lx + lw, ly + lh + 3);
    popStyle();
  }

  String nameToCode(String stateName) {
    for (String code : stateCodeToName.keySet()) {
      if (stateCodeToName.get(code).equals(stateName)) return code;
    }
    return null;
  }
}