//Ema Caragea, moved FlightArc class to a separate file, 15/03/2026, 15:00

// Ema Caragea, moved FlightArc class to a separate file, 15/03/2026
// Ema Caragea, refactored to hold screen reference, 18/03/2026

class FlightArc {
  FlightMapScreen    screen;
  AirportCoordinates origin;
  AirportCoordinates destination;
  String             status; // "onTime", "delayed", or "cancelled" to control color and plane icon

  float t;     //  animation parameter 0.0-1.0, position of the plane along the bezier curve
  float speed; //  randomised per arc so not all planes move in sync
  float cx1, cy1, cx2, cy2; // bezier control points that create the curved arc shape
  float midX, midY;

  PImage planeImg;
  int    planeSize = 28;

  boolean hovered;
  float   currentWeight; 
  float   currentAlpha;  

  //calculates bezier control points so the arc curves upward above the straight line route
  FlightArc(FlightMapScreen screen, String originCode, String destCode, String status) {
    this.screen      = screen;
    this.origin      = screen.findAirport(originCode);
    this.destination = screen.findAirport(destCode);
    this.status      = status;
    this.t           = 0.5; // start midway so not all planes appear at the origin at the same time
    this.speed       = random(0.0015, 0.003); // random speed
    this.hovered     = false;
    this.currentWeight = 1.5;
    this.currentAlpha  = 80;

    // find the midpoint between origin and destination, then lift the control points perpendicularly
    // to create a smooth upward curve  
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

    midX = bezierPoint(origin.x, cx1, cx2, destination.x, 0.5);
    midY = bezierPoint(origin.y, cy1, cy2, destination.y, 0.5);

    //  pick the correct plane image based on flight status, 14/03/2026
    if      (status.equals("onTime"))  planeImg = screen.planeOnTime;
    else if (status.equals("delayed")) planeImg = screen.planeDelayed;
    else                               planeImg = screen.planeCancelled;
  }

  // hover detection samples 21 points along the arc curve, cant just check endpoints
  void draw() {
    hovered = false;
    for (int i = 0; i <= 20; i++) {
      float sample = i / 20.0;
      float sx = bezierPoint(origin.x, cx1, cx2, destination.x, sample);
      float sy = bezierPoint(origin.y, cy1, cy2, destination.y, sample);
      if (dist(screen.mapView.mapMouseX(), screen.mapView.mapMouseY(), sx, sy) < 10) {
        hovered = true;
      }
    }

    // ease alpha and weight toward target values each frame so the hover transition is smooth
    float targetAlpha = hovered ? 220 : 50;
    currentWeight += (3.5 - currentWeight) * 0.1;
    currentAlpha  += (targetAlpha - currentAlpha) * 0.1;

    drawArcLine();
    drawPlane();

    // advance t and loop back to 0 when the plane reaches the destination
    t += speed;
    if (t > 1.0) t = 0.0;
  }

  boolean isClicked() {
    for (int i = 0; i <= 20; i++) {
      float sample = i / 20.0;
      float sx = bezierPoint(origin.x, cx1, cx2, destination.x, sample);
      float sy = bezierPoint(origin.y, cy1, cy2, destination.y, sample);
      if (dist(screen.mapView.mapMouseX(), screen.mapView.mapMouseY(), sx, sy) < 10) {
        return true;
      }
    }
    return false;
  }

  //draws the bezier curve in the correct status color with animated alpha and stroke weight
  void drawArcLine() {
    noFill();
    strokeWeight(currentWeight);
    if      (status.equals("onTime"))  stroke(129, 199, 132, currentAlpha); // green
    else if (status.equals("delayed")) stroke(255, 183, 77,   currentAlpha); // amber
    else                               stroke(239, 83, 80,  currentAlpha);  // red
    bezier(origin.x, origin.y, cx1, cy1, cx2, cy2, destination.x, destination.y);
  }

  //positions the plane along the arc using bezierPoint(t), rotates it to face its direction of travel
  void drawPlane() {
    float x = bezierPoint(origin.x, cx1, cx2, destination.x, t);
    float y = bezierPoint(origin.y, cy1, cy2, destination.y, t);

    //look slightly ahead on the curve to get the direction the plane should face
    float tAhead = min(t + 0.01, 1.0);
    float xAhead = bezierPoint(origin.x, cx1, cx2, destination.x, tAhead);
    float yAhead = bezierPoint(origin.y, cy1, cy2, destination.y, tAhead);
    float angle  = atan2(yAhead - y, xAhead - x); // atan2 gives the correct heading angle

    float drawSize = hovered ? planeSize * 1.4 : planeSize; // plane grows slightly on hover as feedback

    // SCREEN blend mode makes the plane icon glow slightly against the dark map background
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