//4PM, 17/03/26, Jesse Margarites
//cannot make fonts static

class State {
  private String stateName;
  private ArrayList<Airport> listOfAirports;
  private String graphTitle;
  private String[] barLabels;
  private int[] barValues;
  private color[] barColors;
  Charts charts;
  private float chartWidth; //Set these values
  private float chartHeight;
  private boolean setGraphValues;
  private int pageNumber;






  State(String stateName) {
    this.stateName = stateName;
    this.listOfAirports = new ArrayList<Airport>(); //Since every state has an airport
    //4PM, 19/03/26, Jesse Margarites updated and fixed
    charts = new Charts();
    setGraphValues =false;
    pageNumber=1;
  }
  //4PM, 19/03/26, Jesse Margarites updated and fixed
  void setGraphValues(boolean setGraphValues) {
    this.setGraphValues = setGraphValues;
  }
  void setStateName(String stateName) {
    this.stateName = stateName;
  }
  String getStateName() {
    return stateName;
  }
  void addAirport(Airport airportX) {
    if (!listOfAirports.contains(airportX)) {
      listOfAirports.add(airportX);
    }
  }
  Airport getAirport(String airportName) {
    //HAS TO BE EXACT NAME
    //could create a method for if they are searching for an airport that is in a different state
    if (listOfAirports!=null) {
      int numberOfAiports = listOfAirports.size();
      int counter =0;
      while (counter<numberOfAiports) {
        if (listOfAirports.get(counter).getAirportName().equals(airportName)) {
          return listOfAirports.get(counter);
        }

        counter++;
      }
      return null;
    }
    //NO AIRPORT IS NULL
    return null;
  }
  int getNumberOfAirports() {
    return listOfAirports.size();
  }

  ArrayList<Airport> getAirportList() {
    return listOfAirports;
  }

  void setBarGraphValues(Charts thisBarGraph) {
    //12:00 PM, 18/03/2026, Niko write set bar graph values
    //4PM, 19/03/26, Jesse Margarites updated and fixed
    if (!this.setGraphValues) {
      println("test");
      graphTitle = "Flight per airport " + stateName;
      int barLabelsLength = listOfAirports.size();
      barLabels = new String[barLabelsLength];
      barValues = new int[barLabelsLength];
      barColors = new int[barLabelsLength];
      for (int i = 0; i<listOfAirports.size(); i++) {
        barLabels[i] = listOfAirports.get(i).getAirportName();
        barColors[i] = color(54, 110, 190);
        barValues[i] = listOfAirports.get(i).getNumberOfFlightsLeaving();
      }
      thisBarGraph.addBarChart(graphTitle, barLabels, barValues, 63, SCREEN_HEIGHT-260, 300, 200, barColors, true);
      setGraphValues(true);
    }
  }

  void stateDraw(String stateName) {
    //10PM, 24/03, Jesse Margarites, improving draw aesthetics
    background(BACKGROUND_COLOR);

    PFont TITLE_FONT = createFont("Helvetica Bold", 24);
    PFont LABEL_FONT = createFont("Helvetica Bold", 16);
    PFont SMALL_FONT = createFont("Helvetica", 13);
    //example
    int textXCoordinate = 20;
    int textYCoordinate = 25;
    textFont(TITLE_FONT);
    text(stateName, textXCoordinate-10, textYCoordinate);
    textFont(LABEL_FONT);
    textYCoordinate+=40;
    text("Airports: ", textXCoordinate, textYCoordinate);
    if (pageNumber==1) {
      for (int counter=0; counter<15; counter++) {
        textYCoordinate+=20;
        text((counter+1)+": "+ listOfAirports.get(counter).getAirportName().substring(0, listOfAirports.get(counter).getAirportName().length()-4), textXCoordinate, textYCoordinate);
      }
    } else if (pageNumber==2) {
      for (int counter=15; counter<listOfAirports.size(); counter++) {
        textYCoordinate+=20;
        text((counter+1)+": "+ listOfAirports.get(counter).getAirportName().substring(0, listOfAirports.get(counter).getAirportName().length()-4), textXCoordinate, textYCoordinate);
      }
    }
    textFont(LABEL_FONT);
    textYCoordinate+=40;
    text("Graphs: ", textXCoordinate, textYCoordinate);

        //niko charles
        stroke(255);
        strokeWeight(2);
        noFill();

        line(STATE_BACK_ARROW_X, STATE_BACK_ARROW_Y, STATE_BACK_ARROW_X+ARROW_LENGTH, STATE_BACK_ARROW_Y);

        line(STATE_BACK_ARROW_X, STATE_BACK_ARROW_Y, STATE_BACK_ARROW_X+ARROW_HEIGHT, STATE_BACK_ARROW_Y-ARROW_HEIGHT);
        line(STATE_BACK_ARROW_X, STATE_BACK_ARROW_Y, STATE_BACK_ARROW_X+ARROW_HEIGHT, STATE_BACK_ARROW_Y+ARROW_HEIGHT);

        line(STATE_FORWARD_ARROW_X, STATE_FORWARD_ARROW_Y, STATE_FORWARD_ARROW_X + ARROW_LENGTH, STATE_FORWARD_ARROW_Y);
        line(STATE_FORWARD_ARROW_X + ARROW_LENGTH, STATE_FORWARD_ARROW_Y,
            STATE_FORWARD_ARROW_X + ARROW_LENGTH - ARROW_HEIGHT, STATE_FORWARD_ARROW_Y - ARROW_HEIGHT);

        line(STATE_FORWARD_ARROW_X + ARROW_LENGTH, STATE_FORWARD_ARROW_Y,
            STATE_FORWARD_ARROW_X + ARROW_LENGTH - ARROW_HEIGHT, STATE_FORWARD_ARROW_Y + ARROW_HEIGHT);
  }
}

