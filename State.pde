//4PM, 17/03/26, Jesse Margarites
//cannot make fonts static 

class State{
    private String stateName;
    private ArrayList<Airport> listOfAirports;


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
        if(!listOfAirports.contains(airportX)){
            listOfAirports.add(airportX);
        }
        
    }
    Airport getAirport(String airportName){
        //HAS TO BE EXACT NAME
        //could create a method for if they are searching for an airport that is in a different state 
        if(listOfAirports!=null){
            int numberOfAiports = listOfAirports.size();
            int counter =0;
            while(counter<numberOfAiports){
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

    void stateDraw(String stateName){
        PFont TITLE_FONT = createFont("Helvetica Bold", 24);
        PFont LABEL_FONT = createFont("Helvetica Bold", 16);
        PFont SMALL_FONT = createFont("Helvetica", 13);
        //example
        int textXCoordinate = 20;
        int textYCoordinate = 20;
        textFont(TITLE_FONT);
        text(stateName, textXCoordinate, textYCoordinate);

        textFont(LABEL_FONT);
        textYCoordinate+=40;
        text("Airports: ", textXCoordinate, textYCoordinate);

        for (int counter=0; counter<listOfAirports.size(); counter++){
            textYCoordinate+=20;
            text((counter+1)+": "+ listOfAirports.get(counter).getAirportName(), textXCoordinate, textYCoordinate);

        }


    }

}