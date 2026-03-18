//4PM, 17/03/26, Jesse Margarites
//cannot make fonts static 

class State{
    private String stateName;
    private ArrayList<Airport> listOfAirports;
    private String graphTitle;
    private String[] barLabels;
    private int[] barValues;
    private color[] barColors;
    Charts charts;


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

    void setBarGraphValues(){
        graphTitle = "Flight per airport " + stateName;
        String[] barLabels = new String[listOfAirports.size()];
        int[] barValues = new int[listOfAirports.size()];
        color[] barColors = new int[listOfAirports.size()];
        for(int i = 0; i<listOfAirports.size(); i++){
            barLabels[i] = listOfAirports.get(i).getAirportName();
            barColors[i] = color(54, 110, 190);
            barValues[i] = listOfAirports.get(i).getNumberOfFlightsLeaving();
        }
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
        setBarGraphValues();
        textFont(LABEL_FONT);
        textYCoordinate+=40;
        text("Airports: ", textXCoordinate, textYCoordinate);
        charts.addBarChart(graphTitle, barLabels, barValues, 50, 50, 300, 200, barColors, true);
        for (int counter=0; counter<listOfAirports.size(); counter++){
            textYCoordinate+=20;
            text((counter+1)+": "+ listOfAirports.get(counter).getAirportName(), textXCoordinate, textYCoordinate);

        }


    }

}