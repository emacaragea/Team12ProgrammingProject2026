//4PM, 17/03/26, Jesse Margarites
//Used a faster method than loadBytes and loadStrings with the BufferedReader.
//This makes it easier to read it line by line with a scanner
import java.util.Scanner;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
final static int SCREEN_WIDTH = 500;
final static int SCREEN_HEIGHT = 450;

//change maybe
State CO;
String stateName;


void setup() {
  size(900, 900);
  final  PFont TITLE_FONT = createFont("Helvetica Bold", 24);
  final  PFont LABEL_FONT = createFont("Helvetica Bold", 16);
  final  PFont SMALL_FONT = createFont("Helvetica", 13);
 

  stateName = convertStateCodeToStateName("CO");
  CO = new State(stateName);
  readFileByState("CO", CO);

}
String convertStateCodeToStateName(String stateCode){
  String filePath = "/Users/jessm/Desktop/TetsingState/data/StateNameAndCode.csv";
  BufferedReader reader;
  try {
    reader = new BufferedReader(new FileReader(sketchPath(filePath)));  //using sketchPath to correctly find this file from any machine
    String currentLine = reader.readLine();
    while (currentLine != null) {
      currentLine = reader.readLine();
      Scanner lineScanner = new Scanner(currentLine).useDelimiter(","); 
      String currentCode = lineScanner.next();
      if(currentCode.equals(stateCode)){
        //println(lineScanner.next());
        return lineScanner.next();
      }
      lineScanner.close();
      
    }
    reader.close();
  } catch(Exception e) {
    System.out.println(e);
    return "error";
  }
  return null;
}

void readFileByState(String stateCode, State currentState){
  String filePath = "/Users/jessm/Desktop/TetsingState/data/flights/dest_states/";
  String fileEnding = ".csv";
  BufferedReader reader;
  try {
    reader = new BufferedReader(new FileReader(sketchPath(filePath+stateCode+fileEnding)));  //using sketchPath to correctly find this file from any machine
    String line = reader.readLine();
    line = reader.readLine(); // skiping header
   // println(line);
    while (line != null) {
      Scanner lineScan = new Scanner(line).useDelimiter(",");
      
      String flightDate = nextToken(lineScan);
      String airlineCode = nextToken(lineScan);
      int flightNumber = lineScan.nextInt();
      String originCityCode = nextToken(lineScan);
      String originCityName = nextToken(lineScan);
      String originStateCode = nextToken(lineScan);
      int originWorldAreaCode = lineScan.nextInt();
      String destinationCityCode = nextToken(lineScan);
      String destinationCityName = nextToken(lineScan);
      String destinationStateCode = nextToken(lineScan);
      int destinationWorldAreaCode = lineScan.nextInt();
      String scheduledDepartureTime = nextToken(lineScan);
      String actualDepartureTime = nextToken(lineScan);
      String scheduledArrivalTime = nextToken(lineScan);
      String actualArrivalTime = nextToken(lineScan);
      int cancelled = lineScan.nextInt();
      int diverted = lineScan.nextInt();
      double airportDistance = lineScan.nextDouble();

      Airport originAirport = new Airport(originCityName, originWorldAreaCode);
      Airport destinationAirport = new Airport(destinationCityName, destinationWorldAreaCode);
      Flight newFlight = new Flight(flightDate, airlineCode, flightNumber, 
                        originAirport, destinationAirport, scheduledDepartureTime, actualDepartureTime,
                       scheduledArrivalTime, actualArrivalTime, cancelled, diverted, airportDistance);
      originAirport.addFlightsLeaving(newFlight);
      destinationAirport.addFlightsIncoming(newFlight);
      currentState.addAirport(originAirport); //might have to change depedning on which file is being read
      line = reader.readLine();

    }
    reader.close();
  } catch(Exception e) {
    println(e);
  }
}

String nextToken(Scanner sc) {
    String token = sc.next().trim();
    
    if (token.startsWith("\"")) {
        while (!token.endsWith("\"")) {
            token += "," + sc.next();
        }
        token = token.replace("\"", "").trim();
    }
    
    return token;
}


void draw() {
  CO.stateDraw(stateName);
  
}
