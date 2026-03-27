//4PM, 17/03/26, Jesse Margarites
//4PM, 19/03/26, Jesse Margarites fixed some errors
class Airport{
    private String airportName;
    private int worldAreaCode;
    private ArrayList<Flight> flightsLeaving;
    private ArrayList<Flight> flightsIncoming;
    private String pieGraphTitle;
    private String[] pieLabels;
    private float[] pieValues;
    private color[] pieColors = {color(54, 110, 190), color(70, 130, 210), color(90, 150, 230)};
    Charts charts;
    private boolean setGraphValues;
    final private float PIE_CHART_DIAMETER = 200;
    final private int PIE_CHART_X_COORDINATE = SCREEN_WIDTH/3+70;
    final private int PIE_CHART_Y_COORDINATE = 400;


    Airport(String airportName, int worldAreaCode){
      this.airportName = airportName;
      this.worldAreaCode = worldAreaCode;
      this.flightsLeaving = new ArrayList<Flight>();
      this.flightsIncoming = new ArrayList<Flight>();
      charts = new Charts();
      setGraphValues =false;
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

    void setGraphValues(boolean setGraphValues) {
      this.setGraphValues = setGraphValues;
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
        return flightsLeaving.size();
    }
    int getNumberOfFlightsIncoming(){
        return flightsIncoming.size();
    }

//Niko Charles 3:00 25/03/2026 write method
    String[] getPieChartLabels(){
      float cancelled = 0;
      float delayed = 0;
      float onTime = 0;
      String actualDepartTimeString;
      String scheduledDepartTimeString;
      int actualDepartTime;
      int scheduledDepartTime;
      ArrayList<String> flightsCancelledLabels = new ArrayList<String>();
      for(int i = 0; i < flightsLeaving.size(); i++){
        actualDepartTimeString = flightsLeaving.get(i).getActualDepartureTime();
        scheduledDepartTimeString = flightsLeaving.get(i).getScheduledDepartureTime();
        if(actualDepartTimeString != null && scheduledDepartTimeString != null && !actualDepartTimeString.trim().isEmpty()
            && !scheduledDepartTimeString.trim().isEmpty()){
          actualDepartTime = Integer.valueOf(actualDepartTimeString.trim());
          scheduledDepartTime = Integer.valueOf(scheduledDepartTimeString.trim());
        }
        else{
          actualDepartTime = 0;
          scheduledDepartTime = 0;
        }
        if(flightsLeaving.get(i).getFlightCancelled() == 1){
          cancelled++;
        }
        else if(actualDepartTime > scheduledDepartTime){
          delayed++;
        }
        else{
          onTime++;
        }
      }
      if(cancelled == 0){
        if(delayed == 0){
          flightsCancelledLabels.add("On-Time");
        }
        flightsCancelledLabels.add("Delayed");
        flightsCancelledLabels.add("On-Time");
      }
      else if(delayed == 0){
        flightsCancelledLabels.add("Cancelled");
        flightsCancelledLabels.add("On-Time");
      }
      else if(onTime == 0){
        flightsCancelledLabels.add("Cancelled");
        flightsCancelledLabels.add("Delayed");
      }
      else{
        flightsCancelledLabels.add("Cancelled");
        flightsCancelledLabels.add("Delayed");
        flightsCancelledLabels.add("On-Time");
      }
      String[] cancelledDelayedOnTime = new String[flightsCancelledLabels.size()];
      for(int i = 0; i < flightsCancelledLabels.size(); i++){
        cancelledDelayedOnTime[i] = flightsCancelledLabels.get(i);
      }
      return cancelledDelayedOnTime;
    }
    //Niko Charles 9:00 27/03/2026 write method
    float[] getNumberOfFlightsCancelled(){
      float cancelled = 0;
      float delayed = 0;
      float onTime = 0;
      String actualDepartTimeString;
      String scheduledDepartTimeString;
      int actualDepartTime;
      int scheduledDepartTime;
      ArrayList<Float> flightsCancelledData = new ArrayList<Float>();
      for(int i = 0; i < flightsLeaving.size(); i++){
        actualDepartTimeString = flightsLeaving.get(i).getActualDepartureTime();
        scheduledDepartTimeString = flightsLeaving.get(i).getScheduledDepartureTime();
        if(actualDepartTimeString != null && scheduledDepartTimeString != null && !actualDepartTimeString.trim().isEmpty()
            && !scheduledDepartTimeString.trim().isEmpty()){
          actualDepartTime = Integer.valueOf(actualDepartTimeString.trim());
          scheduledDepartTime = Integer.valueOf(scheduledDepartTimeString.trim());
        }
        else{
          actualDepartTime = 0;
          scheduledDepartTime = 0;
        }
        if(flightsLeaving.get(i).getFlightCancelled() == 1){
          cancelled++;
        }
        else if(actualDepartTime > scheduledDepartTime){
          delayed++;
        }
        else{
          onTime++;
        }
      }
      if(cancelled == 0){
        if(delayed == 0){
          flightsCancelledData.add(onTime);
        }
        flightsCancelledData.add(delayed);
        flightsCancelledData.add(onTime);
      }
      else if(delayed == 0){
        flightsCancelledData.add(cancelled);
        flightsCancelledData.add(onTime);
      }
      else if(onTime == 0){
        flightsCancelledData.add(cancelled);
        flightsCancelledData.add(delayed);
      }
      else{
        flightsCancelledData.add(cancelled);
        flightsCancelledData.add(delayed);
        flightsCancelledData.add(onTime);
      }
      float[] cancelledDelayedOnTime = new float[flightsCancelledData.size()];
      for(int i = 0; i < flightsCancelledData.size(); i++){
        cancelledDelayedOnTime[i] = flightsCancelledData.get(i);
      }
      return cancelledDelayedOnTime;
    }

    //Niko Charles 9:00 27/03/2026 write method
    void setPieChartValues(Charts thisPieChart) {
      if (!this.setGraphValues) {
        if(getNumberOfFlightsCancelled() != null){}
        pieGraphTitle = "On-Time Flights";
        pieValues = getNumberOfFlightsCancelled();
        pieLabels = getPieChartLabels();
        thisPieChart.addPieChart(pieGraphTitle, pieLabels, pieValues, PIE_CHART_X_COORDINATE, PIE_CHART_Y_COORDINATE, PIE_CHART_DIAMETER, pieColors);
        setGraphValues(true);
      }
    }

    void airportDraw(String airportName){
      //Niko Charles 2:00 25/03/2026 create method
      //Jesse Margarites background color and text
      background(BACKGROUND_COLOR);
      stroke(255);
      strokeWeight(2);
      noFill();

      PFont TITLE_FONT = createFont("Helvetica Bold", HEADINGS_SIZE);
      PFont LABEL_FONT = createFont("Helvetica Bold", SUBHEADINGS_SIZE);
      PFont SMALL_FONT = createFont("Helvetica", TEXT_SIZE);
      
      int textXCoordinate = 20;
      int textYCoordinate = 80;
      fill(255);
      textFont(TITLE_FONT);
      text(airportName, textXCoordinate, textYCoordinate);
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



