// Ema Caragea, route detail screen, 15/03/2026
// Ema Caragea, refactored into class, 18/03/2026

class Flights {
  FlightMapScreen screen;

  Flights(FlightMapScreen screen) {
    this.screen = screen;
  }

  void draw() {
    background(10, 15, 25);
    if (screen.selectedArc == null) {
      screen.currentScreen = 0;
      return;
    }

    fill(255);
    textFont(screen.fontBold);
    textSize(28);
    textAlign(CENTER, TOP);
    text(screen.selectedArc.origin.code + "  →  " + screen.selectedArc.destination.code, width / 2, 60);

    textSize(16);
    fill(180, 210, 255);
    text(screen.selectedArc.origin.city + "  to  " + screen.selectedArc.destination.city, width / 2, 100);

    textSize(18);
    if (screen.selectedArc.status.equals("onTime")) {
      fill(0, 200, 100);
      text("Status: On Time", width / 2, 150);
    } else if (screen.selectedArc.status.equals("delayed")) {
      fill(255, 200, 0);
      text("Status: Delayed", width / 2, 150);
    } else {
      fill(255, 60, 60);
      text("Status: Cancelled", width / 2, 150);
    }

    textFont(screen.fontRegular);
    drawBackButton();
  }

  void drawBackButton() {
    fill(0, 160, 230);
    noStroke();
    rect(20, 20, 100, 35, 8);
    fill(255);
    textFont(screen.fontBold);
    textSize(13);
    textAlign(CENTER, CENTER);
    text("< Back", 70, 37);
    textFont(screen.fontRegular);
  }
}