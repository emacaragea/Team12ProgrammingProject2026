//12PM, 17/03/26, Jesse Margarites
class Airport{
    private String airportName;
    private int worldAreaCode;
    private ArrayList<Flight> flightsLeaving;
    private ArrayList<Flight> flightsIncoming;
    Airport(String airportName, int worldAreaCode){
        this.airportName = airportName;
        this.worldAreaCode = worldAreaCode;
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
        flightsLeaving.add(flightX); //CHECK WORKS
    }
    void addFlightsIncoming(Flight flightX){
        flightsLeaving.add(flightX); //CHECK WORKS
    }


    
}

