//4PM, 17/03/26, Jesse Margarites
class Airport{
    private String airportName;
    private int worldAreaCode;
    private ArrayList<Flight> flightsLeaving;
    private ArrayList<Flight> flightsIncoming;
    Airport(String airportName, int worldAreaCode){
        this.airportName = airportName;
        this.worldAreaCode = worldAreaCode;
        this.flightsLeaving = new ArrayList<Flight>();
        this.flightsIncoming = new ArrayList<Flight>();
    }

    void setAirportName(String airportName){
        this.airportName = airportName;
    }
    String getAirportName(){
        return airportName;
    }
    void setWorldAreaCode(int worldAreaCode){
        this.worldAreaCode = worldAreaCode;
    }
    int getWorldAreaCode(){
        return worldAreaCode;
    }
    void addFlightsLeaving(Flight flightX){
        if(!flightsLeaving.contains((flightX))){
            flightsLeaving.add(flightX); //CHECK WORKS
        }
    }
    void addFlightsIncoming(Flight flightX){
        if(!flightsIncoming.contains(flightX)){
            flightsIncoming.add(flightX); //CHECK WORKS
        }
    }
    int getNumberOfFlightsLeaving(){
        return flightsLeaving.size()+1;
    }
    int getNumberOfFlightsIncoming(){
        return flightsIncoming.size()+1;
    }
    @Override
    public boolean equals(Object thisObject) {
      if (this == thisObject){
        return true;
      }
      if (thisObject == null || !(thisObject instanceof Airport)) {
        return false;
      }
      Airport airportObject = (Airport) thisObject;
      return this.airportName.equals(airportObject.airportName);
    }
    
}


//Ema Caragea added test and creation for an Airport Screen, 18/03/2026, 20:00
//maybe removed after tests??

class AirportScreen {
  FlightMapScreen screen;

  AirportScreen(FlightMapScreen screen) {
    this.screen = screen;
  }

  void draw() {
    background(10, 15, 25);
    if (screen.selectedAirport == null) {
      screen.currentScreen = 0;
      return;
    }

    fill(255);
    textFont(screen.fontBold);
    textSize(48);
    textAlign(CENTER, TOP);
    text(screen.selectedAirport.code, width / 2, 60);

    textSize(20);
    fill(180, 210, 255);
    text(screen.selectedAirport.city, width / 2, 120);

    fill(255);
    textSize(15);
    textFont(screen.fontRegular);
    text("Flights data coming soon...", width / 2, 200);

    drawBackButton();
  }

  void drawBackButton() {
    fill(0, 160, 230);
    noStroke();
    rect(20, 20, 100, 35, 8);
    fill(255);
    textFont(screen.fontBold);
    textSize(13);
    textAlign(CENTER, CENTER);
    text("< Back", 70, 37);
    textFont(screen.fontRegular);
  }
}



