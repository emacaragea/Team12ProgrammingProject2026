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



