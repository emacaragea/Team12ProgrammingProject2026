// Ema Caragea, added map background setup, started working on airport placement, 12/3/2026 10:00
// Ema Caragea, added and fixed position of airports, added animations for airports, 13/03/2026, 18:00
// Ema Caragea, added animated flight arcs with airplane icons, 14/3/2026, 15:30

PImage usMap;
PFont fontRegular;
PFont fontBold;

PImage planeOnTime;
PImage planeDelayed;
PImage planeCancelled;

int currentScreen = 0;  // 0 = map screen, 1 = route detail screen
FlightArc selectedArc = null;

FlightArc[] arcs;

final float MAP_LEFT   = -130.0;
final float MAP_RIGHT  =  -60.0;
final float MAP_TOP    =   55.0;
final float MAP_BOTTOM =   18.0;

Airport[] airports;

void setup() {
  size(1400, 800);
  usMap          = loadImage("usmap.jpg");
  fontRegular    = createFont("Arial", 12);
  fontBold       = createFont("Arial Bold", 12);
  textFont(fontRegular);
  planeOnTime    = loadImage("onTimeAirplane.png");
  planeDelayed   = loadImage("delayedAirplane.png");
  planeCancelled = loadImage("cancelledAirplane.png");
  initAirports();
  initArcs();
}

void draw() {
  background(10, 15, 25);

  if (currentScreen == 0) {
    drawMap();
    drawArcs();
    drawAirports();
  } else if (currentScreen == 1) {
    drawRoutePage();  //link to flight details page
  }
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
  for (int i = 0; i < airports.length; i++) {
    airports[i].draw();
  }
}

void initArcs() {
  // format: origin code, destination code, status
  // status: "onTime", "delayed", "cancelled"
  arcs = new FlightArc[] {
    new FlightArc("LAX", "JFK",  "onTime"),
    new FlightArc("ATL", "ORD",  "delayed"),
    new FlightArc("SFO", "DFW",  "cancelled"),
    new FlightArc("SEA", "MIA",  "onTime"),
    new FlightArc("BOS", "LAX",  "delayed")
  };
}

void drawArcs() {
  for (int i = 0; i < arcs.length; i++) {
    arcs[i].draw();
  }
}

// finds an airport from the airports array by its code
Airport findAirport(String code) {
  for (int i = 0; i < airports.length; i++) {
    if (airports[i].code.equals(code)) {
      return airports[i];
    }
  }
  return null;
}

void mousePressed() {
  for (int i = 0; i < arcs.length; i++) {
    if (arcs[i].isClicked()) {
      selectedArc = arcs[i];   // save which arc was clicked, so that later on the Flights page it knows what to show
      currentScreen = 1;
      return;
    }
  }

  if (currentScreen == 0) {
    float lon = map(mouseX, 0, width, MAP_LEFT, MAP_RIGHT);
    float lat = map(mouseY, 0, height, MAP_TOP, MAP_BOTTOM);
    println("lon: " + lon + "  lat: " + lat);
  }
}

float lonToX(float lon) {
  return map(lon, MAP_LEFT, MAP_RIGHT, 0, width);
}

float latToY(float lat) {
  return map(lat, MAP_TOP, MAP_BOTTOM, 0, height);
}


