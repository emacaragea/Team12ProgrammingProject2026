//niko 10:00 AM 12/03/26 create and outline screen class
//niko 10:30 AM 12/03/26 write screenDraw and drawHomeBar
//niko 12:00 PM 18/03/26 code home bar button functions
import java.util.ArrayList;
class Screen{
    private int screenType;
    private int lastScreenType;
    private Airport selectedAirport;
    private String selectedAirportName;
    private ArrayList<Integer> screenHistory = new ArrayList<Integer>();
    private ArrayList<State> stateList = new ArrayList<State>();
    private int screenHistoryIndex = 0;
    private int currentStateIndex;
    final int HOME_SCREEN = 1;
    final int AIRPORT_SCREEN = 2;
    final int STATE_SCREEN = 3;
    final int FLIGHT_SCREEN = 4;
    final int LOADING_SCREEN = 5;
    final int BACK_ARROW_X = 15;
    final int BACK_ARROW_Y = 20;
    final int FORWARD_ARROW_X = 85;
    final int FORWARD_ARROW_Y = 20;
    final int ARROW_HEIGHT = 6;
    final int ARROW_LENGTH = 20;
    final int HOME_BUTTON_X = 50;
    final int HOME_BUTTON_Y = 10;
    final int HOME_BUTTON_SIZE = 20;
    final color BACKGROUND_COLOR = color(20, 28, 38);

    //amanda de moraes, 19/3/26, 10AM, added search bar
    final int SEARCHX= 150;
    final int SEARCHY =6;
    final int SEARCHW= 260;
    final int SEARCHH=28;
    
    boolean searchActive = false;
    String searchText ="";
    String selectedStateCode = "";

    //3PM, 19/03/26, Jesse Margarites
    Charts thisChart;

    Screen(int type){
        screenType = type;
        //3PM, 19/03/26, Jesse Margarites
        thisChart = new Charts();
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
    //Niko Charles, 10:00, 25/03/2026
        void screenDraw(String code, State thisState, String stateName, Airport thisAirport, String airportName){
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

    void drawHomeBar(){
        fill(200);
        rect(0, 0, 1400, 40);
        //draw backArrow
        stroke(255);
        strokeWeight(2);
        noFill();

        line(BACK_ARROW_X, BACK_ARROW_Y, BACK_ARROW_X+ARROW_LENGTH, BACK_ARROW_Y);

        line(BACK_ARROW_X, BACK_ARROW_Y, BACK_ARROW_X+ARROW_HEIGHT, BACK_ARROW_Y-ARROW_HEIGHT);
        line(BACK_ARROW_X, BACK_ARROW_Y, BACK_ARROW_X+ARROW_HEIGHT, BACK_ARROW_Y+ARROW_HEIGHT);
        //drawHomeButton
        rect(HOME_BUTTON_X, HOME_BUTTON_Y, HOME_BUTTON_SIZE, HOME_BUTTON_SIZE);

        //draw forward arrow
        line(FORWARD_ARROW_X, FORWARD_ARROW_Y, FORWARD_ARROW_X + ARROW_LENGTH, FORWARD_ARROW_Y);
        line(FORWARD_ARROW_X + ARROW_LENGTH, FORWARD_ARROW_Y,
            FORWARD_ARROW_X + ARROW_LENGTH - ARROW_HEIGHT, FORWARD_ARROW_Y - ARROW_HEIGHT);

        line(FORWARD_ARROW_X + ARROW_LENGTH, FORWARD_ARROW_Y,
            FORWARD_ARROW_X + ARROW_LENGTH - ARROW_HEIGHT, FORWARD_ARROW_Y + ARROW_HEIGHT);
    }


     //amanda de moraes, 19/3, search bar methods
     void drawSearchBar(){
       boolean hover = mouseX>= SEARCHX && mouseX <= SEARCHX + SEARCHW
       && mouseY >= SEARCHY && mouseY <= SEARCHY + SEARCHH;
       
       fill(searchActive ? color(120,190,245):color(70,90,110));
       strokeWeight(1.5);
       rect(SEARCHX, SEARCHY, SEARCHW, SEARCHH,8);
       
       textAlign(LEFT,CENTER);
       textSize(13);
       
       if(searchText.length()==0 && !searchActive){
         
         fill(150,165,180);
         text("Search state code:", SEARCHX +10, SEARCHY+SEARCHH/2);
       }
       else{
         fill(240);
         text(searchText, SEARCHX +10, SEARCHY+SEARCHH/2);
       }
     }
     
     void handleSearchClick(int mx, int my){
       searchActive = (mx >= SEARCHX && mx <= SEARCHX + SEARCHW && my>= SEARCHY &&
       my<+ SEARCHY + SEARCHH);
     }
     
     void handleSearchKey(char key, int keyCode){
        if(!searchActive) return;

        // enter key = search
        if(keyCode == ENTER || keyCode == RETURN){
            runSearch();
            return;
        }

        // backspace
        if(keyCode == BACKSPACE){
            if(searchText.length() > 0){
                searchText = searchText.substring(0, searchText.length()-1);
            }
            return;
        }

        // ignore weird keys
        if(keyCode == SHIFT || keyCode == CONTROL || keyCode == ALT){
            return;
        }

        // only allow letters
        if(Character.isLetter(key) && searchText.length() < 20){
            searchText += Character.toUpperCase(key);
        }
    }

      void runSearch(){
        String cleaned = trim(searchText).toUpperCase();

        // only switch if user entered a 2 letter state code
        if(cleaned.length() == 2){
            selectedStateCode = cleaned;
            setScreenType(STATE_SCREEN);
            searchActive = false;
        }
    }

    void drawHomeScreen(){

    }

    void drawAirportScreen(Airport thisAirport, String AirportName){

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
    }



    void drawFlightScreen(){

    }

    void drawLoadScreen(){

    }

    void mousePressed() {
        handleSearchClick(mouseX, mouseY);
        goHome(mouseX, mouseY);
        goBack(mouseX, mouseY);
        goForward(mouseX, mouseY);
        if (screenType == STATE_SCREEN) {
            State currentState = stateList.get(currentStateIndex);
            Airport clickedAirport = currentState.linkClick(mouseX, mouseY);
            if (clickedAirport != null) {
                setSelectedAirport(clickedAirport);
                setScreenType(AIRPORT_SCREEN);
            }
        }
    }

    void goHome(int mX, int mY){
        if(mX > HOME_BUTTON_X && mX < HOME_BUTTON_X + HOME_BUTTON_SIZE && 
            mY > HOME_BUTTON_Y && mY < HOME_BUTTON_Y + HOME_BUTTON_SIZE){
                setScreenType(1);
        }
    }

    void goBack(int mX, int mY){
        if(mX > BACK_ARROW_X && mX < BACK_ARROW_X + ARROW_LENGTH && 
            mY > BACK_ARROW_Y && mY < BACK_ARROW_Y + ARROW_HEIGHT){
                screenHistoryIndex--;
                setScreenType(screenHistory.get(screenHistoryIndex));
        }
    }

    void goForward(int mX, int mY){
        if(mX > FORWARD_ARROW_X && mX < FORWARD_ARROW_X + ARROW_LENGTH && 
            mY > FORWARD_ARROW_Y && mY < FORWARD_ARROW_Y + ARROW_HEIGHT){
                screenHistoryIndex++;
                setScreenType(screenHistory.get(screenHistoryIndex));
        }
    }
}