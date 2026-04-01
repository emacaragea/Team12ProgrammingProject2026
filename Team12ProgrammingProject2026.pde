import java.util.Scanner;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;

final static int SCREEN_WIDTH  = 1400;
final static int SCREEN_HEIGHT = 800;

final int STATE_BACK_ARROW_X = SCREEN_WIDTH/4-20;
final int STATE_BACK_ARROW_Y = 650;
final int STATE_FORWARD_ARROW_X = STATE_BACK_ARROW_X + 70;
final int STATE_FORWARD_ARROW_Y = 650;
final int ARROW_HEIGHT = 6;
final int ARROW_LENGTH = 20;
final int CURRENT_VIEW_HOME = 0;
final int CURRENT_VIEW_STATE = 1;
final int CURRENT_VIEW_FLIGHT_MAP = 2;
final int CURRENT_VIEW_AIRPORT = 3;
final int CURRENT_VIEW_GENERAL_TABLE = 4;
final int CURRENT_VIEW_BOOK_FLIGHT = 5;   //amanda working here
final static float HEADINGS_SIZE = 40;
final static float SUBHEADINGS_SIZE = 25;
final static float TEXT_SIZE = 21;

FlightMapScreen         flightMap;
USMapScreen             usMap;
Screen                  screen1;
Screen                  screen2;
HomeScreen homeScreen;

HashMap<String, String>   stateCodeToName;
HashMap<String, Integer>  stateFlightCounts;
HashMap<String, Airport>  airportsByCode = new HashMap<String, Airport>();
int    currentView       = 0;
int    lastView;
//String selectedStateCode = "TX";
String selectedStateCode;
State thisState;
String stateName;
String airportName;
Airport thisAirport;
ArrayList<Integer> viewHistory = new ArrayList<Integer>();
boolean dataLoaded = false;
float loadProgress = 0;
int viewHistIndex;

static final String[] ALL_STATE_CODES = {
  "AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA",
  "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME",
  "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM",
  "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX",
  "UT", "VA", "VT", "WA", "WI", "WV", "WY"
};

void settings() {
  size(SCREEN_WIDTH, SCREEN_HEIGHT);
}

//old setup, replaced

// void setup() {
//   // Build code name lookup once from CSV (used by countAllStateFlights + geoMap hover)
//   stateCodeToName = buildCodeToNameMap();

//   // Lightweight pass over all state files  just counts origin + destination per state
//   stateFlightCounts = new HashMap<String, Integer>();
//   countAllStateFlights();

//   flightMap = new FlightMapScreen();
//   flightMap.setup();

//   usMap        = new USMapScreen(this, stateFlightCounts);
//   homeScreen   = new HomeScreen(usMap);
//   screen1 = new Screen(3);
// }

//method that only loads the data, called in setup as a thread so loading screen can be displayed while data is being loaded
void setup() {
  loading = new Loading();
  loading.setup();
  thread("loadData");
}

//new "setup" method
void loadData() {
  flightMap = new FlightMapScreen();
  flightMap.setup();
  screen1 = new Screen(3);
  screen2 = new Screen(2);
  stateCodeToName = buildCodeToNameMap();
  stateFlightCounts = new HashMap<String, Integer>();

  fullTableSetup();
  tableSetup();

  // Count flights per state and track progress
  String path = "data/flights/origin_states/";
  for (int i = 0; i < ALL_STATE_CODES.length; i++) {
    String code = ALL_STATE_CODES[i];
    try {
      BufferedReader reader = new BufferedReader(new FileReader(sketchPath(path + code + ".csv")));
      reader.readLine();
      String line = reader.readLine();
      while (line != null) {
        Scanner scan = new Scanner(line).useDelimiter(",");
        String[] fields = new String[10];
        for (int j = 0; j < 10; j++) {
          fields[j] = scan.hasNext() ? nextToken(scan) : "";
        }
        scan.close();
        addCount(fields[5]);
        addCount(fields[9]);
        line = reader.readLine();
      }
      reader.close();
    } catch (Exception e) {}

    loadProgress = (float)(i + 1) / ALL_STATE_CODES.length;
  }

  usMap      = new USMapScreen(this, stateFlightCounts);
  homeScreen = new HomeScreen(usMap);
  viewHistIndex = 0;
  viewHistory.add(viewHistIndex, CURRENT_VIEW_HOME);
  dataLoaded = true;

  


}

// Reads StateNameAndCode.csv once and returns the full code-name map
HashMap<String, String> buildCodeToNameMap() {
  HashMap<String, String> result = new HashMap<String, String>();
  try {
    BufferedReader reader = new BufferedReader(new FileReader(sketchPath("data/StateNameAndCode.csv")));
    reader.readLine(); // skip header
    String line = reader.readLine();
    while (line != null) {
      Scanner scan = new Scanner(line).useDelimiter(",");
      if (scan.hasNext()) {
        String code = scan.next().trim();
        if (scan.hasNext()) {
          result.put(code, scan.next().trim());
        }
      }
      scan.close();
      line = reader.readLine();
    }
    reader.close();
  }
  catch (Exception e) {
    println("buildCodeToNameMap: " + e);
  }
  return result;
}

// Reads only fields 5 (origin state) and 9 (dest state) from every state file
// so the map can be coloured without loading full Flight objects into memory
void countAllStateFlights() {
  String path = "data/flights/origin_states/";
  for (String code : ALL_STATE_CODES) {
    try {
      BufferedReader reader = new BufferedReader(new FileReader(sketchPath(path + code + ".csv")));
      reader.readLine(); // skip header
      String line = reader.readLine();
      while (line != null) {
        Scanner scan = new Scanner(line).useDelimiter(",");
        String[] fields = new String[10];
        for (int i = 0; i < 10; i++) {
          fields[i] = scan.hasNext() ? nextToken(scan) : "";
        }
        scan.close();
        addCount(fields[5]); // ORIGIN_STATE_ABR
        addCount(fields[9]); // DEST_STATE_ABR
        line = reader.readLine();
      }
      reader.close();
    }
    catch (Exception e) {
      // file missing for this state- skip
    }
  }
}

void addCount(String stateCode) {
  String name = stateCodeToName.get(stateCode);
  if (name != null) {
    int prev = stateFlightCounts.containsKey(name) ? stateFlightCounts.get(name) : 0;
    stateFlightCounts.put(name, prev + 1);
  }
}


String convertStateCodeToStateName(String stateCode) {
  String filePath = "data/StateNameAndCode.csv";
  BufferedReader reader;
  try {
    reader = new BufferedReader(new FileReader(sketchPath(filePath)));
    String currentLine = reader.readLine();
    while (currentLine != null) {
      currentLine = reader.readLine();
      if (currentLine == null) break;
      Scanner lineScanner = new Scanner(currentLine).useDelimiter(",");
      String currentCode = lineScanner.next();
      if (currentCode.equals(stateCode)) {
        return lineScanner.next();
      }
      lineScanner.close();
    }
    reader.close();
  } catch (Exception e) {
    System.out.println(e);
    return "error";
  }
  return null;
}

void readFileByState(String stateCode, State currentState) {
  String filePath = "data/flights/origin_states/";
  String fileEnding = ".csv";
  BufferedReader reader;
  try {
    reader = new BufferedReader(new FileReader(sketchPath(filePath + stateCode + fileEnding)));
    String line = reader.readLine();
    line = reader.readLine(); // skip header
    while (line != null) {
      Scanner lineScan = new Scanner(line).useDelimiter(",");
      String flightDate             = nextToken(lineScan);
      String airlineCode            = nextToken(lineScan);
      int    flightNumber           = lineScan.nextInt();
      String originCityCode         = nextToken(lineScan);
      String originCityName         = nextToken(lineScan);
      String originStateCode        = nextToken(lineScan);
      int    originWorldAreaCode    = lineScan.nextInt();
      String destinationCityCode    = nextToken(lineScan);
      String destinationCityName    = nextToken(lineScan);
      String destinationStateCode   = nextToken(lineScan);
      int    destinationWorldAreaCode = lineScan.nextInt();
      String scheduledDepartureTime = nextToken(lineScan);
      String actualDepartureTime    = nextToken(lineScan);
      String scheduledArrivalTime   = nextToken(lineScan);
      String actualArrivalTime      = nextToken(lineScan);
      int    cancelled              = lineScan.nextInt();
      int    diverted               = lineScan.nextInt();
      double airportDistance        = lineScan.nextDouble();
      lineScan.close();

      Airport originAirport      = new Airport(originCityName, originWorldAreaCode);
      Airport destinationAirport = new Airport(destinationCityName, destinationWorldAreaCode);
      Flight newFlight = new Flight(flightDate, airlineCode, flightNumber,
        originAirport, destinationAirport, scheduledDepartureTime, actualDepartureTime,
        scheduledArrivalTime, actualArrivalTime, cancelled, diverted, airportDistance);

      if (!currentState.getAirportList().contains(originAirport)) {
        currentState.addAirport(originAirport);
        originAirport.addFlightsLeaving(newFlight);
      } else {
        boolean airportFound = false;
        int counter = 0;
        while (counter < currentState.getNumberOfAirports() || !airportFound) {
          if (currentState.getAirportList().get(counter).getAirportName().equals(originCityName)) {
            airportFound = true;
            currentState.getAirportList().get(counter).addFlightsLeaving(newFlight);
          }
          counter++;
        }
      }
      line = reader.readLine();
    }
    reader.close();
  }
  catch (Exception e) {
    println(e);
  }
}




void loadMapAirport(AirportCoordinates ac) {
  if (!airportsByCode.containsKey(ac.code)) {
    Airport airport = new Airport(ac.city, 0);
    String path = "data/flights/origin_states/" + ac.stateCode + ".csv";
    try {
      BufferedReader reader = new BufferedReader(new FileReader(sketchPath(path)));
      reader.readLine(); // skip header
      String line = reader.readLine();
      while (line != null) {
        Scanner lineScan = new Scanner(line).useDelimiter(",");
        try {
          String flightDate             = nextToken(lineScan);
          String airlineCode            = nextToken(lineScan);
          int    flightNumber           = lineScan.nextInt();
          String originCityCode         = nextToken(lineScan);
          String originCityName         = nextToken(lineScan);
          String originStateCode        = nextToken(lineScan);
          int    originWorldAreaCode    = lineScan.nextInt();
          String destinationCityCode    = nextToken(lineScan);
          String destinationCityName    = nextToken(lineScan);
          String destinationStateCode   = nextToken(lineScan);
          int    destinationWorldAreaCode = lineScan.nextInt();
          String scheduledDepartureTime = nextToken(lineScan);
          String actualDepartureTime    = nextToken(lineScan);
          String scheduledArrivalTime   = nextToken(lineScan);
          String actualArrivalTime      = nextToken(lineScan);
          int    cancelled              = lineScan.nextInt();
          int    diverted               = lineScan.nextInt();
          double airportDistance        = lineScan.nextDouble();

          if (originCityCode.equals(ac.code)) {
            Airport destAirport = new Airport(destinationCityName, destinationWorldAreaCode);
            Flight newFlight = new Flight(flightDate, airlineCode, flightNumber,
              airport, destAirport, scheduledDepartureTime, actualDepartureTime,
              scheduledArrivalTime, actualArrivalTime, cancelled, diverted, airportDistance);
            airport.addFlightsLeaving(newFlight);
          }
        } catch (Exception e) {}
        lineScan.close();
        line = reader.readLine();
      }
      reader.close();
    } catch (Exception e) {
      println("loadMapAirport: " + e);
    }
    airportsByCode.put(ac.code, airport);
  }

  thisAirport  = airportsByCode.get(ac.code);
  airportName  = ac.city;
  screen2      = new Screen(2);
  currentView  = CURRENT_VIEW_AIRPORT;
  viewHistIndex++;
  viewHistory.add(viewHistIndex, currentView);
}

String nextToken(Scanner thisScanner) {
  String token = thisScanner.next().trim();
  if (token.startsWith("\"")) {
    while (!token.endsWith("\"")) {
      token += "," + thisScanner.next();
    }
    token = token.replace("\"", "").trim();
  }
  return token;
}

//Ema Caragea, added home screen when running the program, 24/03/2026, 21:00
void draw() {

  //Ema caragea, added loading screen while data is being loaded, 26/03/2026, 9:00
  if(!dataLoaded){
    loading.draw();
    return;
  }
  if (viewHistory.get(viewHistIndex) == CURRENT_VIEW_HOME) {
    homeScreen.draw();
    screen1.drawHomeBar();
  } else if (viewHistory.get(viewHistIndex) == CURRENT_VIEW_STATE) {
    screen1.drawStateScreen(selectedStateCode, thisState, stateName);
    screen1.drawHomeBar();
  } else if (viewHistory.get(viewHistIndex) == CURRENT_VIEW_FLIGHT_MAP) {
    flightMap.draw();
    screen1.drawHomeBar();
  }
  else if(viewHistory.get(viewHistIndex) == CURRENT_VIEW_AIRPORT){
    screen2.drawAirportScreen(thisAirport, airportName);
    screen1.drawHomeBar();
  }
  else if (viewHistory.get(viewHistIndex) == CURRENT_VIEW_GENERAL_TABLE) {
  fullTableDraw();
  screen1.drawHomeBar();
}
else if (viewHistory.get(viewHistIndex) == CURRENT_VIEW_BOOK_FLIGHT) {
  tableDraw();
  screen1.drawHomeBar();
}
}

void mousePressed() {
  if(!dataLoaded){
    
    return;
  }

  //Niko Charles, 9:00 26/03/2026 Added Home Button 
  //Niko Charles, 13:30 26/03/2026 Added Back Button
  if(screen1.goHome(mouseX, mouseY)){
    currentView = CURRENT_VIEW_HOME;
    viewHistIndex++;
    viewHistory.add(viewHistIndex, currentView);
  }
  if(screen1.goBack(mouseX, mouseY)){
    viewHistIndex--;
  }
  if (viewHistory.get(viewHistIndex) == CURRENT_VIEW_HOME) {
    homeScreen.mousePressed();
    if (mouseButton==RIGHT) {
      currentView=CURRENT_VIEW_HOME;
      viewHistIndex++;
      viewHistory.add(viewHistIndex, currentView);
    }
  } else if (viewHistory.get(viewHistIndex)==CURRENT_VIEW_STATE) {
    //Jesse Margarites, 4PM, 24/03 made interactive forward and back buttons for the State screen
    if (thisState.getNumberOfAirports()>MAX_AIRPORT_DISPLAY&&mouseX>=STATE_FORWARD_ARROW_X && mouseX<= STATE_FORWARD_ARROW_X+ARROW_LENGTH
      && mouseY>= STATE_FORWARD_ARROW_Y-ARROW_HEIGHT && mouseY <= STATE_FORWARD_ARROW_Y+ARROW_HEIGHT
      && thisState.getPageNumber()==1) {
      thisState.setPageNumber(2);
    } else if (thisState.getNumberOfAirports()>MAX_AIRPORT_DISPLAY&&mouseX>=STATE_BACK_ARROW_X && mouseX<= STATE_BACK_ARROW_X+ARROW_LENGTH
      && mouseY>= STATE_BACK_ARROW_Y-ARROW_HEIGHT && mouseY <= STATE_BACK_ARROW_Y+ARROW_HEIGHT
      && thisState.getPageNumber()==2) {
      thisState.setPageNumber(1);
    }
    thisState.airportClicked();
    screen1.mousePressed();
  } else if (viewHistory.get(viewHistIndex)==CURRENT_VIEW_FLIGHT_MAP) {
    flightMap.mousePressed();
  }
  else if (viewHistory.get(viewHistIndex) == CURRENT_VIEW_GENERAL_TABLE) {
  fullTableMousePressed();
}
else if (viewHistory.get(viewHistIndex) == CURRENT_VIEW_BOOK_FLIGHT) {
  tableMousePressed();
}
}
//Jesse Margarites and Orla Kealy 10AM, fixed filter search bar
void keyPressed(){
  if(viewHistory.get(viewHistIndex)==CURRENT_VIEW_STATE){
    screen1.keyPressed(key);
  }

}


void mouseDragged() {
  if (viewHistory.get(viewHistIndex) == CURRENT_VIEW_GENERAL_TABLE) {
  fullTableMouseDragged();
} else {
  flightMap.mouseDragged();
}
}
void mouseReleased() {
  if (viewHistory.get(viewHistIndex) == CURRENT_VIEW_GENERAL_TABLE) {
  fullTableMouseReleased();
} else {
  flightMap.mouseReleased();
}
}
void mouseWheel(MouseEvent event) {
 if (viewHistory.get(viewHistIndex) == CURRENT_VIEW_GENERAL_TABLE) {
  fullTableMouseWheel(event);
}
else if (viewHistory.get(viewHistIndex) == CURRENT_VIEW_BOOK_FLIGHT) {
  tableMouseWheel(event);
}
else {
  flightMap.mouseWheel(event);
}
}

