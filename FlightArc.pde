//Ema Caragea, moved FlightArc class to a separate file, 15/03/2026, 15:00
// Ema Caragea, code was written on 14/03/2026, more details on FlightMap.pde

class FlightArc {
  AirportCoordinates origin;
  AirportCoordinates destination;
  String status;

  float t;
  float speed;

  float cx1, cy1;
  float cx2, cy2;

  float midX, midY;       // midpoint of the arc for hover detection

  PImage planeImg;
  int planeSize = 28;

  boolean hovered;
  float currentWeight;    // animates smoothly between thin and thick
  float currentAlpha;     // animates smoothly between dim and bright

  FlightArc(String originCode, String destCode, String status) {
    this.origin      = findAirport(originCode);
    this.destination = findAirport(destCode);
    this.status      = status;
    this.t           = 0.5;   // start at midpoint when not animating
    this.speed       = random(0.0015, 0.003);
    this.hovered     = false;
    this.currentWeight = 1.5;
    this.currentAlpha  = 80;

    float mx   = (origin.x + destination.x) / 2;
    float my   = (origin.y + destination.y) / 2;
    float dx   = destination.x - origin.x;
    float dy   = destination.y - origin.y;
    float d    = sqrt(dx * dx + dy * dy);
    float lift = d * 0.35;

    float perpX = -dy / d;
    float perpY =  dx / d;

    cx1 = origin.x      + (mx - origin.x)      * 0.5 + perpX * lift;
    cy1 = origin.y      + (my - origin.y)      * 0.5 + perpY * lift;
    cx2 = destination.x + (mx - destination.x) * 0.5 + perpX * lift;
    cy2 = destination.y + (my - destination.y) * 0.5 + perpY * lift;

    // midpoint of the bezier curve for hover detection
    midX = bezierPoint(origin.x, cx1, cx2, destination.x, 0.5);
    midY = bezierPoint(origin.y, cy1, cy2, destination.y, 0.5);

    if (status.equals("onTime")) {
      planeImg = planeOnTime;
    } else if (status.equals("delayed")) {
      planeImg = planeDelayed;
    } else {
      planeImg = planeCancelled;
    }
  }

 void FlightArcDraw() {
  // check mouse distance against multiple points along the arc so that it recognises the hover all along the route
  hovered = false;
  for (int i = 0; i <= 20; i++) {
    float sample = i / 20.0;
    float sx = bezierPoint(origin.x, cx1, cx2, destination.x, sample);
    float sy = bezierPoint(origin.y, cy1, cy2, destination.y, sample);
    if (dist(mouseX, mouseY, sx, sy) < 20) {
      hovered = true;
    }
  }

  float targetWeight;
  float targetAlpha;
  if (hovered) {
    targetWeight = 3.5;
    targetAlpha  = 220;
  } else {
    targetWeight = 3.5;
    targetAlpha  = 50;
  }
  currentWeight += (targetWeight - currentWeight) * 0.1;
  currentAlpha  += (targetAlpha  - currentAlpha)  * 0.1;

  drawArcLine();
  drawPlane();

  t += speed;
  if (t > 1.0) {
    t = 0.0;
  }
}

boolean isClicked() {
  for (int i = 0; i <= 20; i++) {
    float sample = i / 20.0;
    float sx = bezierPoint(origin.x, cx1, cx2, destination.x, sample);
    float sy = bezierPoint(origin.y, cy1, cy2, destination.y, sample);
    if (dist(mouseX, mouseY, sx, sy) < 20) {
      return true;
    }
  }
  return false;
}

  void drawArcLine() {
    noFill();
    strokeWeight(currentWeight);

    if (status.equals("onTime")) {
      stroke(0, 210, 100, currentAlpha);
    } else if (status.equals("delayed")) {
      stroke(255, 200, 0, currentAlpha);
    } else {
      stroke(255, 60, 60, currentAlpha);
    }

    bezier(origin.x, origin.y, cx1, cy1, cx2, cy2, destination.x, destination.y);
  }

  void drawPlane() {
    float x = bezierPoint(origin.x, cx1, cx2, destination.x, t);
    float y = bezierPoint(origin.y, cy1, cy2, destination.y, t);

    float tAhead = t + 0.01;
    if (tAhead > 1.0) {
      tAhead = 1.0;
    }
    float xAhead = bezierPoint(origin.x, cx1, cx2, destination.x, tAhead);
    float yAhead = bezierPoint(origin.y, cy1, cy2, destination.y, tAhead);

    float angle = atan2(yAhead - y, xAhead - x);

    // make plane slightly bigger on hover
  float drawSize;
if (hovered) {
  drawSize = planeSize * 1.4;
} else {
  drawSize = planeSize * 1.0;  
}

    blendMode(SCREEN);
    pushMatrix();
    translate(x, y);
    rotate(angle);   
    imageMode(CENTER);
    image(planeImg, 0, 0, drawSize, drawSize);
    popMatrix();
    blendMode(BLEND);
    imageMode(CORNER);
  }
}