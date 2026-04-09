// Ema Caragea, added map background setup, started working on airport placement, 12/3/2026 10:00
// Ema Caragea, added and fixed position of airports, added animations for airports, 13/03/2026, 18:00
// Ema Caragea, added animated flight arcs with airplane icons, 14/3/2026, 15:30

//Ema Caragea, refactored into class for multi-screen program, 18/03/2026
//Ema Caragea, added actual routes to the map, 01/04/2026, 19:00
//Ema Caragea, added ux/ui elements like pop up list of flights, 2/04/2026, 10:00

class FlightMapScreen {
  PImage usMap;
  PFont  fontRegular;
  PFont  fontBold;

  PImage planeOnTime;
  PImage planeDelayed;
  PImage planeCancelled;

  int currentScreen                  = 0;   // 0 = map, 1 = route, 2 = airport
  boolean showRoutesPanel            = false;
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

  // loads assets and initialises all airports and arcs during the main loading phase
  void setup() {
    usMap          = loadImage("usmap.jpg");
    fontRegular    = createFont("Arial", 12);
    fontBold       = createFont("Arial Bold", 12);
    textFont(fontRegular);

    // three separate plane images so on-time/delayed/cancelled routes are visually distinct
    planeOnTime    = loadImage("onTimeAirplane.png");
    planeDelayed   = loadImage("delayedAirplane.png");
    planeCancelled = loadImage("cancelledAirplane.png");
    mapView        = new MapView();
    initAirports();
    initArcs();
    routePage   = new Flights(this);
    airportPage = new AirportScreen(this);
  }

  // routes draw calls to the correct sub-screen 
  void draw() {
    background(10, 15, 25);
    if (currentScreen == 0) {
      // mapView.begin/end wraps the pan/zoom transform around all map content
      mapView.begin();
        drawMap();
        drawArcs();
        drawAirports();
      mapView.end();
      //legend and panel button are drawn after mapView.end so they stay fixed on screen during pan/zoom
      drawLegend();
      drawRoutesPanelButton();
      if (showRoutesPanel) drawRoutesPanel();
    } else if (currentScreen == 1) {
      routePage.draw();
    } else if (currentScreen == 2) {
      airportPage.draw();
    }
  }


  // draws a fixed legend card in the bottom-left corner explaining the three flight status colors
  void drawLegend() {
    int x        = 32;
    int y        = height - 206; // bottom-left
    int iconSize = 38;
    int rowH     = 46; 

    //, semi-transparent dark card so the map shows through slightly behind the legend
    fill(30, 36, 52, 230);
    stroke(70, 80, 110, 180);
    strokeWeight(1.5);
    rect(x - 12, y - 12, 250, 198, 14);
    noStroke();

    textFont(fontBold);
    textSize(18);
    textAlign(LEFT, TOP);
    fill(220);
    text("Flight Status", x, y);

    textFont(fontRegular);
    textSize(13);
    fill(160, 170, 200, 200);
    text("Click any airport or route to explore", x, y + 22); 

   
    imageMode(CENTER);
    textFont(fontRegular);
    textSize(13);

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

  void drawRoutesPanel() {
    String[][] sections = {
      {"Top 10 most on-time routes",
       "LGA → ORD", "BOS → DCA", "LAX → SFO", "JFK → LAX", "LAS → LAX",
       "LAX → PHX", "ATL → LGA", "BOS → LGA", "ATL → MCO", "PDX → SEA"},
      {"Top 10 most delayed routes",
       "EWR → MCO", "BOS → JFK", "JFK → MIA", "DEN → SLC", "DEN → ORD",
       "ATL → DFW", "IAH → LAX", "SEA → SFO", "MIA → ORD", "DFW → LAX"},
      {"Top 10 most cancelled routes",
       "DCA → EWR", "CLT → LGA", "BOS → ORD", "DCA → ORD", "DCA → LGA",
       "ATL → EWR", "JFK → ORD", "MIA → LGA", "BOS → MIA", "DFW → ORD"}
    };
    color[] sectionColors = {color(0, 210, 100), color(255, 200, 0), color(255, 60, 60)};

    int panelW   = 230;
    int titleH   = 18;
    int routeH   = 14;
    int gapH     = 10;
    int padX     = 14;
    int padY     = 14;
    int sectionH = titleH + 10 * routeH;
    int panelH   = padY + 3 * sectionH + 2 * gapH + padY;

    int px = width - panelW - 20;
    int py = height - panelH - 70;  
    fill(30, 36, 52, 230);
    stroke(70, 80, 110, 180);
    strokeWeight(1.5);
    rect(px, py, panelW, panelH, 14);
    noStroke();

    int cx = px + padX;
    int cy = py + padY;

    for (int s = 0; s < 3; s++) {
      textFont(fontBold);
      textSize(13);
      textAlign(LEFT, TOP);
      fill(sectionColors[s]);
      text(sections[s][0], cx, cy);
      cy += titleH;

      textFont(fontRegular);
      textSize(11);
      fill(190, 195, 215);
      for (int r = 1; r <= 10; r++) {
        text(r + ". " + sections[s][r], cx + 4, cy);
        cy += routeH;
      }
      cy += gapH;
    }

    textAlign(LEFT, BASELINE);
  }

  // draws the satellite map image then overlays a dark tint to make airport dots and arcs more visible
  void drawMap() {
    image(usMap, 0, 0, width, height);
    // semi-transparent dark overlay darkens the map so the colored arcs stand out
    fill(0, 10, 30, 55);
    noStroke();
    rect(0, 0, width, height);
  }

  // defines the 20 busiest US airports by lat/lon - rank controls dot size on the map, 12/03/2026
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
      new AirportCoordinates(this, "JFK", "New York",       37.64,  -70.78, 13, "NY"),
      new AirportCoordinates(this, "SFO", "San Francisco",  34.62, -119.38, 14, "CA"),
      new AirportCoordinates(this, "BOS", "Boston",         40.37,  -68.00, 15, "MA"),
      new AirportCoordinates(this, "LGA", "New York LaGuardia", 38.20,  -70.78, 16, "NY"),
      new AirportCoordinates(this, "DCA", "Washington DC",  36.85,  -74.20, 17, "DC"),
      new AirportCoordinates(this, "EWR", "Newark",         37.80,  -71.50, 18, "NJ"),
      new AirportCoordinates(this, "PDX", "Portland",       43.58, -119.80, 19, "OR"),
      new AirportCoordinates(this, "SLC", "Salt Lake City", 37.20, -108.60, 20, "UT")
    };
  }

  void drawAirports() {
    for (int i = 0; i < airports.length; i++) airports[i].draw();
  }

  // defines the 30 animated flight arcs based on real top-10 routes per status category
  void initArcs() {
  arcs = new FlightArc[] {
    // top 10 on time routes
    new FlightArc(this,"LGA", "ORD", "onTime"),
    new FlightArc(this, "BOS", "DCA", "onTime"),
    new FlightArc(this, "LAX", "SFO", "onTime"),
    new FlightArc(this, "JFK", "LAX", "onTime"),
    new FlightArc(this, "LAS", "LAX", "onTime"),
    new FlightArc(this, "LAX", "PHX", "onTime"),
    new FlightArc(this, "ATL", "LGA", "onTime"),
    new FlightArc(this, "BOS", "LGA", "onTime"),
    new FlightArc(this, "ATL", "MCO", "onTime"),
    new FlightArc(this, "PDX", "SEA", "onTime"),


    // top 10 delayed routes
    new FlightArc(this, "EWR", "MCO", "delayed"),
    new FlightArc(this, "BOS", "JFK", "delayed"),
    new FlightArc(this, "JFK", "MIA", "delayed"),
    new FlightArc(this, "DEN", "SLC", "delayed"),
    new FlightArc(this, "DEN", "ORD", "delayed"),
    new FlightArc(this, "ATL", "DFW", "delayed"),
    new FlightArc(this, "IAH", "LAX", "delayed"),
    new FlightArc(this, "SEA", "SFO", "delayed"),
    new FlightArc(this, "MIA", "ORD", "delayed"),
    new FlightArc(this, "DFW", "LAX", "delayed"),

    // top 10 cancelled routes
    new FlightArc(this, "DCA", "EWR", "cancelled"),
    new FlightArc(this, "CLT", "LGA", "cancelled"),
    new FlightArc(this, "BOS", "ORD", "cancelled"),
    new FlightArc(this, "DCA", "ORD", "cancelled"),
    new FlightArc(this, "DCA", "LGA", "cancelled"),
    new FlightArc(this, "ATL", "EWR", "cancelled"),
    new FlightArc(this, "JFK", "ORD", "cancelled"),
    new FlightArc(this, "MIA", "LGA", "cancelled"),
    new FlightArc(this, "BOS", "MIA", "cancelled"),
    new FlightArc(this, "DFW", "ORD", "cancelled")
    
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


  boolean isRoutesPanelButtonHovered() {
    int bw = 170, bh = 40;
    int bx = width - bw - 20;
    int by = height - bh - 20;
    return mouseX >= bx && mouseX <= bx + bw && mouseY >= by && mouseY <= by + bh;
  }

  void drawRoutesPanelButton() {
    int bw = 170, bh = 40;
    int bx = width - bw - 20;
    int by = height - bh - 20;

    fill(30, 36, 52, 230);
    stroke(70, 80, 110, 180);
    strokeWeight(1.5);
    rect(bx, by, bw, bh, 10);
    noStroke();

    textFont(fontBold);
    textSize(13);
    textAlign(CENTER, CENTER);
    fill(220);
    text("Top Routes " + (showRoutesPanel ? "\u25b2" : "\u25bc"), bx + bw / 2, by + bh / 2);
    textAlign(LEFT, BASELINE);
  }

  // handles clicks on the back button, the routes panel toggle, airports, and map drag
  void mousePressed() {
    // back button in the top-left returns to the map from either detail sub-screen
    if (currentScreen == 1 || currentScreen == 2) {
      if (mouseX > 20 && mouseX < 120 && mouseY > 20 && mouseY < 55) {
        currentScreen = 0;
      }
      return;
    }
    if (currentScreen == 0) {
      // routes panel button toggles the top-routes panel open and closed
      if (isRoutesPanelButtonHovered()) {
        showRoutesPanel = !showRoutesPanel;
        return;
      }
      // check each airport dot for a click 
      for (int i = 0; i < airports.length; i++) {
        if (airports[i].isClicked()) {
          loadMapAirport(airports[i]);
          return;
        }
      }
      //  any other click on the map starts a pan drag and closes the routes panel
      showRoutesPanel = false;
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


  // maps a longitude value to a screen x coordinate using the map's geographic bounding box
  float lonToX(float lon) {
    return map(lon, MAP_LEFT, MAP_RIGHT, 0, width); //  MAP_LEFT=-130 (west coast), MAP_RIGHT=-60 (east coast)
  }

  // maps a latitude value to a screen y coordinate 
  // !lat is inverted
  float latToY(float lat) {
    return map(lat, MAP_TOP, MAP_BOTTOM, 0, height); 
  }
}