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
    public boolean equals(Object obj) {
      if (this == obj) return true;
      if (obj == null || !(obj instanceof Airport)) return false;
      Airport other = (Airport) obj;
      return this.airportName.equals(other.airportName);
    }


    
}



