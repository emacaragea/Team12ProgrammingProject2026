//4PM, 17/03/26, Jesse Margarites
//cannot make fonts static
final int MAX_AIRPORT_DISPLAY = 13;
final private float CHART_WIDTH = 600;
final private float CHART_HEIGHT = 200;
final private int CHART_X_COORDINATE = SCREEN_WIDTH/3+70;
final private int CHART_Y_COORDINATE = 520;

class State {
  private String stateName;
  private ArrayList<Airport> listOfAirports;
  ArrayList<TextLinks> airportLinks = new ArrayList<TextLinks>();
  private String graphTitle;
  private String[] barLabels;
  private int[] barValues;
  private color[] barColors;
  Charts charts;
  private boolean setGraphValues;
  private int pageNumber;
  private StateHeatMap stateHeatMap;

  private String[] heatmapAirports;
  private int[] heatmapCounts;

  PFont TITLE_FONT = createFont("Helvetica Bold", HEADINGS_SIZE);
  PFont LABEL_FONT = createFont("Helvetica Bold", SUBHEADINGS_SIZE);
  PFont SMALL_FONT = createFont("Helvetica", TEXT_SIZE);


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

  //Niko Charles, 10:00, 25/03/2026
  Airport linkClicked(float mx, float my) {
    for (TextLinks ct : airportLinks) {
      if (ct.isMouseOver(mx, my)) {
        return ct.getTextLinkAirport();
      }
    }
    return null;
  }
  //Jesse Margarites, 11AM, 24/03, implementing pageNumber
  int getPageNumber() {
    return pageNumber;
  }
  void setPageNumber(int pageNumber) {
    this.pageNumber = pageNumber;
  }
  Airport getAirport(String airportName) {
    //HAS TO BE EXACT NAME
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
  void stateMousePressed() {
    //Jesse Margarites, 4PM, 24/03 made interactive forward and back buttons for the State screen
    if (thisState.getNumberOfAirports()>MAX_AIRPORT_DISPLAY&&mouseX>=STATE_FORWARD_ARROW_X && mouseX<= STATE_FORWARD_ARROW_X+ARROW_LENGTH
      && mouseY>= STATE_FORWARD_ARROW_Y-ARROW_HEIGHT && mouseY <= STATE_FORWARD_ARROW_Y+ARROW_HEIGHT
      && thisState.getPageNumber()==1) {
      thisState.setPageNumber(2);
    } else if (thisState.getNumberOfAirports()>MAX_AIRPORT_DISPLAY&&mouseX>=STATE_BACK_ARROW_X && mouseX<= STATE_BACK_ARROW_X+ARROW_LENGTH
      && mouseY>= STATE_BACK_ARROW_Y-ARROW_HEIGHT && mouseY <= STATE_BACK_ARROW_Y+ARROW_HEIGHT
      && thisState.getPageNumber()==2) {
      thisState.setPageNumber(1);
    }

  }
  int getNumberOfAirports() {
    return listOfAirports.size();
  }

  ArrayList<Airport> getAirportList() {
    return listOfAirports;
  }

  void airportClicked(){
    Airport clickedAirport = linkClicked(mouseX, mouseY);
    if (clickedAirport != null) {
      airportName = clickedAirport.getAirportName();
      thisAirport = clickedAirport;
      currentView = CURRENT_VIEW_AIRPORT;
      viewHistIndex++;
      viewHistory.add(viewHistIndex, currentView);
      screen2 = new Screen(2);
    }
  }

  void setBarGraphValues(Charts thisBarGraph) {
    //12:00 PM, 18/03/2026, Niko write set bar graph values
    //4PM, 19/03/26, Jesse Margarites updated and fixed
    if (!this.setGraphValues) {
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
      thisBarGraph.addBarChart(graphTitle, barLabels, barValues, CHART_X_COORDINATE, CHART_Y_COORDINATE, CHART_WIDTH, CHART_HEIGHT, barColors, true);
      setGraphValues(true);
    }
  }

  void setHeatMapValues()
  {
    // Orla Kealy, 21:00 PM, 01/04/2026
    // Description: Set array values for heat map
    int size = listOfAirports.size();

    heatmapAirports = new String[size];
    heatmapCounts = new int[size];

    for (int i = 0; i < size; i++)
    {
      Airport a = listOfAirports.get(i);

      heatmapAirports[i] = a.getAirportName();
      heatmapCounts[i] = a.getNumberOfFlightsLeaving();
    }
  }

  void stateDraw(String stateName) {
    //10PM, 24/03, Jesse Margarites, improving draw aesthetics
    //Jesse Margarites, 11AM, 26/03, updated state draw and fixed fonts
    background(BACKGROUND_COLOR);
    stroke(255);
    strokeWeight(2);
    noFill();
    line(SCREEN_WIDTH/3, 0, SCREEN_WIDTH/3, SCREEN_HEIGHT);
    airportLinks.clear();
    //Jesse Margarits, 04/04, Fixing aesthetics of state screen


    //PFont AIPORT_NAMES_FONT = createFont("Trispace", SUBHEADINGS_SIZE);
    //example
    int textXCoordinate = 20;
    int textYCoordinate = 80;
    fill(255);
    textAlign(LEFT,CENTER);
    textFont(TITLE_FONT);
    text(stateName, textXCoordinate-16, textYCoordinate); //was textXcord-10


    fill(255, 255, 255);
    textFont(TITLE_FONT);
    textAlign(LEFT, CENTER);
    textSize(18);
    textYCoordinate+=40;
    text("Airports: ", textXCoordinate, textYCoordinate);
    fill(255, 255, 255);
    int maxCounter;
    
    // Orla Kealy, 21:00 PM, 01/04/2026
    // Description: Draws state heat map
    if (heatmapAirports != null && heatmapCounts != null)
    {
      stateHeatMap.drawStateHeatMap(CHART_X_COORDINATE, 70, heatmapAirports, heatmapCounts);
    }

    if (listOfAirports.size()>MAX_AIRPORT_DISPLAY) {
      maxCounter = MAX_AIRPORT_DISPLAY;
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
    } else {
      maxCounter = listOfAirports.size();
    }

    //Niko Charles 10:00, 25/03/2026 Implemented clickable text links
    if (pageNumber==1) {
      for (int counter=0; counter<maxCounter; counter++) {
        /*textYCoordinate+=35;
         text((counter+1)+": "+ listOfAirports.get(counter).getAirportName().substring(0, listOfAirports.get(counter).getAirportName().length()-4), textXCoordinate, textYCoordinate);
         fill(255, 255, 255);*/
        textYCoordinate += 45;

        Airport airport = listOfAirports.get(counter);
        String name = airport.getAirportName().substring(0, airport.getAirportName().length() - 4);
        String label = (counter + 1) + ": " + name;
        textFont(SMALL_FONT);
        float w = textWidth(label);
        float h = 20;
        if (mouseX >= textXCoordinate && mouseX <= textXCoordinate + w &&
          mouseY >= textYCoordinate - h && mouseY <= textYCoordinate + h/2) {
          fill(200, 200, 255);
        } else {
          fill(255);
        }
        textSize(18);
        textFont(SMALL_FONT);
        text(label, textXCoordinate, textYCoordinate);
        airportLinks.add(new TextLinks(label, textXCoordinate, textYCoordinate, w, h, airport));
      }
    } else if (pageNumber==2&&listOfAirports.size()>MAX_AIRPORT_DISPLAY) {
      for (int counter=MAX_AIRPORT_DISPLAY; counter<listOfAirports.size(); counter++) {
        textFont(SMALL_FONT);
        /*textYCoordinate+=35;
         text((counter+1)+": "+ listOfAirports.get(counter).getAirportName().substring(0, listOfAirports.get(counter).getAirportName().length()-4), textXCoordinate, textYCoordinate);
         fill(255, 255, 255);*/
        textYCoordinate += 45;
        Airport airport = listOfAirports.get(counter);
        String name = airport.getAirportName().substring(0, airport.getAirportName().length() - 4);
        String label = (counter + 1) + ": " + name;
        float w = textWidth(label);
        float h = 20;
        if (mouseX >= textXCoordinate && mouseX <= textXCoordinate + w &&
          mouseY >= textYCoordinate - h && mouseY <= textYCoordinate) {
          fill(200, 200, 255);
        } else {
          fill(255);
        }
        textFont(SMALL_FONT);
        text(label, textXCoordinate, textYCoordinate);
        airportLinks.add(new TextLinks(label, textXCoordinate, textYCoordinate, w, h, airport));
      }
    }
    fill(255, 255, 255);
    textFont(SMALL_FONT);
    text("Click on an airport to see it's details", textXCoordinate, SCREEN_HEIGHT-20);
    
  }
  //Jesse Margarites, 4PM, 24/03, implemented an equals method to Override the contains method
  @Override
    public boolean equals(Object thisObject) {
    if (this == thisObject) {
      return true;
    }
    if (thisObject == null || !(thisObject instanceof Airport)) {
      return false;
    }
    State stateObject = (State) thisObject;
    return this.stateName.equals(stateObject.stateName);
  }
}

