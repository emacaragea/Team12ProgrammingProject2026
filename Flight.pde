import java.util.Comparator; //Amanda de moraes, 18/03/26, Comparator interface
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
    
    
}
