//Ema Caragea, created a rough draft of Home Screen with header, map and buttons, 24/03/2026 20:00
//Ema Caragea, added UI elements and connected General Table and Flight Map screens to buttons, 1/04/2026, 14:00
class HomeScreen {
  Header   header;
  USMapScreen usMap;

  PFont titleFont;
  PFont subtitleFont;

  // calculated layout zones so the map, title and buttons don't overlap
  final int HEADER_H    = 90;
  final int TITLE_H     = 70;

  final int BUTTON_H   = 45;
  final int BUTTON_GAP = 60;
  final int BUTTON_Y   = height - BUTTON_H - 40; 
  final int BUTTON_W   = (width - BUTTON_GAP * 6) / 3;  

  // map fills the remaining vertical space between the title and the buttons
  final float MAP_H       = (height - HEADER_H - TITLE_H - BUTTON_H - BUTTON_GAP * 2) ;
  final float MAP_Y       = HEADER_H + TITLE_H + (height - HEADER_H - TITLE_H - BUTTON_H - BUTTON_GAP * 2 - MAP_H) / 2;

  // Button hover state
  boolean[] hovered = new boolean[2];

  final String[] BUTTON_LABELS = {
    "Satelite View",
    "Flights Table"
  };

  // button colors match the header blue 
  final color BUTTON_DEFAULT  = color(82, 156, 214);
  final color BUTTON_HOVER    = color(92, 170, 230);
  final color BUTTON_STROKE   = color(120, 190, 245);
  final color BUTTON_TEXT     = color(220, 235, 255);

  // constructor takes usMap so HomeScreen doesn't need to create it 
  HomeScreen(USMapScreen usMap) {
    this.header = new Header();
    this.usMap  = usMap;
    titleFont    = createFont("Helvetica Bold", 38);
    subtitleFont = createFont("Helvetica", 18);
  }

  //draw order matters, map first, then buttons and title on top, then header last so it's always on top
  void draw() {
    pushStyle();
    background(20, 28, 38);

    // Draw US map in the middle region
    usMap.drawInRegion(0, MAP_Y, width, MAP_H);

    // Draw buttons, title and header on top
    drawButtons();
    drawTitle();
    header.draw();
    popStyle();
  }

  // draws the page title and subtitle 
  void drawTitle() {
    textAlign(CENTER, CENTER);
    textFont(titleFont);
    fill(235, 240, 245);
    text("US Flight Activity by State", width / 2, HEADER_H + TITLE_H * 0.38);

    textFont(subtitleFont);
    fill(150, 165, 180);
    text("Click any state to explore its flight activity", width / 2, HEADER_H + TITLE_H * 0.88);
  }



  // buttons are centred as a group using totalWidth calculation
  void drawButtons() {
    for (int i = 0; i < 2; i++) {
      float totalWidth = 2 * BUTTON_W + BUTTON_GAP;
      float startX = (width - totalWidth) / 2; // centres the button group regardless of window width
      float bx = startX + i * (BUTTON_W + BUTTON_GAP);

      // hover is checked every frame so the color updates without needing a separate mouse event
      boolean hov = mouseX >= bx && mouseX <= bx + BUTTON_W &&
                    mouseY >= BUTTON_Y && mouseY <= BUTTON_Y + BUTTON_H;

      fill(hov ? color( 92, 170, 230) : color(82, 156, 214));
      stroke(color(120, 190, 245));
      strokeWeight(1.5);
      rect(bx, BUTTON_Y, BUTTON_W, BUTTON_H, 12); 

      fill(240);
      textAlign(CENTER, CENTER);
      textSize(14);
      text(BUTTON_LABELS[i], bx + BUTTON_W / 2, BUTTON_Y + BUTTON_H / 2);
    }
  }

  // checks buttons first, then passes the click down to the map if it wasn't a button, 01/04/2026
  void mousePressed() {
    for (int i = 0; i < 2; i++) {
      float totalWidth = 2 * BUTTON_W + BUTTON_GAP;
      float startX = (width - totalWidth) / 2;
      float bx = startX + i * (BUTTON_W + BUTTON_GAP);
      if (mouseX >= bx && mouseX <= bx + BUTTON_W &&
          mouseY >= BUTTON_Y && mouseY <= BUTTON_Y + BUTTON_H) {
        handleButtonPress(i);
        return; // early return so a button click doesn't also fire a map click underneath
      }
    }

    //  only pass click to the map if the click is actually within the map region
    if (mouseY > MAP_Y && mouseY < MAP_Y + MAP_H) {
        usMap.mousePressedInRegion(0, MAP_Y, width, MAP_H);
    }
  }

  // navigates to the correct screen by updating currentView and pushing to view history
  void handleButtonPress(int index) {
    if (index == 0) {
      currentView = CURRENT_VIEW_FLIGHT_MAP;
      viewHistIndex++;
      viewHistory.add(viewHistIndex, currentView);
    } else if (index == 1) {
      currentView = CURRENT_VIEW_GENERAL_TABLE;
      viewHistIndex++;
      viewHistory.add(viewHistIndex, currentView);
    }
  }
}