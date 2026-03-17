//Ema Caragea added airpors and their attributes 12- 13/ 03/ 2026
//Ema Caragea created a separate file for Airport class 15/03/2026, 15:00

//class Airport {
//  String code;
//  String city;
//  float lat, lon;
//  float x, y;
//  boolean hovered;
//  float dotSize;
//  float currentSize;

//  Airport(String code, String city, float lat, float lon, int rank) {
//    this.code        = code;
//    this.city        = city;
//    this.lat         = lat;
//    this.lon         = lon;
//    this.x           = lonToX(lon);
//    this.y           = latToY(lat);
//    this.dotSize     = map(rank, 1, 15, 14, 7);
//    this.currentSize = dotSize;
//  }

  void draw() {
    hovered = dist(mouseX, mouseY, x, y) < 15;

    float targetSize;
    if (hovered) {
      targetSize = dotSize * 1.5;
    } else {
      targetSize = dotSize;
    }
    currentSize += (targetSize - currentSize) * 0.15;

    strokeWeight(1.5);
    if (hovered) {
      fill(255, 220, 0);
      stroke(255, 255, 255, 200);
    } else {
      fill(0, 160, 230);
      stroke(100, 210, 255, 200);
    }
    ellipse(x, y, currentSize, currentSize);

    drawCodeLabel();
    if (hovered) {
      drawHoverLabel();
    }
  }

  void drawCodeLabel() {
    if (hovered) {
      fill(255, 220, 0);
    } else {
      fill(255, 255, 255, 220);
    }
    noStroke();
    textFont(fontBold);
    textSize(11);
    textAlign(CENTER, TOP);
    text(code, x, y + currentSize / 2 + 4);
    textFont(fontRegular);
  }

  void drawHoverLabel() {
    String label = code + "  " + city;
    float labelX = x + currentSize / 2 + 8;
    float labelY = y - 8;

    textFont(fontBold);
    textSize(13);
    float boxW = textWidth(label) + 14;
    float boxH = 20;

    fill(0, 0, 0, 80);
    noStroke();
    rect(labelX - 4, labelY - 13, boxW + 2, boxH + 2, 5);

    fill(5, 10, 30, 230);
    stroke(0, 180, 255, 150);
    strokeWeight(1);
    rect(labelX - 5, labelY - 14, boxW, boxH, 5);

    fill(255);
    noStroke();
    textAlign(LEFT, TOP);
    text(label, labelX, labelY - 12);
    textFont(fontRegular);
  }
}