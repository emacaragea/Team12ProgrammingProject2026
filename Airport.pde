class Airport{
    String airportName;
    ArrayList<Flight> flightsLeaving;
    ArrayList<Flight> flightsIncoming;
    Airport(String airportName){
        this.airportName = airportName;
    }

    void setAirportName(String airportName){
        this.airportName = airportName;
    }
    String getAirportName(){
        return airportName;
    }
    void addFlightsLeaving(Flight flightX){
        flightsLeaving.add(flightX); //CHECK WORKS
    }
    void addFlightsIncoming(Flight flightX){
        flightsLeaving.add(flightX); //CHECK WORKS
    }


    
}

