//Amanda de Moraes, 9:40 AM 12/3
//code for a loading/barcode page
public class Barcode{
float scanX = 120;
PFont font;

void setup() {
  size(520, 400);
  font = createFont("Helvetica Bold", 16);
}

void draw() {
  background(235, 240, 245);

  // boarding pass card
  fill(255);
  stroke(180);
  rect(110, 130, 300, 140, 10);

  // airline title
  fill(40, 60, 90);
  textFont(font);
  textAlign(LEFT);
  text("BOARDING PASS", 130, 160);

  // flight information
  textSize(14);
  text("Passenger: user", 130, 190);
  text("Flight: BA204", 130, 210);
  text("Gate: A12", 130, 230);
  text("Seat: 14C", 130, 250);

  // barcode area
  stroke(0);
  for (int i = 0; i < 60; i++) {
    line(300 + i*2, 180, 300 + i*2, 250);
  }

  // moving scanner line
  noStroke();
  fill(0, 150, 255, 120);
  rect(scanX, 130, 5, 140);

  // move scanner
  scanX += 3;

  if (scanX > 410) {
    scanX = 110;
  }

  // loading text
  fill(50);
  textAlign(CENTER);
  text("Verifying Boarding Pass...", width/2, 310);
}
}