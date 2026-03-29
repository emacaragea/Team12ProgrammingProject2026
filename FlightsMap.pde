// Ema Caragea, added map background setup, started working on airport placement, 12/3/2026 10:00
// Ema Caragea, added and fixed position of airports, added animations for airports, 13/03/2026, 18:00
// Ema Caragea, added animated flight arcs with airplane icons, 14/3/2026, 15:30

// Ema Caragea, refactored into class for multi-screen program, 18/03/2026

class FlightMapScreen {
  PImage usMap;
  PFont  fontRegular;
  PFont  fontBold;

  PImage planeOnTime;
  PImage planeDelayed;
  PImage planeCancelled;

  int currentScreen                  = 0;   // 0 = map, 1 = route, 2 = airport
  FlightArc          selectedArc     = null;
  AirportCoordinates selectedAirport = null;

  FlightArc[]          arcs;
  AirportCoordinates[] airports;
  MapView              mapView;

  Flights  routePage;
  AirportScreen airportPage;

  final float MAP_LEFT   = -130.0;
  final float MAP_RIGHT  =  -60.0;
  final float MAP_TOP    =   55.0;
  final float MAP_BOTTOM =   18.0;

  void setup() {
    usMap          = loadImage("usmap.jpg");
    fontRegular    = createFont("Arial", 12);
    fontBold       = createFont("Arial Bold", 12);
    textFont(fontRegular);
    planeOnTime    = loadImage("onTimeAirplane.png");
    planeDelayed   = loadImage("delayedAirplane.png");
    planeCancelled = loadImage("cancelledAirplane.png");
    mapView        = new MapView();
    initAirports();
    initArcs();
    routePage   = new Flights(this);
    airportPage = new AirportScreen(this);
  }

  void draw() {
    background(10, 15, 25);
    if (currentScreen == 0) {
      mapView.begin();
        drawMap();
        drawArcs();
        drawAirports();
      mapView.end();
      drawLegend();
    } else if (currentScreen == 1) {
      routePage.draw();
    } else if (currentScreen == 2) {
      airportPage.draw();
    }
  }


  void drawLegend() {
    int x        = 20;
    int y        = height - 190;
    int iconSize = 38;
    int rowH     = 46;

    fill(0, 10, 30, 190);
    noStroke();
    rect(x - 12, y - 12, 220, 192, 10);

    textFont(fontBold);
    textSize(22);
    textAlign(LEFT, TOP);
    fill(220);
    text("Flight Status", x, y);

    imageMode(CENTER);
    textFont(fontRegular);
    textSize(16);

    image(planeOnTime,    x + iconSize / 2, y + rowH      + iconSize / 2, iconSize, iconSize);
    fill(0, 210, 100);
    text("On Time",   x + iconSize + 10, y + rowH      + 10);

    image(planeDelayed,   x + iconSize / 2, y + rowH * 2  + iconSize / 2, iconSize, iconSize);
    fill(255, 200, 0);
    text("Delayed",   x + iconSize + 10, y + rowH * 2  + 10);

    image(planeCancelled, x + iconSize / 2, y + rowH * 3  + iconSize / 2, iconSize, iconSize);
    fill(255, 60, 60);
    text("Cancelled", x + iconSize + 10, y + rowH * 3  + 10);

    imageMode(CORNER);
    textAlign(LEFT, BASELINE);
  }

  void drawMap() {
    image(usMap, 0, 0, width, height);
    fill(0, 10, 30, 55);
    noStroke();
    rect(0, 0, width, height);
  }

  void initAirports() {
    airports = new AirportCoordinates[] {
      new AirportCoordinates(this, "ATL", "Atlanta",        31.64,  -81.43,  1, "GA"),
      new AirportCoordinates(this, "DFW", "Dallas",         30.90,  -94.04,  2, "TX"),
      new AirportCoordinates(this, "DEN", "Denver",         37.86, -101.67,  3, "CO"),
      new AirportCoordinates(this, "ORD", "Chicago",        39.97,  -84.90,  4, "IL"),
      new AirportCoordinates(this, "LAX", "Los Angeles",    31.94, -115.41,  5, "CA"),
      new AirportCoordinates(this, "CLT", "Charlotte",      33.21,  -77.94,  6, "NC"),
      new AirportCoordinates(this, "MCO", "Orlando",        26.43,  -78.31,  7, "FL"),
      new AirportCoordinates(this, "LAS", "Las Vegas",      34.08, -112.15,  8, "NV"),
      new AirportCoordinates(this, "PHX", "Phoenix",        31.43, -109.01,  9, "AZ"),
      new AirportCoordinates(this, "MIA", "Miami",          23.79,  -77.29, 10, "FL"),
      new AirportCoordinates(this, "SEA", "Seattle",        45.45, -119.31, 11, "WA"),
      new AirportCoordinates(this, "IAH", "Houston",        27.99,  -92.34, 12, "TX"),
      new AirportCoordinates(this, "JFK", "New York",       38.64,  -70.78, 13, "NY"),
      new AirportCoordinates(this, "SFO", "San Francisco",  34.62, -119.38, 14, "CA"),
      new AirportCoordinates(this, "BOS", "Boston",         40.37,  -68.00, 15, "MA")
    };
  }

  void drawAirports() {
    for (int i = 0; i < airports.length; i++) airports[i].draw();
  }

  void initArcs() {
    arcs = new FlightArc[] {
      new FlightArc(this, "LAX", "JFK",  "onTime"),
      new FlightArc(this, "ATL", "ORD",  "delayed"),
      new FlightArc(this, "SFO", "DFW",  "cancelled"),
      new FlightArc(this, "SEA", "MIA",  "onTime"),
      new FlightArc(this, "BOS", "LAX",  "delayed")
    };
  }

  void drawArcs() {
    for (int i = 0; i < arcs.length; i++) arcs[i].draw();
  }

  AirportCoordinates findAirport(String code) {
    for (int i = 0; i < airports.length; i++) {
      if (airports[i].code.equals(code)) return airports[i];
    }
    return null;
  }


  void mousePressed() {
    if (currentScreen == 1 || currentScreen == 2) {
      if (mouseX > 20 && mouseX < 120 && mouseY > 20 && mouseY < 55) {
        currentScreen = 0;
      }
      return;
    }
    if (currentScreen == 0) {
      for (int i = 0; i < airports.length; i++) {
        if (airports[i].isClicked()) {
          loadMapAirport(airports[i]);
          return;
        }
      }
      for (int i = 0; i < arcs.length; i++) {
        if (arcs[i].isClicked()) {
          selectedArc   = arcs[i];
          currentScreen = 1;
          return;
        }
      }
      mapView.startDrag();
    }
  }

  void mouseDragged() {
    if (currentScreen == 0) mapView.updateDrag();
  }

  void mouseReleased() {
    mapView.stopDrag();
  }

  void mouseWheel(MouseEvent event) {
    if (currentScreen == 0) mapView.handleZoom(event.getCount());
  }


  float lonToX(float lon) {
    return map(lon, MAP_LEFT, MAP_RIGHT, 0, width);
  }

  float latToY(float lat) {
    return map(lat, MAP_TOP, MAP_BOTTOM, 0, height);
  }
}