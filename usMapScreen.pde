// Ema Caragea, added US Interactive Map screen with choropleth, 24/03/2026
// Ema Caragea, fixed bugs with map  24/03/2026, 21:30

//TBD find out why alabama has 0 flights
import org.gicentre.geomap.*;

class USMapScreen {
  PApplet sketch;
  GeoMap geoMap;
  HashMap<String, Integer> counts;
  int mapMax;

  final color LOW   = color(198, 219, 239);
  final color HIGH  = color(8,   48,  107);
  final color HOVER = color(255, 200,   0);

  USMapScreen(PApplet sketch, HashMap<String, Integer> counts) {
    this.sketch = sketch;
    this.counts = counts;
    mapMax = 1;
    for (int v : counts.values()) {
      if (v > mapMax) mapMax = v;
    }
    geoMap = new GeoMap(0, 0, width, height, sketch);
    geoMap.readFile("usContinental");
  }

  // Full-screen draw (kept for backwards compat)
  void draw() {
    drawInRegion(0, 0, width, height);
  }

  // Draw choropleth clipped to a sub-region of the screen
  void drawInRegion(float rx, float ry, float rw, float rh) {
  // Scale the full-size map down to fit the region, preserving aspect ratio
  float scaleX = rw / width;
  float scaleY = rh / height;
  float s = min(scaleX, scaleY);

  // Centre within the region
  float offsetX = rx + (rw - width  * s) / 2;
  float offsetY = ry + (rh - height * s) / 2;

  pushMatrix();
  translate(offsetX, offsetY);
  scale(s);

  strokeWeight(0.5 / s);
  for (int id : geoMap.getFeatures().keySet()) {
    String name = geoMap.getAttributeTable().findRow(str(id), 0).getString("Name");
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
    String name = geoMap.getAttributeTable().findRow(str(hovId), 0).getString("Name");
    fill(HOVER, 130);
    stroke(HOVER);
    strokeWeight(1.5 / s);
    geoMap.draw(hovId);
    popMatrix();
    drawTooltip(name); // draw tooltip in screen space
  } else {
    popMatrix();
  }

  drawLegend(rx, ry, rw, rh);
}

  void mousePressedInRegion(float rx, float ry, float rw, float rh) {
  float scaleX  = rw / width;
  float scaleY  = rh / height;
  float s       = min(scaleX, scaleY);
  float offsetX = rx + (rw - width  * s) / 2;
  float offsetY = ry + (rh - height * s) / 2;

  float mapMouseX = (mouseX - offsetX) / s;
  float mapMouseY = (mouseY - offsetY) / s;

  int id = geoMap.getID(mapMouseX, mapMouseY);
  if (id == -1) return;
  String name = geoMap.getAttributeTable().findRow(str(id), 0).getString("Name");
  String code = nameToCode(name);
  if (code != null) {
    //Jesse Margarites, 5PM, 24/03, updated this method so when each State is clicked on, go to its state screen
     selectedStateCode = code;
     stateName = convertStateCodeToStateName(selectedStateCode);
     thisState = new State(stateName);
     currentView = 1;
      screen1 = new Screen(3); // reset so Screen loads the newly selected state
  }
}

  // Keep old mousePressed for when map is fullscreen
  void mousePressed() {
    mousePressedInRegion(0, 0, width, height);
  }

  void drawTooltip(String stateName) {
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
  }

  void drawLegend(float rx, float ry, float rw, float rh) {
    int lx = (int) rx + 12;
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
  }

  String nameToCode(String stateName) {
    for (String code : stateCodeToName.keySet()) {
      if (stateCodeToName.get(code).equals(stateName)) return code;
    }
    return null;
  }
}