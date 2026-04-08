import java.util.Comparator; //Amanda de moraes, 18/03/26, Comparator interface
// 4PM, 17/03/26, Jesse Margarites
//4PM, 19/03/26, Jesse Margarites fixed some errors
class Flight{
    //fileds may be empty
    private String flightDate;
    private String airlineCode;
    private int flightNumber;
    private int delayedAmount;
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
        this.setFlightDelayAmount(this.scheduledArrivalTime, this.actualArrivalTime);
    }
    //Not sure if we will need se methods but I implemented them for now
    String getFlightDate() {
        return flightDate;
    }
    void setFlightDate(String flightDate) {
        this.flightDate = flightDate;
    }
    void setFlightNumber(int flightNumber){
        this.flightNumber = flightNumber;
    }
    int getFlightNumber(){
        return flightNumber;
    }
    String getAirlineCode() {
        return airlineCode;
    }
    void setAirlineCode(String airlineCode) {
        this.airlineCode = airlineCode;
    }
    Airport getOriginAirport() {
        return originAirport;
    }
    void setOriginAirport(Airport originAirport) {
        this.originAirport = originAirport;
    }
    Airport getDestinationAirport() {
        return destinationAirport;
    }
    void setDestinationAirport(Airport destinationAirport) {
        this.destinationAirport = destinationAirport;
    }
    String getScheduledDepartureTime() {
        return scheduledDepartureTime;
    }
    void setScheduledDepartureTime(String scheduledDepartureTime) {
        this.scheduledDepartureTime = scheduledDepartureTime;
    }
    String getActualDepartureTime() {
        return actualDepartureTime;
    }
    void setActualDepartureTime(String actualDepartureTime) {
        this.actualDepartureTime = actualDepartureTime;
    }
    String getScheduledArrivalTime() {
        return scheduledArrivalTime;
    }
    void setScheduledArrivalTime(String scheduledArrivalTime) {
        this.scheduledArrivalTime = scheduledArrivalTime;
    }
    String getActualArrivalTime() {
        return actualArrivalTime;
    }
    void setActualArrivalTime(String actualArrivalTime) {
        this.actualArrivalTime = actualArrivalTime;
    }
    int getFlightCancelled() {
        return flightCancelled;
    }
    void setFlightCancelled(int flightCancelled) {
        this.flightCancelled = flightCancelled;
    }
    int getFlightDiverted() {
        return flightDiverted;
    }
    void setFlightDiverted(int flightDiverted) {
        this.flightDiverted = flightDiverted;
    }
    double getAirportDistanceInMiles() {
        return airportDistanceInMiles;
    }
    void setAirportDistanceInMiles(double airportDistanceInMiles) {
        this.airportDistanceInMiles = airportDistanceInMiles;
    }
    //Niko Charles 11:00, 08/04 write method
    void setFlightDelayAmount(String scheduledArrivalTime, String actualArrivalTime){
        String actualArrivalTimeString;
        String scheduledArrivalTimeString;
        int actualArrivalTimeInt;
        int scheduledArrivalTimeInt;
        actualArrivalTimeString = this.getActualArrivalTime();
        scheduledArrivalTimeString = this.getScheduledArrivalTime();
        if (actualArrivalTimeString != null && scheduledArrivalTimeString != null && !actualArrivalTimeString.trim().isEmpty()
            && !scheduledArrivalTimeString.trim().isEmpty()) {
                actualArrivalTimeInt = Integer.valueOf(actualArrivalTimeString.trim());
                scheduledArrivalTimeInt = Integer.valueOf(scheduledArrivalTimeString.trim());
        }else {
            actualArrivalTimeInt = 0;
        scheduledArrivalTimeInt = 0;
        }
        this.delayedAmount = Math.abs(actualArrivalTimeInt-scheduledArrivalTimeInt);
    }

    int getDelayedAmount(){
        return delayedAmount;
    }
    //Amanda de moraes, 18/3, 1:09
    //comparators for the sorting table and helper methods for the format method
     //comparators

    // comparator to sort flights by flight number (ascending)
    Comparator<Flight> sortByFlightNum = new Comparator<Flight>() {
        public int compare(Flight a, Flight b) {
            return Integer.compare(a.flightNumber, b.flightNumber);
        }
    };
    //comparator to sort flights by distance (ascending)
    Comparator<Flight> sortByDistance = new Comparator<Flight>() {
        public int compare(Flight a, Flight b) {
            return Double.compare(a.airportDistanceInMiles, b.airportDistanceInMiles);
        }
    };

    //Niko Charles 11:00, 08/04 
    //comparotor to sort flights by lateness (ascending)
    Comparator<Flight> sortByLateness = new Comparator<Flight>() {
        public int compare(Flight a, Flight b) {
            return Integer.compare(a.delayedAmount, b.delayedAmount);
        }
    };
    
    
}
