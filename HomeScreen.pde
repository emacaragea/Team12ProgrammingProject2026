//Ema Caragea, created a rough draft of Home Screen with header, map and buttons, 24/03/2026 20:00

class HomeScreen {
  Header   header;
  USMapScreen usMap;

  final int HEADER_H    = 90;
  final int BUTTON_H   = 45;   // was 70
  final int BUTTON_GAP = 60;   // was 20
  final int BUTTON_Y   = height - BUTTON_H - 30;
  final int BUTTON_W   = (width - BUTTON_GAP * 6) / 2;  // more gap on sides

  final float MAP_H       = (height - HEADER_H - BUTTON_H - BUTTON_GAP * 2) ;
  final float MAP_Y       = HEADER_H + (height - HEADER_H - BUTTON_H - BUTTON_GAP * 2 - MAP_H) / 2; // vertically centre it
    // Button hover state
  boolean[] hovered = new boolean[2];

  final String[] BUTTON_LABELS = {
    "Flight Map",
    "TBD"
  };

  final color BUTTON_DEFAULT  = color(82, 156, 214);
  final color BUTTON_HOVER    = color(92, 170, 230);
  final color BUTTON_STROKE   = color(120, 190, 245);
  final color BUTTON_TEXT     = color(220, 235, 255);

  HomeScreen(USMapScreen usMap) {
    this.header = new Header();
    this.usMap  = usMap;
  }

  void draw() {
    background(20, 28, 38);

    // Draw US map in the middle region
    usMap.drawInRegion(0, MAP_Y, width, MAP_H);

    // Draw buttons and header on top
    drawButtons();
    header.draw();
    // drawBackgroundGlow();
  }

  //background glow effect, TBD if we want to keep it or replace with something else
  // void drawBackgroundGlow() {
  //   noStroke();

  //   fill(70, 110, 150, 18);
  //   ellipse(width * 0.25, height * 0.3, 520, 520);

  //   fill(70, 110, 150, 12);
  //   ellipse(width * 0.75, height * 0.7, 600, 600);
  // }


  void drawButtons() {
  for (int i = 0; i < 2; i++) {
    float totalWidth = 2 * BUTTON_W + BUTTON_GAP;
    float startX = (width - totalWidth) / 2;
    float bx = startX + i * (BUTTON_W + BUTTON_GAP);
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

  void mousePressed() {
    for (int i = 0; i < 2; i++) {
      float bx = BUTTON_GAP + i * (BUTTON_W + BUTTON_GAP);
      if (mouseX >= bx && mouseX <= bx + BUTTON_W &&
          mouseY >= BUTTON_Y && mouseY <= BUTTON_Y + BUTTON_H) {
        handleButtonPress(i);
        return;
      }
    }

    // Click on map 
    if (mouseY > MAP_Y && mouseY < MAP_Y + MAP_H) {
        usMap.mousePressedInRegion(0, MAP_Y, width, MAP_H);
    }
  }

  void handleButtonPress(int index) {
    if (index == 0) {
      currentView = 2; // FlightMapScreen
      viewHistIndex++;
      viewHistory.add(viewHistIndex, currentView);
    }
    // index 1 is TBD
  }
}