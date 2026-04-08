// Ema Caragea, added airports and their attributes 12-13/03/2026
// Ema Caragea, created a separate file 15/03/2026
// Ema Caragea, refactored to hold screen reference 18/03/2026

class AirportCoordinates {
  FlightMapScreen screen;

  String  code;      
  String  city;
  String  stateCode; //  used when clicking an airport to load the correct state's flight data
  float   lat, lon;  // geographic coordinates, converted to screen x/y in the constructor
  float   x, y;
  boolean hovered;
  float   dotSize;  
  float   currentSize; 

  // converts lat/lon to pixel coordinates immediately so draw() doesnt need to recalculate each frame, 12/03/2026
  AirportCoordinates(FlightMapScreen screen, String code, String city,
                     float lat, float lon, int rank, String stateCode) {
    this.screen      = screen;
    this.code        = code;
    this.city        = city;
    this.stateCode   = stateCode;
    this.lat         = lat;
    this.lon         = lon;
    this.x           = screen.lonToX(lon); 
    this.y           = screen.latToY(lat);
    this.dotSize     = map(rank, 1, 15, 14, 7); 
    this.currentSize = dotSize;
  }

  //hover radius is tighter for the NY cluster (JFK/LGA/EWR) to avoid triggering the wrong airport
  void draw() {
    boolean tight = code.equals("JFK") || code.equals("LGA") || code.equals("EWR");
    float hoverRadius = tight ? currentSize / 2 : 15;
    hovered = dist(screen.mapView.mapMouseX(), screen.mapView.mapMouseY(), x, y) < hoverRadius;

    float targetSize = hovered ? dotSize * 1.5 : dotSize;
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
    if (hovered) drawHoverLabel();
  }

  boolean isClicked() {
    boolean tight = code.equals("JFK") || code.equals("LGA") || code.equals("EWR");
    float clickRadius = tight ? dotSize / 2 : 15;
    return dist(screen.mapView.mapMouseX(), screen.mapView.mapMouseY(), x, y) < clickRadius;
  }

  // label position is special cased for the crowded NJ/NY area so labels dont collide
  void drawCodeLabel() {
    fill(hovered ? color(255, 220, 0) : color(255, 255, 255, 220));
    noStroke();
    textFont(screen.fontBold);
    textSize(11);
    if (code.equals("EWR")) {
      textAlign(RIGHT, CENTER);  // EWR label goes left of the dot to avoid JFK
      text(code, x - currentSize / 2 - 4, y);
    } else if (code.equals("LGA")) {
      textAlign(LEFT, CENTER);   //LGA label goes right of the dot to avoid JFK
      text(code, x + currentSize / 2 + 4, y);
    } else {
      textAlign(CENTER, TOP);    // all other airports label below the dot
      text(code, x, y + currentSize / 2 + 4);
    }
    textFont(screen.fontRegular);
  }

  // popup label shows full city name on hover, positioned to avoid going off-screen
  void drawHoverLabel() {
    String label = code + "  " + city;

    textFont(screen.fontBold);
    textSize(13);
    float boxW = textWidth(label) + 14;
    float boxH = 20;

    float labelX, labelY;
    if (code.equals("JFK")) {
      // JFK label goes above the dot so it doesnt overlap LGA which is directly to the left
      labelX = x - boxW / 2;
      labelY = y - currentSize / 2 - boxH - 6;
    } else {
      labelX = x + currentSize / 2 + 8; // all others appear to the right of the dot
      labelY = y - 8;
    }

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
    textFont(screen.fontRegular);
  }
}