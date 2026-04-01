//niko 10:00 AM 12/03/26 create and outline screen class
//niko 10:30 AM 12/03/26 write screenDraw and drawHomeBar
//niko 12:00 PM 18/03/26 code home bar button functions
import java.util.ArrayList;
static final int HOME_BAR_HEIGHT = 50;
 final color ON_TIME_COLOR = color(129, 199, 132);
 final color DIVERTED_COLOR = color(255, 183, 77);
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

    private boolean setArrivalAirports;
    
    boolean searchActive = false;
    String searchText ="";
    ArrayList<Airport> filteredAirports = new ArrayList<Airport>();
    final int SUGGESTION_HEIGHT = 30;
    final int MAX_SUGGESTIONS = 5;
    

    //3PM, 19/03/26, Jesse Margarites
    Charts thisChart;

    Screen(int type){
        screenType = type;
        //3PM, 19/03/26, Jesse Margarites
        thisChart = new Charts();
        setArrivalAirports = false;
        
    }

    void setScreenType(int type){
        screenHistory.add(type);
        screenHistoryIndex++;
        screenType = type;
    }
    

    void setSelectedAirport(Airport airport){
        this.selectedAirport = airport;
        this.selectedAirportName = airport.getAirportName();

    }


    int getScreenType(){
        return screenType;
    }

    //Jesse Margarites, 4PM, 24/03
        void screenDraw(String code, State thisState, String stateName){
        fill(BACKGROUND_COLOR);
        drawHomeBar();
        switch(screenType){
            case 1:
            drawHomeScreen();
            break;
            case 2:
            //drawAirportScreen(thisAirport, airportName);
            //break;
            case 3:
            drawStateScreen(code, thisState, stateName);
            break;
            case 4:
            drawFlightScreen();
            break;
            case 5:
            drawLoadScreen();
            break;
        }
    }
    //Niko Charles, 10:00, 25/03/2026
    void screenDraw(Airport thisAirport, String airportName){
        fill(BACKGROUND_COLOR);
        drawHomeBar();
        switch(screenType){
            case 1:
            drawHomeScreen();
            break;
            case 2:
            drawAirportScreen(thisAirport, airportName);
            break;
            case 3:
            //drawStateScreen();
            break;
            case 4:
            drawFlightScreen();
            break;
            case 5:
            drawLoadScreen();
            break;
        }
    }

    void screenDraw(){
        fill(BACKGROUND_COLOR);
        drawHomeBar();
        switch(screenType){
            case 1:
            drawHomeScreen();
            break;
            case 2:
            //drawAirportScreen();
            break;
            case 3:
            //drawStateScreen();
            break;
            case 4:
            drawFlightScreen();
            break;
            case 5:
            drawLoadScreen();
            break;
        }
    }

    void drawHomeBar(){
        fill(200);
        //rect(0, 0, 1400, 40);
        //draw backArrow
        //ema home bar background 
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

        //draw forward arrow
        /*line(FORWARD_ARROW_X, FORWARD_ARROW_Y, FORWARD_ARROW_X + ARROW_LENGTH, FORWARD_ARROW_Y);
        line(FORWARD_ARROW_X + ARROW_LENGTH, FORWARD_ARROW_Y,
            FORWARD_ARROW_X + ARROW_LENGTH - ARROW_HEIGHT, FORWARD_ARROW_Y - ARROW_HEIGHT);

        line(FORWARD_ARROW_X + ARROW_LENGTH, FORWARD_ARROW_Y,
            FORWARD_ARROW_X + ARROW_LENGTH - ARROW_HEIGHT, FORWARD_ARROW_Y + ARROW_HEIGHT);*/

            drawSearchBar();
    }


     //amanda de moraes, 19/3, search bar methods
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

            setSelectedAirport(chosen);
            setScreenType(AIRPORT_SCREEN);

            searchActive = false;
            filteredAirports.clear();
            return;
        }
    }

    searchActive = false;
}


// handle key input
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

    void drawHomeScreen(){

    }

    void drawAirportScreen(Airport thisAirport, String airportName){
        if(!setArrivalAirports){
            readFileByDestinationAirport(thisAirport.getOriginCityCode(), thisAirport);
            //ONLY FOR FLIGHTS INCOMING!!!!!!!!!
            //float totalContentHeight = thisAirport.getNumberOfFlightsIncoming() * 34; //??
            //drawScrollbar(SCREEN_DIVIDER_X_COORDINATE-20, HOME_BAR_HEIGHT+80+HEADINGS_SIZE, SCREEN_HEIGHT-HOME_BAR_HEIGHT*2, totalContentHeight, HOME_BAR_HEIGHT+80+HEADINGS_SIZE, 0); //currentScroll
            setArrivalAirports = true;

        }
        airportList.add(thisAirport);
        currentAirportIndex = airportList.size()-1;
        thisAirport.setPieChartValues(thisChart);
        thisAirport.airportDraw(airportName);
        pushStyle();
        thisChart.chartsDraw();
        popStyle();
    }

    void drawStateScreen(String code, State thisState, String stateName){
        //4PM, 18/03/26, Jesse Margarites
        if(stateList.isEmpty() || !stateList.contains(thisState)){ //dont think this will work for more states
        stateList.add(thisState);
        currentStateIndex = stateList.size()-1;
        readFileByState(code, thisState);
        thisState.setBarGraphValues(thisChart);
        }
        thisState.stateDraw(stateName);
        thisChart.chartsDraw();
        airportList = thisState.getAirportList();
    }


   
   void drawFlightScreen(){
    
}

    void drawLoadScreen(){

    }
//Jesse Margarites, 11AM, 26/03, updated moused pressed
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
/*
//Jesse Margarites, 1PM, 01/04, implmenting scroll bar
    void mouseWheel(MouseEvent event){
        
        if(screenType==AIRPORT_SCREEN){
            tableMouseWheel(event);
        }
        
    }
*/
        
//Jesse Margarites, 11AM, 26/03, updated key pressed
    void keyPressed(char key, int keyCode){
        handleSearchKey(key,keyCode);

        if(screenType==STATE_SCREEN){
            thisChart.keyPressed(key);
        }
    }

    boolean goHome(int mX, int mY){
        if(mouseX >= HOME_BUTTON_X-1 && mouseX <= HOME_BUTTON_X + HOME_BUTTON_SIZE+1 &&
          mouseY >= HOME_BUTTON_Y - HOME_BUTTON_SIZE/2 && mouseY <= HOME_BUTTON_Y + HOME_BUTTON_HEIGHT){
                return true;
        }
        return false;
    }

    boolean goBack(int mX, int mY){
        if(viewHistIndex != 0){
            if(mouseX >= BACK_ARROW_X && mouseX <= BACK_ARROW_X + ARROW_LENGTH &&
                mouseY >= BACK_ARROW_Y-ARROW_HEIGHT && mouseY <= BACK_ARROW_Y + ARROW_HEIGHT){
                return true;
            }
        }
        return false;
    }

    void goForward(int mX, int mY){
        if(mX > FORWARD_ARROW_X && mX < FORWARD_ARROW_X + ARROW_LENGTH && 
            mY > FORWARD_ARROW_Y && mY < FORWARD_ARROW_Y + ARROW_HEIGHT){
                screenHistoryIndex++;
                setScreenType(screenHistory.get(screenHistoryIndex));
        }
    }
}