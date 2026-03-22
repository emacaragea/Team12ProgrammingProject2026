import org.gicentre.geomap.*;

class USMapScreen {
  GeoMap geoMap;
  HashMap<String, Integer> counts;
  int mapMax;

  final color LOW   = color(198, 219, 239);  // light blue  - fewest flights
  final color HIGH  = color(8,   48,  107);  // dark navy   - most flights
  final color HOVER = color(255, 200, 0);    // yellow highlight on hover

  USMapScreen(HashMap<String, Integer> counts) {
    this.counts = counts;
    mapMax = 1;
    for (int v : counts.values()) {
      if (v > mapMax) mapMax = v;
    }
    geoMap = new GeoMap(0, 0, width, height, Team12ProgrammingProject2026.this);
    geoMap.readFile("usContinental");
  }

  void draw() {
    background(20, 28, 38);

    // Choropleth - colour each state by total flight count
    strokeWeight(0.5);
    for (int id : geoMap.getFeatures().keySet()) {
      String name = geoMap.getAttributeTable().findRow(str(id), 0).getString("Name");
      stroke(30);
      if (counts.containsKey(name)) {
        float norm = (float) counts.get(name) / mapMax;
        fill(lerpColor(LOW, HIGH, norm));
      } else {
        fill(50); // no data
      }
      geoMap.draw(id);
    }

    // Hover highlight
    int hovId = geoMap.getID(mouseX, mouseY);
    if (hovId != -1) {
      String name = geoMap.getAttributeTable().findRow(str(hovId), 0).getString("Name");
      fill(HOVER, 130);
      stroke(HOVER);
      strokeWeight(1.5);
      geoMap.draw(hovId);
      drawTooltip(name);
    }

    drawTitle();
    drawLegend();
    drawHint();
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

  void drawTitle() {
    noStroke();
    fill(220, 235, 255);
    textAlign(CENTER, TOP);
    textSize(20);
    text("Total Flights Per State  (departures + arrivals)", width / 2, 12);
  }

  void drawLegend() {
    int lx = 12;
    int lw = width / 5;
    int lh = 14;
    int ly = height - 44;

    // Label above bar
    noStroke();
    fill(180);
    textSize(11);
    textAlign(LEFT, BOTTOM);
    text("Fewer flights", lx, ly - 2);
    textAlign(RIGHT, BOTTOM);
    text("More flights", lx + lw, ly - 2);

    // Gradient bar (vertical lines left - right)
    strokeWeight(1);
    for (int i = lx; i <= lx + lw; i++) {
      float t = (float)(i - lx) / lw;
      stroke(lerpColor(LOW, HIGH, t));
      line(i, ly, i, ly + lh);
    }

    // Border around bar
    noFill();
    stroke(160);
    strokeWeight(1);
    rect(lx, ly, lw, lh);

    // Tick labels
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

  void drawHint() {
    noStroke();
    fill(90);
    textAlign(RIGHT, BOTTOM);
    textSize(11);
    text("Click a state for details   |   Right-click to return", width - 12, height - 6);
  }

  void mousePressed() {
    if (mouseButton != LEFT) return;
    int id = geoMap.getID(mouseX, mouseY);
    if (id == -1) return;

    String name = geoMap.getAttributeTable().findRow(str(id), 0).getString("Name");
    String code = nameToCode(name);
    if (code != null) {
      selectedStateCode = code;
      currentView = 1;
      screen1 = new Screen(3); // reset so Screen loads the newly selected state
    }
  }

  // Reverse lookup using the stateCodeToName map already built in setup
  String nameToCode(String stateName) {
    for (String code : stateCodeToName.keySet()) {
      if (stateCodeToName.get(code).equals(stateName)) {
        return code;
      }
    }
    return null;
  }
}