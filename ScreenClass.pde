//niko 10:00 AM 12/03/26 create and outline screen class
//niko 10:30 AM 12/03/26 write screenDraw and drawHomeBar
//niko 12:00 PM 18/03/26 code home bar button functions
import java.util.ArrayList;
class Screen{
    private int screenType;
    private int lastScreenType;
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
    final color BACKGROUND_COLOR = (0);

    Screen(int type){
        screenType = type;
    }

    void setScreenType(int type){
        screenHistory.add(type);
        screenHistoryIndex++;
        screenType = type;
    }

    int getScreenType(){
        return screenType;
    }

    void screenDraw(String name){
        fill(BACKGROUND_COLOR);
        drawHomeBar();
        switch(screenType){
            case 1:
            drawHomeScreen();
            break;
            case 2:
            drawAirportScreen();
            break;
            case 3:
            drawStateScreen(name);
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

    void drawHomeScreen(){

    }

    void drawAirportScreen(){

    }

    void drawStateScreen(String code){
        //2PM, 18/03/26, Jesse Margarites
        String stateName = convertStateCodeToStateName(code);
        State thisState = new State(stateName);
        stateList.add(thisState);
        currentStateIndex = stateList.size()-1;
        readFileByState(code, thisState);
        thisState.stateDraw(stateName);
    }

    void drawFlightScreen(){

    }

    void drawLoadScreen(){

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