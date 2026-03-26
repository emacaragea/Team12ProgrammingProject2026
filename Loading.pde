// Amanda de Moraes  - march 15 16:27
// Loading screen updated, scaled for 1400 x 800
// Ema Caragea connected loading screen to main sketch, 26/03/2026 21:00  

Loading loading;

//void setup() {
//  size(1400, 800);
//  smooth();
//  loading = new Loading();
//  loading.setup();
//}

//void draw() {
//  loading.draw();
//}

class Loading {
  PFont titleFont;
  PFont labelFont;
  PFont smallFont;

  float progress = 0.0;
  int loadingDots = 0;
  int lastDotChange = 0;

  String fromCode = "DUB";
  String toCode = "JFK";

  void setup() {
    titleFont = createFont("Helvetica Bold", 52);
    labelFont = createFont("Helvetica Bold", 32);
    smallFont = createFont("Helvetica", 24);
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
    ellipse(width * 0.25, height * 0.3, 520, 520);

    fill(70, 110, 150, 12);
    ellipse(width * 0.75, height * 0.7, 600, 600);
  }

  void drawHeader() {
    fill(235, 240, 245);
    textAlign(CENTER, CENTER);

    textFont(titleFont);
    text("Preparing Your Route", width / 2, 120);

    textFont(smallFont);
    fill(150, 165, 180);
    text("Synchronising flight and airport data", width / 2, 178);
  }

  void drawRouteCard() {
    float cardX = 190;
    float cardY = 230;
    float cardW = 1020;
    float cardH = 290;

    noStroke();
    fill(0, 35);
    rect(cardX + 8, cardY + 10, cardW, cardH, 32);

    fill(30, 40, 52);
    rect(cardX, cardY, cardW, cardH, 32);

    fill(240, 244, 248);
    textAlign(CENTER, CENTER);
    textFont(labelFont);
    text(fromCode, cardX + 120, cardY + 100);
    text(toCode, cardX + cardW - 120, cardY + 100);

    fill(140, 155, 170);
    textFont(smallFont);
    text("Departure", cardX + 120, cardY + 148);
    text("Arrival", cardX + cardW - 120, cardY + 148);

    float startX = cardX + 215;
    float endX   = cardX + cardW - 215;
    float routeY = cardY + 110;

    stroke(90, 105, 120);
    strokeWeight(2.5);
    line(startX, routeY, endX, routeY);

    stroke(170, 185, 200, 120);
    for (float x = startX; x < endX; x += 22) {
      line(x, routeY, x + 11, routeY);
    }

    noStroke();
    fill(82, 156, 214);
    ellipse(startX, routeY, 18, 18);
    ellipse(endX,   routeY, 18, 18);

    float planeX = lerp(startX, endX, progress);
    stroke(82, 156, 214);
    strokeWeight(4.5);
    line(startX, routeY, planeX, routeY);

    drawPlaneIcon(planeX, routeY);

    float barX = cardX + 70;
    float barY = cardY + 222;
    float barW = cardW - 140;
    float barH  = 14;

    noStroke();
    fill(55, 68, 82);
    rect(barX, barY, barW, barH, 8);

    fill(82, 156, 214);
    rect(barX, barY, barW * progress, barH, 8);

    fill(220, 228, 236);
    textAlign(RIGHT, CENTER);
    textFont(smallFont);
    text(int(progress * 100) + "%", cardX + cardW - 44, cardY + 260);
  }

  void drawPlaneIcon(float x, float y) {
    pushMatrix();
    translate(x, y);

    noStroke();
    fill(245);

    rect(-18, -6, 36, 12, 6);
    triangle(18, -6, 30, 0, 18, 6);
    triangle(-18, -6, -28, -18, -8, -6);

    fill(225);
    triangle(-4, 0, -18, 16, 10, 6);
    triangle(-4, 0, -18, -16, 10, -6);

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
    text("Finalising journey details" + dots, width / 2, 620);

    fill(120, 135, 150);
    text("Please wait a moment", width / 2, 662);
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