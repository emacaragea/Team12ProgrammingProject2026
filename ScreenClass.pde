//niko 10:00 AM 12/03/26 create and outline screen class
//niko 10:30 AM 12/03/26 write screenDraw and drawHomeBar
//niko 12:00 PM 18/03/26 code home bar button functions
import java.util.ArrayList;
static final int HOME_BAR_HEIGHT = 50;
 final color ON_TIME_COLOR = color(129, 199, 132);
 final color DELAYED_COLOR = color(255, 183, 77);
 final color CANCELLED_COLOR = color(239, 83, 80);

class Screen{
    private int screenType;
    private int lastScreenType;
    private Airport selectedAirport;
    private String selectedAirportName;
    private ArrayList<Integer> screenHistory = new ArrayList<Integer>();
    private ArrayList<State> stateList = new ArrayList<State>();
    private ArrayList<Airport> airportList = new ArrayList<Airport>();
    private int screenHistoryIndex = 0;
    private int currentStateIndex;
    private int currentAirportIndex;
    private Airport lastAirport = null;
    final int HOME_SCREEN = 1;
    final int AIRPORT_SCREEN = 2;
    final int STATE_SCREEN = 3;
    final int FLIGHT_SCREEN = 4;
    final int LOADING_SCREEN = 5;
    final int BACK_ARROW_X = 15;
    final int BACK_ARROW_Y = 25;
    final int FORWARD_ARROW_X = 85;
    final int FORWARD_ARROW_Y = 25;
    final int ARROW_HEIGHT = 6;
    final int ARROW_LENGTH = 20;
    final int HOME_BUTTON_X = 50;
    final int HOME_BUTTON_Y = 23;
    final int HOME_BUTTON_SIZE = 13;
    final int HOME_BUTTON_HEIGHT = 11;

    final color HOME_BAR_COLOR = color(82, 156, 214);
    final color HOME_BAR_STROKE_COLOR = color(0, 120, 200);
    final color HOME_BAR_BACKGROUND_COLOR = color(20, 28, 38);

    //amanda de moraes, 19/3/26, 10AM, added search bar
    final int SEARCHX= 1070;
    final int SEARCHY =12;
    final int SEARCHW= 260;
    final int SEARCHH=28;

    
    boolean searchActive = false;
    String searchText ="";
    ArrayList<Airport> filteredAirports = new ArrayList<Airport>();
    final int SUGGESTION_HEIGHT = 30;
    final int MAX_SUGGESTIONS = 5;
    

    //3PM, 19/03/26, Jesse Margarites
    Charts thisChart;

    //Method to instantiate a new screen
    //Called in main to create screen1 and screen2 (state and airport screen)
    Screen(int type){
        screenType = type;
        //3PM, 19/03/26, Jesse Margarites
        thisChart = new Charts();
        
    }

    //Sets the screen type of a screen object
    //Called in handleSearchKey to instantiate new screen based on selected airport
    void setScreenType(int type){
        screenHistory.add(type);
        screenHistoryIndex++;
        screenType = type;
    }
    
    //Sets the selected airport if the screen type is AIRPORT_SCREEN (2)
    //Called in handleSearchKey to instantiate new screen based on selected airport
    void setSelectedAirport(Airport airport){
        this.selectedAirport = airport;
        this.selectedAirportName = airport.getAirportName();

    }

    //Returns current screenType
    int getScreenType(){
        return screenType;
    }

    //Draws the home bar and home and back button
    //Draws the buttons in different color when mouse is hovering over them or button is clicked
    //Called in main draw method for all screens being drawn
    void drawHomeBar(){
        pushStyle();
        fill(200);
        //rect(0, 0, 1400, 40);
        //draw backArrow
        noStroke();
        fill(HOME_BAR_COLOR);
        rect(0, 0, width, HOME_BAR_HEIGHT);

        stroke(HOME_BAR_STROKE_COLOR);
        strokeWeight(1);
        line(0, HOME_BAR_HEIGHT, width, HOME_BAR_HEIGHT);
        stroke(255);
        strokeWeight(2);
        noFill();


        //drawBackArrow
        if (mouseX >= BACK_ARROW_X && mouseX <= BACK_ARROW_X + ARROW_LENGTH &&
          mouseY >= BACK_ARROW_Y-ARROW_HEIGHT && mouseY <= BACK_ARROW_Y + ARROW_HEIGHT) {
          stroke(200, 200, 255);
        } else {
          stroke(255);
        }
        line(BACK_ARROW_X, BACK_ARROW_Y, BACK_ARROW_X+ARROW_LENGTH, BACK_ARROW_Y);

        line(BACK_ARROW_X, BACK_ARROW_Y, BACK_ARROW_X+ARROW_HEIGHT, BACK_ARROW_Y-ARROW_HEIGHT);
        line(BACK_ARROW_X, BACK_ARROW_Y, BACK_ARROW_X+ARROW_HEIGHT, BACK_ARROW_Y+ARROW_HEIGHT);
        
        //drawHomeButton
        if (mouseX >= HOME_BUTTON_X-1 && mouseX <= HOME_BUTTON_X + HOME_BUTTON_SIZE+1 &&
          mouseY >= HOME_BUTTON_Y - HOME_BUTTON_SIZE/2 && mouseY <= HOME_BUTTON_Y + HOME_BUTTON_HEIGHT) {
          stroke(200, 200, 255);
        } else {
          stroke(255);
        }
        rect(HOME_BUTTON_X, HOME_BUTTON_Y, HOME_BUTTON_SIZE, HOME_BUTTON_HEIGHT);
        pushStyle();
        strokeWeight(3);
        stroke(HOME_BAR_COLOR);
        line(HOME_BUTTON_X, HOME_BUTTON_Y, HOME_BUTTON_X + HOME_BUTTON_SIZE, HOME_BUTTON_Y);
        popStyle();
        line(HOME_BUTTON_X-2, HOME_BUTTON_Y, HOME_BUTTON_SIZE/2 + HOME_BUTTON_X, HOME_BUTTON_Y - HOME_BUTTON_SIZE/2);
        line(HOME_BUTTON_X + HOME_BUTTON_SIZE+2, HOME_BUTTON_Y, HOME_BUTTON_X + HOME_BUTTON_SIZE/2, 
            HOME_BUTTON_Y - HOME_BUTTON_SIZE/2);
        popStyle();

    }


    //Amanda de moraes, 19/3, added seach bar
    //Draws SearchBar
    //Called in main if the currentScreen is the home screen
    void drawSearchBar(){
          boolean hover = mouseX >= SEARCHX && mouseX <= SEARCHX + SEARCHW &&
                    mouseY >= SEARCHY && mouseY <= SEARCHY + SEARCHH;

    if (searchActive) fill(120, 190, 245);
    else if (hover) fill(90, 110, 130);
    else fill(70, 90, 110);

    stroke(255);
    strokeWeight(1.5);
    rect(SEARCHX, SEARCHY, SEARCHW, SEARCHH, 8);

    textAlign(LEFT, CENTER);
    textSize(13);

    if (searchText.length() == 0 && !searchActive) {
        fill(150);
        text("Search airport...", SEARCHX + 10, SEARCHY + SEARCHH / 2);
    } else {
        fill(10);
        text(searchText, SEARCHX + 10, SEARCHY + SEARCHH / 2);
    }

    // draw suggestions
    if (!searchActive || filteredAirports.size() == 0) return;

    for (int i = 0; i < filteredAirports.size() && i < MAX_SUGGESTIONS; i++) {
        int boxY = SEARCHY + SEARCHH + (i * SUGGESTION_HEIGHT);

        boolean hov = mouseX >= SEARCHX && mouseX <= SEARCHX + SEARCHW &&
                      mouseY >= boxY && mouseY <= boxY + SUGGESTION_HEIGHT;

        fill(hov ? color(90,110,130) : color(50,65,82));
        stroke(255);
        rect(SEARCHX, boxY, SEARCHW, SUGGESTION_HEIGHT);

        fill(240);
        textAlign(LEFT, CENTER);
        text(filteredAirports.get(i).getAirportName(),
             SEARCHX + 10, boxY + SUGGESTION_HEIGHT / 2);
    }
       
    }

    //Amanda de Moraes, 19/3, added method to update search suggestions based on current search text
    void updateSearchSuggestions() {
    filteredAirports.clear();

    String input = searchText.toLowerCase().trim();
    if (input.equals("")) return;

    for (Airport a : airportList) {
        if (a.getAirportName().toLowerCase().startsWith(input)) {
            filteredAirports.add(a);
        }
        if (filteredAirports.size() >= MAX_SUGGESTIONS) break;
    }
}

//Amanda de Moraes, 19/3, added method to handle clicks on the search bar and suggestions
 void handleSearchClick(int mx, int my) {

    // click search bar
    if (mx >= SEARCHX && mx <= SEARCHX + SEARCHW &&
        my >= SEARCHY && my <= SEARCHY + SEARCHH) {
        searchActive = true;
        return;
    }

    // click suggestions
    for (int i = 0; i < filteredAirports.size() && i < MAX_SUGGESTIONS; i++) {
        int boxY = SEARCHY + SEARCHH + (i * SUGGESTION_HEIGHT);

        if (mx >= SEARCHX && mx <= SEARCHX + SEARCHW &&
            my >= boxY && my <= boxY + SUGGESTION_HEIGHT) {

            Airport chosen = filteredAirports.get(i);
            searchText = chosen.getAirportName();

            searchActive = false;
            filteredAirports.clear();
//Niko Charles connected the search click to navigate to airport screen
            airportName = chosen.getAirportName();
            thisAirport = chosen;
            currentView = CURRENT_VIEW_AIRPORT;
            viewHistIndex++;
            viewHistory.add(viewHistIndex, currentView);
            screen2 = new Screen(2);
            return;
        }
    }

    searchActive = false;
}


// Amanda de Moraes, 19/3, added method to handle key presses when search bar is active, including backspace, enter, and character input
void handleSearchKey(char key, int keyCode) {
    if (!searchActive) return;

    if (keyCode == BACKSPACE) {
        if (searchText.length() > 0) {
            searchText = searchText.substring(0, searchText.length() - 1);
            updateSearchSuggestions();
        }
        return;
    }

    if (keyCode == ENTER || keyCode == RETURN) {
        if (filteredAirports.size() > 0) {
            Airport chosen = filteredAirports.get(0);
            searchText = chosen.getAirportName();
            setSelectedAirport(chosen);
            setScreenType(AIRPORT_SCREEN);
            searchActive = false;
            filteredAirports.clear();
        }
        return;
    }

    if (Character.isLetterOrDigit(key) || key == ' ')  {
        searchText += key;
        updateSearchSuggestions();
    }
}


    //Jesse Margarits, 04/04, Fixing airport screen bug
    //Jesse Margarites, 2AM, 08/04, implemented methods to initalise airport from search bar

    //Draws the airport screen, loads in data, fills pie charts
    //Called in main method if currentScreen is set to airport screen
    void drawAirportScreen(Airport thisAirport, String airportName){
        if(!thisAirport.getSetArrivalAirports()){
            readFileByAirport(thisAirport.getOriginCityCode(), thisAirport, "dest");
            thisAirport.setSetArrivalAirports(true);

        }

        if(thisAirport.getNumberOfFlightsLeaving()==0){
            readFileByAirport(thisAirport.getOriginCityCode(), thisAirport, "dest");
            readFileByAirport(thisAirport.getOriginCityCode(), thisAirport, "origin");
        }

        if(!airportList.contains(thisAirport)){
            airportList.add(thisAirport);
            currentAirportIndex = airportList.size()-1;

        }

        //Niko Charles 14:00 02/04/2026 fix pie charts set and draw 
        if (thisAirport != lastAirport) {
            thisChart.clearCharts();
            thisAirport.setPieChartValues(thisChart);
            lastAirport = thisAirport;
        }
        //thisAirport.setPieChartValues(thisChart);
        thisAirport.airportDraw(airportName);
        pushStyle();
        thisChart.chartsDraw();
        popStyle();
    }

    //Draws state screen and creates heatmap 
    //Called in main if currentScreen is set to state screen
    void drawStateScreen(String code, State thisState, String stateName){
        //4PM, 18/03/26, Jesse Margarites
        if(stateList.isEmpty() || !stateList.contains(thisState)){ //dont think this will work for more states
        stateList.add(thisState);
        currentStateIndex = stateList.size()-1;
        readFileByState(code, thisState);
        }

        // Orla Kealy, 21:00 PM, 01/04/2026
        // Description: Sets data for state heat map
        if (thisState.stateHeatMap == null)
        {
            PImage img = loadImage("data/USStateOutlines/" + stateName.trim() + ".jpg"); 
            float maxHeight = SCREEN_HEIGHT / 3 + 100;
            img.resize(0, (int) maxHeight); 
            thisState.stateHeatMap = new StateHeatMap(code, img); 
            thisState.setBarGraphValues(thisChart);
        }
        thisState.setHeatMapValues();

        thisState.stateDraw(stateName);
        thisChart.chartsDraw();
        airportList = thisState.getAirportList();
    }

//Jesse Margarites, 11AM, 26/03, updated moused pressed
//Mouse pressed method for the bar chart on the state screen, search bar clicks, and flight screen table
//Called in main method depending on screen type
    void mousePressed() {
        handleSearchClick(mouseX, mouseY);
        //goHome(mouseX, mouseY);
        if (screenType == STATE_SCREEN) {
            thisChart.mousePressed();
        }
        

        if (screenType == FLIGHT_SCREEN) {
            tableMousePressed();
        }

    }

//Jesse Margarites, 11AM, 26/03, updated key pressed
//Key pressed method for the search bar and for bar chart on state screen
//Called in main method
    void keyPressed(char key, int keyCode){
        handleSearchKey(key,keyCode);

        if(screenType==STATE_SCREEN){
            thisChart.keyPressed(key);
        }
    }

//Method determines if home button was pressed: returns true if the home button has been clicked 
//Called in main method mouse clicked for all screens containing the home bar
    boolean goHome(int mX, int mY){
        if(mouseX >= HOME_BUTTON_X-1 && mouseX <= HOME_BUTTON_X + HOME_BUTTON_SIZE+1 &&
          mouseY >= HOME_BUTTON_Y - HOME_BUTTON_SIZE/2 && mouseY <= HOME_BUTTON_Y + HOME_BUTTON_HEIGHT){
                return true;
        }
        return false;
    }

//Method determines if the back button was pressed: returns true if back button has been clicked
//Called in main method mouse clicked for all screens containing the home bar
    boolean goBack(int mX, int mY){
        if(viewHistIndex != 0){
            if(mouseX >= BACK_ARROW_X && mouseX <= BACK_ARROW_X + ARROW_LENGTH &&
                mouseY >= BACK_ARROW_Y-ARROW_HEIGHT && mouseY <= BACK_ARROW_Y + ARROW_HEIGHT){
                return true;
            }
        }
        return false;
    }

}