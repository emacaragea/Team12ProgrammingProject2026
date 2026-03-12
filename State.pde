class State{
    String stateName;
    ArrayList<Airport> listOfAirports;

    State(String stateName){
        this.stateName = stateName;
        this.listOfAirports = new ArrayList<Airport>(); //Since every state has an airport
    }
    void setStateName(String stateName){
        this.stateName = stateName;
    }
    String getStateName(){
        return stateName;
    }
    void addAirport(Airport airportX){
        listOfAirports.add(airportX);
        
    }
    Airport getAirport(String airportName){
        //HAS TO BE EXACT NAME
        //could create a method for if they are searching for an airport that is in a different state 
        if(listOfAirports!=null){
            boolean foundAirport = false;
            int numberOfAiports = listOfAirports.size();
            int counter =0;
            while(!foundAirport || counter<numberOfAiports){
                if (listOfAirports.get(counter).getAirportName().equals(airportName)){
                    return listOfAirports.get(counter);
                }

                counter++;
            }
            return null;
        }
        //NO AIRPORT IS NULL
        return null;
    }
    
    ArrayList<Airport> getAirportList(){
        return listOfAirports;
    }

}