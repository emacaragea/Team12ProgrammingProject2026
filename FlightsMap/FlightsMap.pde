// Ema Caragea, added map background setup, started working on airport placement, 12/3/2026 10:00
// Ema Caragea, added and fixed position of airports, added animations for airports, 13/03/2026, 18:00

PImage usMap;
PFont fontRegular;
PFont fontBold;

final float MAP_LEFT   = -130.0;
final float MAP_RIGHT  =  -60.0;
final float MAP_TOP    =   55.0;
final float MAP_BOTTOM =   18.0;

Airport[] airports;

void setup() {
  size(1400, 800);
  usMap       = loadImage("usmap.jpg");
  fontRegular = createFont("Arial", 12);
  fontBold    = createFont("Arial Bold", 12);
  textFont(fontRegular);
  initAirports();
}

void draw() {
  background(10, 15, 25);
  drawMap();
  drawAirports();
}

void drawMap() {
  image(usMap, 0, 0, width, height);
  fill(0, 10, 30, 55);
  noStroke();
  rect(0, 0, width, height);
}

void initAirports() {
  airports = new Airport[] {
    new Airport("ATL", "Atlanta",        31.64,  -81.43,  1),
    new Airport("DFW", "Dallas",         30.90,  -94.04,  2),
    new Airport("DEN", "Denver",         37.86, -101.67,  3),
    new Airport("ORD", "Chicago",        39.97,  -84.90,  4),
    new Airport("LAX", "Los Angeles",    31.94, -115.41,  5),
    new Airport("CLT", "Charlotte",      33.21,  -77.94,  6),
    new Airport("MCO", "Orlando",        26.43,  -78.31,  7),
    new Airport("LAS", "Las Vegas",      34.08, -112.15,  8),
    new Airport("PHX", "Phoenix",        31.43, -109.01,  9),
    new Airport("MIA", "Miami",          23.79,  -77.29, 10),
    new Airport("SEA", "Seattle",        45.45, -119.31, 11),
    new Airport("IAH", "Houston",        27.99,  -92.34, 12),
    new Airport("JFK", "New York",       38.64,  -70.78, 13),
    new Airport("SFO", "San Francisco",  34.62, -119.38, 14),
    new Airport("BOS", "Boston",         40.37,  -68.00, 15)
  };
}

void drawAirports() {
  for (Airport a : airports) {
    a.draw();
  }
}

void mousePressed() {
  float lon = map(mouseX, 0, width, MAP_LEFT, MAP_RIGHT);
  float lat = map(mouseY, 0, height, MAP_TOP, MAP_BOTTOM);
  println("lon: " + lon + "  lat: " + lat);
}

float lonToX(float lon) {
  return map(lon, MAP_LEFT, MAP_RIGHT, 0, width);
}

float latToY(float lat) {
  return map(lat, MAP_TOP, MAP_BOTTOM, 0, height);
}




class Airport {
  String code;
  String city;
  float lat, lon;
  float x, y;
  boolean hovered;
  float dotSize;
  float currentSize;

  Airport(String code, String city, float lat, float lon, int rank) {
    this.code        = code;
    this.city        = city;
    this.lat         = lat;
    this.lon         = lon;
    this.x           = lonToX(lon);
    this.y           = latToY(lat);
    this.dotSize     = map(rank, 1, 15, 14, 7);
    this.currentSize = dotSize;
  }

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
    float labelX  = x + currentSize / 2 + 8;
    float labelY  = y - 8;

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