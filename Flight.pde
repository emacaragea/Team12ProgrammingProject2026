// 4PM, 17/03/26, Jesse Margarites
class Flight{
    //fileds may be empty
    private String flightDate;
    private String airlineCode;
    private int flightNumber;
    private Airport originAirport, destinationAirport;
    private String scheduledDepartureTime; 
    private String actualDepartureTime; 
    private String scheduledArrivalTime;
    private String actualArrivalTime;
    private int flightCancelled; //1=yes
    private int flightDiverted; //1=yes
    private  double airportDistanceInMiles;
    public Flight(String flightDate, String airlineCode, int flightNumber, Airport originAirport, Airport destinationAirport, String scheduledDepartureTime, String actualDepartureTime,
            String scheduledArrivalTime, String actualArrivalTime, int flightCancelled, int flightDiverted,
            double airportDistanceInMiles) {
        this.flightDate = flightDate;
        this.airlineCode = airlineCode;
        this.flightNumber = flightNumber;
        this.originAirport = originAirport;
        this.destinationAirport = destinationAirport;
        this.scheduledDepartureTime = scheduledDepartureTime;
        this.actualDepartureTime = actualDepartureTime;
        this.scheduledArrivalTime = scheduledArrivalTime;
        this.actualArrivalTime = actualArrivalTime;
        this.flightCancelled = flightCancelled;
        this.flightDiverted = flightDiverted;
        this.airportDistanceInMiles = airportDistanceInMiles;
    }
    //Not sure if we will need se methods but I implemented them for now
    public String getFlightDate() {
        return flightDate;
    }
    public void setFlightDate(String flightDate) {
        this.flightDate = flightDate;
    }
    public String getAirlineCode() {
        return airlineCode;
    }
    public void setAirlineCode(String airlineCode) {
        this.airlineCode = airlineCode;
    }
    public Airport getOriginAirport() {
        return originAirport;
    }
    public void setOriginAirport(Airport originAirport) {
        this.originAirport = originAirport;
    }
    public Airport getDestinationAirport() {
        return destinationAirport;
    }
    public void setDestinationAirport(Airport destinationAirport) {
        this.destinationAirport = destinationAirport;
    }
    public String getScheduledDepartureTime() {
        return scheduledDepartureTime;
    }
    public void setScheduledDepartureTime(String scheduledDepartureTime) {
        this.scheduledDepartureTime = scheduledDepartureTime;
    }
    public String getActualDepartureTime() {
        return actualDepartureTime;
    }
    public void setActualDepartureTime(String actualDepartureTime) {
        this.actualDepartureTime = actualDepartureTime;
    }
    public String getScheduledArrivalTime() {
        return scheduledArrivalTime;
    }
    public void setScheduledArrivalTime(String scheduledArrivalTime) {
        this.scheduledArrivalTime = scheduledArrivalTime;
    }
    public String getActualArrivalTime() {
        return actualArrivalTime;
    }
    public void setActualArrivalTime(String actualArrivalTime) {
        this.actualArrivalTime = actualArrivalTime;
    }
    public int getFlightCancelled() {
        return flightCancelled;
    }
    public void setFlightCancelled(int flightCancelled) {
        this.flightCancelled = flightCancelled;
    }
    public int getFlightDiverted() {
        return flightDiverted;
    }
    public void setFlightDiverted(int flightDiverted) {
        this.flightDiverted = flightDiverted;
    }
    public double getAirportDistanceInMiles() {
        return airportDistanceInMiles;
    }
    public void setAirportDistanceInMiles(double airportDistanceInMiles) {
        this.airportDistanceInMiles = airportDistanceInMiles;
    }
    
    
}

// Ema Caragea, route detail screen, 15/3/2026, 14:00
void drawRoutePage() {
  background(10, 15, 25);

  // safety check — if nothing selected, go back
  if (selectedArc == null) {
    currentScreen = 0;
    return;
  }

  // title
  fill(255);
  textFont(fontBold);
  textSize(28);
  textAlign(CENTER, TOP);
  text(selectedArc.origin.code + "  →  " + selectedArc.destination.code, width / 2, 60);

  // city names
  textSize(16);
  fill(180, 210, 255);
  text(selectedArc.origin.city + "  to  " + selectedArc.destination.city, width / 2, 100);

  // status box
  textSize(18);
  if (selectedArc.status.equals("onTime")) {
    fill(0, 200, 100);
    text("Status: On Time", width / 2, 150);
  } else if (selectedArc.status.equals("delayed")) {
    fill(255, 200, 0);
    text("Status: Delayed", width / 2, 150);
  } else {
    fill(255, 60, 60);
    text("Status: Cancelled", width / 2, 150);
  }

  textFont(fontRegular);
  drawBackButton();
}

// to be removed once the header is added
void drawBackButton() {
  fill(0, 160, 230);
  noStroke();
  rect(20, 20, 100, 35, 8);

  fill(255);
  textFont(fontBold);
  textSize(13);
  textAlign(CENTER, CENTER);
  text("< Back", 70, 37);
  textFont(fontRegular);

  if (mousePressed && mouseX > 20 && mouseX < 120 && mouseY > 20 && mouseY < 55) {
    currentScreen = 0;
  }
}