//Ema Caragea, created a rough draft of Home Screen with header, map and buttons, 24/03/2026 20:00

class HomeScreen {
  Header   header;
  USMapScreen usMap;

  final int HEADER_H    = 90;
final int BUTTON_H    = 70;
final int BUTTON_GAP  = 20;
final int BUTTON_W    = (width - BUTTON_GAP * 4) / 3;

final int MAP_H       = (height - HEADER_H - BUTTON_H - BUTTON_GAP * 2) / 2;
final int MAP_Y       = HEADER_H + (height - HEADER_H - BUTTON_H - BUTTON_GAP * 2 - MAP_H) / 2; // vertically centre it
final int BUTTON_Y    = height - BUTTON_H - BUTTON_GAP;
  // Button hover state
  boolean[] hovered = new boolean[3];

  final String[] BUTTON_LABELS = {
    "Flight Map",
    "TBD",
    "TBD"
  };

  final color BUTTON_DEFAULT  = color(25, 40, 65);
  final color BUTTON_HOVER    = color(0, 100, 180);
  final color BUTTON_STROKE   = color(0, 140, 220);
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
    drawBackgroundGlow();
  }

  void drawBackgroundGlow() {
    noStroke();

    fill(70, 110, 150, 18);
    ellipse(width * 0.25, height * 0.3, 520, 520);

    fill(70, 110, 150, 12);
    ellipse(width * 0.75, height * 0.7, 600, 600);
  }

  void drawButtons() {
    for (int i = 0; i < 3; i++) {
      float bx = BUTTON_GAP + i * (BUTTON_W + BUTTON_GAP);

      hovered[i] = mouseX >= bx && mouseX <= bx + BUTTON_W &&
                   mouseY >= BUTTON_Y && mouseY <= BUTTON_Y + BUTTON_H;

      // Shadow
      noStroke();
      fill(0, 40);
      rect(bx + 4, BUTTON_Y + 4, BUTTON_W, BUTTON_H, 10);

      // Button body
      fill(hovered[i] ? BUTTON_HOVER : BUTTON_DEFAULT);
      stroke(BUTTON_STROKE);
      strokeWeight(1.2);
      rect(bx, BUTTON_Y, BUTTON_W, BUTTON_H, 10);

      // Label
      fill(BUTTON_TEXT);
      noStroke();
      textAlign(CENTER, CENTER);
      textSize(15);
      text(BUTTON_LABELS[i], bx + BUTTON_W / 2, BUTTON_Y + BUTTON_H / 2);
    }
  }

  void mousePressed() {
    for (int i = 0; i < 3; i++) {
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
    }
    // index 1 and 2 are TBD
  }
}