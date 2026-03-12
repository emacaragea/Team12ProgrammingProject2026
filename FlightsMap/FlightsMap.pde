// Ema Caragea, added map background setup, 12/3/2026 10:00

PImage usMap;

final float MAP_LEFT   = -135.0;  // was -125, pushed west coast right
final float MAP_RIGHT  =  -60.0;  // was -66, pulled east coast left
final float MAP_TOP    =   52.0;  // was 49, pushed northern airports down
final float MAP_BOTTOM =   22.0;  // was 24, pulled southern airports up

// a small lookup table of airports (code, name, lat, lon)

Airport[] airports;

void setup() {
  size(1400, 800);
  usMap = loadImage("us_map.png");
  initAirports();
}

void draw() {
  background(#4169e1);
  drawMap();
  drawAirports();
}

void drawMap() {
  tint(255, 200);
  image(usMap, 0, 0, width, height);
  noTint();
}

void initAirports() {
  // format: code, city name, latitude, longitude
  //more -longitude goes left
  //more latitude goes up
  airports = new Airport[] {
    new Airport("JFK", "New York",      40.64,  -73.78),
    new Airport("LAX", "Los Angeles",   33.94, -118.41),
    new Airport("ORD", "Chicago",       41.97,  -87.90),
    new Airport("DFW", "Dallas",        32.90,  -97.04),
    new Airport("ATL", "Atlanta",       33.64,  -84.43),
    new Airport("MIA", "Miami",         25.79,  -80.29),
    new Airport("SEA", "Seattle",       48.45, -120.30),
    new Airport("DEN", "Denver",        39.86, -104.67),
    new Airport("SFO", "San Francisco", 35.82, -123.38),
    new Airport("BOS", "Boston",        42.37,  -71.02)
  };
}

void mousePressed() {
  // converts your click position back to lon/lat
  float clickedLon = map(mouseX, 0, width, MAP_LEFT, MAP_RIGHT);
  float clickedLat = map(mouseY, 0, height, MAP_TOP, MAP_BOTTOM);
  println("Clicked lon: " + clickedLon + "  lat: " + clickedLat);
}

void drawAirports() {
  for (Airport a : airports) {
    a.draw();
  }
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
  float x, y;          // pixel position on screen
  boolean hovered;     // is the mouse hovering over it?

  Airport(String code, String city, float lat, float lon) {
    this.code = code;
    this.city = city;
    this.lat  = lat;
    this.lon  = lon;
    this.x    = lonToX(lon);   // convert to screen position immediately
    this.y    = latToY(lat);
  }

  void draw() {
    hovered = dist(mouseX, mouseY, x, y) < 10;  // check if mouse is nearby

    // outer glow ring
    noFill();
    stroke(0, 180, 255, 60);
    strokeWeight(6);
    ellipse(x, y, 18, 18);

    // main dot
    if (hovered) {
      fill(255, 220, 0);        // yellow when hovered
      stroke(255, 255, 255);
    } else {
      fill(0, 180, 255);        // blue normally
      stroke(255, 255, 255, 150);
    }
    strokeWeight(1.5);
    ellipse(x, y, 8, 8);

    // show label when hovered
    if (hovered) {
      drawLabel();
    }
  }

  void drawLabel() {
 
    float labelX = x + 12;
    float labelY = y - 10;
    
    textSize(12);
    float boxW = textWidth(code + " - " + city) + 10;

    fill(15, 15, 30, 220);
    noStroke();
    rect(labelX - 5, labelY - 13, boxW, 18, 4);

    
    fill(255);
    textAlign(LEFT, TOP);
    text(code + " - " + city, labelX, labelY - 12);
  }
}