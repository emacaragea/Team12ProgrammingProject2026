//niko 10:00 AM 12/03/26 create and outline screen class
//niko 10:30 AM 12/03/26 write screenDraw and drawHomeBar
class Screen{
    int screentype;

    final int HOME_SCREEN = 1;
    final int AIRPORT_SCREEN = 2;
    final int STATE_SCREEN = 3;
    final int FLIGHT_SCREEN = 4;
    final int LOADING_SCREEN = 5;
    final int ARROW_X = 15;
    final int ARROW_Y = 20;
    final color BACKGROUND_COLOR = (0);

    Screen(int type){
        screentype = type;
    }

    void setScreenType(int type){
        screenType = type;
    }

    int getScreenType(){
        return screenType;
    }

    void screenDraw(){
        fill(BACKGROUND_COLOR);
        drawHomeBar();
        switch(screentype){
            case 1:
            drawHomeScreen();
            break;
            case 2:
            drawAirportScreen();
            break;
            case 3:
            drawStateScreen();
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
        rect(0, 0, 400, 40);
        //draw backArrow
        stroke(255);
        strokeWeight(2);
        noFill();

        line(ARROW_X, ARROW_Y, ARROW_X+20, ARROW_Y);

        line(ARROW_X, ARROW_Y, ARROW_X+6, ARROW_y-6);
        line(ARROW_X, ARROW_Y, ARROW_X+6, ARROW_Y+6);
        //drawHomeButton

    }

    void drawHomeScreen(){

    }

    void drawAirportScreen(){

    }

    void drawStateScreen(){

    }

    void drawFlightScreen(){

    }

    void drawLoadScreen(){

    }
}