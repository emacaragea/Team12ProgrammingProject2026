// 11AM, 12/02/26, Jesse Margarites
class Flight {
  

}

// Ema Caragea, route detail screen, 15/3/2026, 14:00
void drawRoutePage() {
  background(10, 15, 25);

  // safety check — if nothing selected, go back
  if (selectedArc == null) {
    currentScreen = 0;
    return;
  }

  // title
  fill(255);
  textFont(fontBold);
  textSize(28);
  textAlign(CENTER, TOP);
  text(selectedArc.origin.code + "  →  " + selectedArc.destination.code, width / 2, 60);

  // city names
  textSize(16);
  fill(180, 210, 255);
  text(selectedArc.origin.city + "  to  " + selectedArc.destination.city, width / 2, 100);

  // status box
  textSize(18);
  if (selectedArc.status.equals("onTime")) {
    fill(0, 200, 100);
    text("Status: On Time", width / 2, 150);
  } else if (selectedArc.status.equals("delayed")) {
    fill(255, 200, 0);
    text("Status: Delayed", width / 2, 150);
  } else {
    fill(255, 60, 60);
    text("Status: Cancelled", width / 2, 150);
  }

  textFont(fontRegular);
  drawBackButton();
}

// to be removed once the header is added
void drawBackButton() {
  fill(0, 160, 230);
  noStroke();
  rect(20, 20, 100, 35, 8);

  fill(255);
  textFont(fontBold);
  textSize(13);
  textAlign(CENTER, CENTER);
  text("< Back", 70, 37);
  textFont(fontRegular);

  if (mousePressed && mouseX > 20 && mouseX < 120 && mouseY > 20 && mouseY < 55) {
    currentScreen = 0;
  }
}