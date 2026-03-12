//Amanda de Moraes , example of loading page, 9:29 AM, 12/3
public class Loading {
PFont titleFont;
PFont labelFont;
PFont smallFont;

float progress = 0.0;
int loadingDots = 0;
int lastDotChange = 0;

String fromCode = "DUB";
String toCode = "JFK";

void setup() {
  size(520, 400);
  smooth();

  titleFont = createFont("Helvetica Bold", 24);
  labelFont = createFont("Helvetica Bold", 16);
  smallFont = createFont("Helvetica", 13);
}

void draw() {
  background(20, 28, 38);

  drawBackgroundGlow();
  drawHeader();
  drawRouteCard();
  drawProgressText();
  updateAnimation();
}

void drawBackgroundGlow() {
  noStroke();

  fill(70, 110, 150, 18);
  ellipse(width * 0.25, height * 0.3, 220, 220);

  fill(70, 110, 150, 12);
  ellipse(width * 0.75, height * 0.7, 260, 260);
}

void drawHeader() {
  fill(235, 240, 245);
  textAlign(CENTER, CENTER);

  textFont(titleFont);
  text("Preparing Your Route", width / 2, 55);

  textFont(smallFont);
  fill(150, 165, 180);
  text("Synchronising flight and airport data", width / 2, 82);
}

void drawRouteCard() {
  float cardX = 55;
  float cardY = 120;
  float cardW = 410;
  float cardH = 150;

  // card shadow
  noStroke();
  fill(0, 35);
  rect(cardX + 5, cardY + 6, cardW, cardH, 18);

  // main card
  fill(30, 40, 52);
  rect(cardX, cardY, cardW, cardH, 18);

  // airport labels
  fill(240, 244, 248);
  textAlign(CENTER, CENTER);
  textFont(labelFont);
  text(fromCode, cardX + 55, cardY + 52);
  text(toCode, cardX + cardW - 55, cardY + 52);

  fill(140, 155, 170);
  textFont(smallFont);
  text("Departure", cardX + 55, cardY + 78);
  text("Arrival", cardX + cardW - 55, cardY + 78);

  // route line
  float startX = cardX + 105;
  float endX = cardX + cardW - 105;
  float routeY = cardY + 55;

  stroke(90, 105, 120);
  strokeWeight(2);
  line(startX, routeY, endX, routeY);

  // dashed overlay
  stroke(170, 185, 200, 120);
  for (float x = startX; x < endX; x += 18) {
    line(x, routeY, x + 8, routeY);
  }

  // airport dots
  noStroke();
  fill(82, 156, 214);
  ellipse(startX, routeY, 10, 10);
  ellipse(endX, routeY, 10, 10);

  //  progress line
  float planeX = lerp(startX, endX, progress);
  stroke(82, 156, 214);
  strokeWeight(3);
  line(startX, routeY, planeX, routeY);

  // plane icon
  drawPlaneIcon(planeX, routeY);

  // progress bar at bottom of card
  float barX = cardX + 35;
  float barY = cardY + 112;
  float barW = cardW - 70;
  float barH = 8;

  noStroke();
  fill(55, 68, 82);
  rect(barX, barY, barW, barH, 6);

  fill(82, 156, 214);
  rect(barX, barY, barW * progress, barH, 6);

  // percentage
  fill(220, 228, 236);
  textAlign(RIGHT, CENTER);
  textFont(smallFont);
  text(int(progress * 100) + "%", cardX + cardW - 25, cardY + 132);
}

void drawPlaneIcon(float x, float y) {
  pushMatrix();
  translate(x, y);
  rotate(radians(0));

  noStroke();
  fill(245);

  // body
  rect(-10, -3, 20, 6, 3);

  // nose
  triangle(10, -3, 16, 0, 10, 3);

  // tail
  triangle(-10, -3, -15, -9, -5, -3);

  // wings
  fill(225);
  triangle(-2, 0, -10, 8, 6, 3);
  triangle(-2, 0, -10, -8, 6, -3);

  popMatrix();
}

void drawProgressText() {
  String dots = "";
  for (int i = 0; i < loadingDots; i++) {
    dots += ".";
  }

  fill(180, 190, 200);
  textAlign(CENTER, CENTER);
  textFont(smallFont);
  text("Finalising journey details" + dots, width / 2, 315);

  fill(120, 135, 150);
  text("Please wait a moment", width / 2, 340);
}

void updateAnimation() {
  progress += 0.0035;

  if (progress > 1) {
    progress = 0;
  }

  if (millis() - lastDotChange > 450) {
    loadingDots++;
    if (loadingDots > 3) {
      loadingDots = 0;
    }
    lastDotChange = millis();
  }
}
}
