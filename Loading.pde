// Amanda de Moraes  - march 15 16:27
// Loading screen updated, scaled for 1400 x 800
// Ema Caragea connected loading screen to main sketch, 26/03/2026 21:00 
//Ema Caragea, made the loading bar load proportionately to the time spent on the loading screen, 26/03/2026 17:00


Loading loading;
Loading flightTableLoading;

//void setup() {
//  size(1400, 800);
//  smooth();
//  loading = new Loading();
//  loading.setup();
//}

//void draw() {
//  loading.draw();
//}

//Jesse Margarites, 11AM, 26/03, updated loading screen by
//  1: Making it useable for different screens 
//  2: pushing and poping styles
class Loading {
  PFont titleFont;
  PFont labelFont;
  PFont smallFont;

  float progress = 0.0;
  int loadingDots = 0;
  int lastDotChange = 0;

  float snapshotProgress =0;

  private final String FROM_CODE = "LDS"; 
  private final String FROM_FULL_STRING = "Loading Screen";
  private String toCode;
  private String toFullString;

  PImage planeImg;
//Jesse Margarites, 7PM, 03/04, implmenting features to make loading screen reuseable 
  Loading(String toCode, String toFullString){
    this.toCode = toCode;
    this.toFullString = toFullString;
  }

  void setToCode(String toCode){
    this.toCode=toCode;
  }
  void setToFullString(String toFullString){
    this.toFullString = toFullString;
  }

void loadingSetup() {
  titleFont = createFont("Helvetica Bold", 52);
  labelFont = createFont("Helvetica Bold", 32);
  smallFont = createFont("Helvetica", 24);
  planeImg  = loadImage("LoadingScreenPlane.png");
}

  void loadingDraw() {


    pushStyle();

    snapshotProgress=loadProgress;
 
        background(20, 28, 38);
    fill(20, 28, 38); 
        noStroke();
    //if(toCode.equals("HMS")){
      updateAnimation();
      drawBackgroundGlow();

    //}
 

    drawHeader();
    drawRouteCard();
    drawProgressText();
    popStyle();
    
    //fill(20, 28, 38);  
    //noStroke();

  }

  void drawBackgroundGlow() {
    pushStyle();
    noStroke();

    fill(70, 110, 150, 18);
    ellipse(width * 0.25, height * 0.3, 520, 520);

    fill(70, 110, 150, 12);
    ellipse(width * 0.75, height * 0.7, 600, 600);
    popStyle();
  }

  void drawHeader() {
    pushStyle();
        background(20, 28, 38);
    //fill(20, 28, 38);  // reseting to fill to background color first
    noStroke();
    fill(235, 240, 245);
    textAlign(CENTER, CENTER);

    textFont(titleFont);
    String headerDots = "";
    for (int i = 0; i < loadingDots; i++) headerDots += ".";
    text("Loading" + headerDots, width / 2, 120); //text was "Preparing Your Route"

    textFont(smallFont);
    fill(150, 165, 180);
    text("Synchronising flight and airport data", width / 2, 178);
    popStyle();
  }

  void drawRouteCard() {
    pushStyle();
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
    text(FROM_CODE, cardX + 120, cardY + 100);
    text(toCode, cardX + cardW - 120, cardY + 100);

    fill(140, 155, 170);
    textFont(smallFont);
    text(FROM_FULL_STRING, cardX + 120, cardY + 148); 
    text(toFullString, cardX + cardW - 120, cardY + 148); 

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

    float planeX = lerp(startX, endX, snapshotProgress);    
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
    rect(barX, barY, barW * snapshotProgress, barH, 8);

    fill(220, 228, 236);
    textAlign(RIGHT, CENTER);
    textFont(smallFont);
    text(int(snapshotProgress * 100) + "%", cardX + cardW - 44, cardY + 260);
    popStyle();
  }

  void drawPlaneIcon(float x, float y) {
  pushStyle();
  imageMode(CENTER);
  image(planeImg, x, y, 50, 50);
  imageMode(CORNER);
  popStyle();
}

  void drawProgressText() {
    pushStyle();
    fill(180, 190, 200);
    textAlign(CENTER, CENTER);
    textFont(smallFont);
    text("Finalising journey details...", width / 2, 620);

    fill(120, 135, 150);
    text("Please wait a moment", width / 2, 662);
    popStyle();

  }

  //Ema Caragea, made the loading bar load proportionately to the time spent on the loading screen + Loading animation, 1/04/2026 15:15
  void updateAnimation() {
    progress += 0.0035;

    if (progress > 1) {
      progress = 0;
    }

    if (millis() - lastDotChange > 500) {
      loadingDots++;
      if (loadingDots > 3) {
        loadingDots = 0;
      }
      lastDotChange = millis();
    }
  }
}