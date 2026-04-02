//Amanda de Moraes, 25/03. Added code for the flights table
// TABLE NOTE:
// in main- call tableSetup() in setup()
// in ScreenClass - drawFlightScreen() must call tableDraw(), and mousePressed() must call tableMousePressed() when on the flight screen
// also add mouseWheel() in main to call tableMouseWheel() for scrolling
import processing.event.MouseEvent;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.HashMap;

// data lists
ArrayList<Flight> allFlights = new ArrayList<Flight>();
ArrayList<Flight> goFlights = new ArrayList<Flight>();
ArrayList<Flight> backFlights = new ArrayList<Flight>();
ArrayList<String> availableDates = new ArrayList<String>();

// store airport names separately so table does not depend on Airport methods
HashMap<Flight, String> originNameByFlight = new HashMap<Flight, String>();
HashMap<Flight, String> destNameByFlight = new HashMap<Flight, String>();

// selected flights
Flight selectedGoFlight = null;
Flight selectedBackFlight = null;

// table states inside flight screen
final int TABLE_DATE_SELECT = 0;
final int TABLE_BARCODE = 1;
final int TABLE_FLIGHT_SELECT = 2;
final int TABLE_BOOKED = 3;
int tableState = TABLE_DATE_SELECT;

// sort states
final String SORT_FLIGHT_NO = "Flight No.";
final String SORT_DISTANCE = "Distance";

// selected dates and sort option
String goDate = "";
String backDate = "";
String currentSort = SORT_FLIGHT_NO;

// calendar visibility
boolean showGoCalendar = false;
boolean showBackCalendar = false;

// barcode animation values
int barcodeStartTime = 0;
float scanX = 120;

// fonts
PFont titleFont;
PFont bodyFont;
PFont smallFont;
PFont boardFont;

// screen 1 button layout
float goBtnX, goBtnY, goBtnW, goBtnH;
float backBtnX, backBtnY, backBtnW, backBtnH;
float continueBtnX, continueBtnY, continueBtnW, continueBtnH;

// screen 2 layout
float cardX, cardY, cardW, cardH;
float sortBtn1X, sortBtn2X, sortBtnY, sortBtnW, sortBtnH;
float confirmBtnX, confirmBtnY, confirmBtnW, confirmBtnH;
float backToDatesBtnX, backToDatesBtnY, backToDatesBtnW, backToDatesBtnH;

// flight table layout
float goTableX, goTableY, goTableW, goTableH;
float backTableX, backTableY, backTableW, backTableH;

// calendar layout
float calW = 320;
float calH = 300;
float calHeaderH = 40;
float calCellW;
float calCellH;

// calendar date setup
int calMonth = 1;
int calYear = 2022;
int calFirstDayOfWeek = 6; // jan 1, 2022 was saturday
String[] calDayLabels = {"Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"};

// scroll values
float goScrollY = 0;
float backScrollY = 0;
float goMaxScroll = 0;
float backMaxScroll = 0;
float scrollSpeed = 28;


// call this once from setup()
void tableSetup() {
  titleFont = createFont("Helvetica Bold", 28);
  bodyFont = createFont("Helvetica", 14);
  smallFont = createFont("Helvetica", 12);
  boardFont = createFont("Helvetica Bold", 16);

  calculateTableLayout();
  loadFlightData();
  setDefaultDates();
}


// call this from drawFlightScreen()
void tableDraw() {
  if (tableState == TABLE_DATE_SELECT) {
    background(18, 24, 32);
    drawDateSelectionScreen();
    return;
  }

  if (tableState == TABLE_BARCODE) {
    drawBarcodeScreen("Verifying Boarding Pass...");

    if (millis() - barcodeStartTime >= 5000) {
      tableState = TABLE_FLIGHT_SELECT;
      scanX = getBoardingPassX();
    }
    return;
  }

  if (tableState == TABLE_FLIGHT_SELECT) {
    background(18, 24, 32);
    drawFlightSelectionScreen();
    return;
  }

  if (tableState == TABLE_BOOKED) {
    drawBarcodeScreen("Booking Confirmed");
  }
}


// call this from mousePressed() when flight screen is open
void tableMousePressed() {
  if (tableState == TABLE_DATE_SELECT) {
    handleDateScreenClicks();
  } else if (tableState == TABLE_FLIGHT_SELECT) {
    handleFlightScreenClicks();
  }
}


// call this from mouseWheel() when flight screen is open
void tableMouseWheel(MouseEvent event) {
  float amt = event.getCount() * scrollSpeed;

  if (tableState == TABLE_FLIGHT_SELECT) {
    if (overRect(goTableX, goTableY, goTableW, goTableH)) {
      goScrollY -= amt;
      goScrollY = constrain(goScrollY, -goMaxScroll, 0);
      return;
    }

    if (overRect(backTableX, backTableY, backTableW, backTableH)) {
      backScrollY -= amt;
      backScrollY = constrain(backScrollY, -backMaxScroll, 0);
      return;
    }
  }
}


// draws the first screen where dates are selected
void drawDateSelectionScreen() {
  fill(240);
  textFont(titleFont);
  textAlign(CENTER, TOP);
  textSize(28);
  text("Book a Flight", width / 2, 70);

  fill(150, 165, 180);
  textFont(bodyFont);
  textSize(16);
  text("Choose your departure and return dates first.", width / 2, 122);

  drawBigDateButton(goBtnX, goBtnY, goBtnW, goBtnH, "Select Departure Date", goDate, showGoCalendar);
  drawBigDateButton(backBtnX, backBtnY, backBtnW, backBtnH, "Select Return Date", backDate, showBackCalendar);

  boolean ready = datesAreValid();
  boolean hov = overRect(continueBtnX, continueBtnY, continueBtnW, continueBtnH);

  if (ready) {
    fill(hov ? color(92, 170, 230) : color(82, 156, 214));
    stroke(120, 190, 245);
  } else {
    fill(70);
    stroke(110);
  }
  strokeWeight(1.5);
  rect(continueBtnX, continueBtnY, continueBtnW, continueBtnH, 16);

  fill(255);
  textAlign(CENTER, CENTER);
  textFont(bodyFont);
  textSize(16);
  text("Continue", continueBtnX + continueBtnW / 2, continueBtnY + continueBtnH / 2);

  if (!goDate.equals("") && !backDate.equals("") && dateToNumber(backDate) < dateToNumber(goDate)) {
    fill(255, 120, 120);
    textAlign(CENTER, TOP);
    textFont(bodyFont);
    textSize(14);
    text("Return date cannot be before departure date.", width / 2, continueBtnY + continueBtnH + 14);
  }

  if (showGoCalendar) {
    drawCalendar(goBtnX + goBtnW / 2 - calW / 2, goBtnY + goBtnH + 18, "GO");
  }

  if (showBackCalendar) {
    drawCalendar(backBtnX + backBtnW / 2 - calW / 2, backBtnY + backBtnH + 18, "BACK");
  }
}


// draws a large date selection button
void drawBigDateButton(float x, float y, float w, float h, String title, String value, boolean active) {
  boolean hov = overRect(x, y, w, h);

  fill(active ? color(82, 156, 214) : hov ? color(52, 66, 84) : color(35, 45, 58));
  stroke(active ? color(120, 190, 245) : color(70, 90, 110));
  strokeWeight(1.8);
  rect(x, y, w, h, 18);

  fill(240);
  textAlign(CENTER, CENTER);
  textFont(bodyFont);
  textSize(19);
  text(title, x + w / 2, y + h / 2 - 18);

  fill(245);
  textSize(18);
  text(value.equals("") ? "No date selected" : value, x + w / 2, y + h / 2 + 22);
}


// draws the flight selection screen
void drawFlightSelectionScreen() {
  fill(240);
  textFont(titleFont);
  textAlign(LEFT, TOP);
  textSize(28);
  text("Choose Your Flights", 40, 24);

  fill(150, 165, 180);
  textFont(bodyFont);
  textSize(15);
  text("Departure date: " + goDate + "   |   Return date: " + backDate, 40, 70);

  drawStandardButton(sortBtn1X, sortBtnY, sortBtnW, sortBtnH, "Sort by Flight No.", currentSort.equals(SORT_FLIGHT_NO));
  drawStandardButton(sortBtn2X, sortBtnY, sortBtnW, sortBtnH, "Sort by Distance", currentSort.equals(SORT_DISTANCE));
  drawSecondaryButton(backToDatesBtnX, backToDatesBtnY, backToDatesBtnW, backToDatesBtnH, "Back");

  boolean ready = selectedGoFlight != null && selectedBackFlight != null;
  boolean hov = overRect(confirmBtnX, confirmBtnY, confirmBtnW, confirmBtnH);

  if (ready) {
    fill(hov ? color(92, 170, 230) : color(82, 156, 214));
    stroke(120, 190, 245);
  } else {
    fill(70);
    stroke(110);
  }
  strokeWeight(1.5);
  rect(confirmBtnX, confirmBtnY, confirmBtnW, confirmBtnH, 12);

  fill(255);
  textAlign(CENTER, CENTER);
  textFont(bodyFont);
  textSize(14);
  text("Confirm Booking", confirmBtnX + confirmBtnW / 2, confirmBtnY + confirmBtnH / 2);

  drawMainCard();
  drawFlightTables();
}


// draws the main dark card behind both tables
void drawMainCard() {
  noStroke();
  fill(28, 36, 46);
  rect(cardX, cardY, cardW, cardH, 18);

  fill(36, 46, 58);
  rect(cardX, cardY, cardW, 50, 18, 18, 0, 0);

  fill(220);
  textFont(bodyFont);
  textAlign(LEFT, CENTER);
  textSize(16);
  text("Departure Flights (" + goDate + ")", goTableX, cardY + 18);
  text("Return Flights (" + backDate + ")", backTableX, cardY + 18);
}


// draws both flight tables
void drawFlightTables() {
  drawFlightTable(goFlights, goTableX, goTableY, goTableW, goTableH, goScrollY, "DEPARTURE");
  drawFlightTable(backFlights, backTableX, backTableY, backTableW, backTableH, backScrollY, "RETURN");
}


// draws one flight table
void drawFlightTable(ArrayList<Flight> flights, float x, float y, float w, float h, float scrollY, String type) {
  float rowH = 34;
  float pad = 12;
  float startX = x + pad;
  float usable = w - 40;

  float colCarrier = startX;
  float colFlight = startX + usable * 0.18;
  float colOrigin = startX + usable * 0.36;
  float colDest = startX + usable * 0.56;
  float colDist = startX + usable * 0.76;

  fill(230);
  textFont(smallFont);
  textAlign(LEFT, CENTER);
  textSize(12);
  text("Carrier", colCarrier, y - 20);
  text("Flight", colFlight, y - 20);
  text("Origin", colOrigin, y - 20);
  text("Destination", colDest, y - 20);
  text("Distance", colDist, y - 20);

  if (flights.size() == 0) {
    fill(180);
    textFont(bodyFont);
    textAlign(CENTER, CENTER);
    textSize(16);
    text("No flights found", x + w / 2, y + h / 2);
    return;
  }

  float totalContentHeight = flights.size() * rowH;
  float maxScroll = max(0, totalContentHeight - h);

  if (type.equals("DEPARTURE")) goMaxScroll = maxScroll;
  if (type.equals("RETURN")) backMaxScroll = maxScroll;

  for (int i = 0; i < flights.size(); i++) {
    Flight f = flights.get(i);
    float rowTop = y + scrollY + i * rowH;
    float cy = rowTop + rowH / 2;

    if (rowTop + rowH < y || rowTop > y + h) continue;

    boolean selected =
      (type.equals("DEPARTURE") && selectedGoFlight == f) ||
      (type.equals("RETURN") && selectedBackFlight == f);

    fill(selected ? color(82, 156, 214) : (i % 2 == 0 ? color(33, 42, 54) : color(26, 34, 44)));
    noStroke();
    rect(x, rowTop, w - 14, rowH - 2, 8);

    String originName = "";
    String destName = "";

    if (originNameByFlight.containsKey(f)) {
      originName = originNameByFlight.get(f);
    }

    if (destNameByFlight.containsKey(f)) {
      destName = destNameByFlight.get(f);
    }

    fill(245);
    textFont(smallFont);
    textAlign(LEFT, CENTER);
    textSize(12);
    text(f.getAirlineCode(), colCarrier, cy);
    text(f.getAirlineCode() + " " + f.getFlightNumber(), colFlight, cy);
    text(originName, colOrigin, cy);
    text(destName, colDest, cy);
    text(round((float)f.getAirportDistanceInMiles()) + " mi", colDist, cy);
  }


  drawScrollbar(x + w - 8, y, h, totalContentHeight, maxScroll, scrollY);
}

//Jesse Margarites, 11PM, 31/03, created a filtered flight table
// draws one flight table
void drawFilteredFlightTable(ArrayList<Flight> flights, float x, float y, float w, float h, float scrollY, String type, int tableType) {
  //pushStyle();

  tableState=TABLE_FLIGHT_SELECT;
  float rowH = 40; //was 34
  float pad = 12;
  float startX = x + pad;
  float usable = w - 40;

  float colCarrier = startX;
  float colFlight = startX + usable * 0.18;
  float colOriginOrDest = startX + usable * 0.36;
  float colDist = startX + usable * 0.56;
  float colStatus = startX + usable * 0.76;

  fill(180);
  textFont(titleFont);
  textAlign(LEFT, CENTER);
  textSize(18);
  text("Page " + (tableType+1), startX, y - 40);



  fill(230);
  textFont(smallFont);
  textAlign(LEFT, CENTER);
  textSize(16); //was 13
  text("Carrier", colCarrier, y - 5); //y-5, y-20
  text("Flight", colFlight, y - 5);
  text("Distance", colDist, y - 5);
  text("Status", colStatus, y - 5);

  if (type.equals(("DEPARTURE"))) {
    pushStyle();
    fill(230);
    text("Destination", colOriginOrDest, y - 5);
    popStyle();
  } else if (type.equals(("RETURN"))) {
    pushStyle();
    text("Origin", colOriginOrDest, y - 5);
    popStyle();
  }

  if (flights.size() == 0) {
    fill(180);
    textFont(bodyFont);
    textAlign(CENTER, CENTER);
    textSize(16);
    text("No flights found", x + w / 2, y + h / 2);
    return;
  }

  float totalContentHeight = flights.size() * rowH;
  float maxScroll = max(0, totalContentHeight - h);

  /*

   if (type.equals("DEPARTURE")) goMaxScroll = maxScroll;
   if (type.equals("RETURN")) backMaxScroll = maxScroll;
   */


  //Jesse Margarites, 11PM, 01/04, implemented arrows to cycle through flights within flitered flight table
  int i= tableType*15;
  int maxI = i + 14;
  if (flights.size()-1<maxI) {
    maxI = flights.size()-1;
  }
  int rowCounter=0;

  while ( i < maxI) {//why must i redeclare i
    Flight f = flights.get(i);

    float rowTop = y + scrollY + rowCounter * rowH;
    float cy = rowTop + rowH / 2;

    if (rowTop + rowH < y || rowTop > y + h) continue;

    /*
    boolean selected =
     (type.equals("DEPARTURE") && selectedGoFlight == f) ||
     (type.equals("RETURN") && selectedBackFlight == f);
     */

    fill((rowCounter % 2 == 0 ? color(33, 42, 54) : color(26, 34, 44)));
    noStroke();
    rect(x, rowTop, w - 14, rowH - 2, 8);

    /*
    String originName = "";
     String destName = "";
     
     if (originNameByFlight.containsKey(f)) {
     originName = originNameByFlight.get(f);
     }
     
     if (destNameByFlight.containsKey(f)) {
     destName = destNameByFlight.get(f);
     }
     */


    fill(245); //was 245
    textFont(smallFont);
    textAlign(LEFT, CENTER);
    textSize(14);//was 12
    text(f.getAirlineCode(), colCarrier, cy);
    text(f.getAirlineCode() + " " + f.getFlightNumber(), colFlight, cy);

    //Jesse Margarites, 3PM, 01/04, implemented status for airport
    String currentStatus = "On time";
    //Niko Charles 9:00 02/04/2026 edit method to calculate delays
    //format scheduled arrival and departure time
    String actualArrivalTimeString;
    String scheduledArrivalTimeString;
    int actualArrivalTime;
    int scheduledArrivalTime;
    actualArrivalTimeString = f.getActualArrivalTime();
    scheduledArrivalTimeString = f.getScheduledArrivalTime();
    if (actualArrivalTimeString != null && scheduledArrivalTimeString != null && !actualArrivalTimeString.trim().isEmpty()
      && !scheduledArrivalTimeString.trim().isEmpty()) {
        actualArrivalTime = Integer.valueOf(actualArrivalTimeString.trim());
        scheduledArrivalTime = Integer.valueOf(scheduledArrivalTimeString.trim());
    }else {
      actualArrivalTime = 0;
      scheduledArrivalTime = 0;
    }
    String actualDepartTimeString;
    String scheduledDepartTimeString;
    int actualDepartTime;
    int scheduledDepartTime;
    actualDepartTimeString = f.getActualDepartureTime();
    scheduledDepartTimeString = f.getScheduledDepartureTime();
    if (actualDepartTimeString != null && scheduledDepartTimeString != null && !actualDepartTimeString.trim().isEmpty()
      && !scheduledDepartTimeString.trim().isEmpty()) {
        actualDepartTime = Integer.valueOf(actualDepartTimeString.trim());
        scheduledDepartTime = Integer.valueOf(scheduledDepartTimeString.trim());
    } else {
      actualDepartTime = 0;
      scheduledDepartTime = 0;
    }

    if (f.getFlightCancelled()==1) {
      pushStyle();
      currentStatus = "Cancelled";
      noStroke();
      fill(CANCELLED_COLOR);
      circle(colStatus-20, cy, rowH/2-5);
      popStyle();
      //CHANGE HERE
    } else if ((type.equals("RETURN") && actualArrivalTime > scheduledArrivalTime) || ((type.equals(("DEPARTURE")) && actualDepartTime > scheduledDepartTime))) {
      pushStyle();
      currentStatus="Delayed";
      noStroke();
      fill(DELAYED_COLOR);
      circle(colStatus-20, cy, rowH/2-5);
      popStyle();
    } else {
      pushStyle();
      noStroke();
      fill(ON_TIME_COLOR);
      circle(colStatus-20, cy, rowH/2-5);
      popStyle();
    }
    text(currentStatus, colStatus, cy);
    if (type.equals(("DEPARTURE"))) {
      text(f.getDestinationAirport().getAirportName(), colOriginOrDest, cy);    // text(destName, colDest, cy);
    } else if (type.equals(("RETURN"))) {
      text(f.getOriginAirport().getAirportName(), colOriginOrDest, cy);      //getOriginAirport is not working
    }

    text(round((float)f.getAirportDistanceInMiles()) + " mi", colDist, cy);
    rowCounter++;
    i++;
  }

  //  drawScrollbar(0, HOME_BAR_HEIGHT+80+HEADINGS_SIZE, SCREEN_HEIGHT-HOME_BAR_HEIGHT*2, SCREEN_HEIGHT, HOME_BAR_HEIGHT+80+HEADINGS_SIZE, 0); //currentScroll
  //drawScrollbar(SCREEN_DIVIDER_X_COORDINATE-20, HOME_BAR_HEIGHT+80+HEADINGS_SIZE, SCREEN_HEIGHT-HOME_BAR_HEIGHT*2, totalContentHeight, maxScroll, scrollY); //currentScroll
  //popStyle();
}



// draws the popup calendar
void drawCalendar(float x, float y, String which) {
  noStroke();
  fill(0, 0, 0, 90);
  rect(x + 4, y + 4, calW, calH, 14);

  fill(28, 36, 46);
  stroke(70, 90, 110);
  strokeWeight(1.3);
  rect(x, y, calW, calH, 12);

  fill(36, 46, 58);
  noStroke();
  rect(x, y, calW, calHeaderH, 12, 12, 0, 0);

  fill(245);
  textAlign(CENTER, CENTER);
  textFont(bodyFont);
  textSize(16);
  text(which.equals("GO") ? "Choose Departure Date" : "Choose Return Date", x + calW / 2, y + calHeaderH / 2);

  float labelY = y + calHeaderH + 12;
  textFont(smallFont);
  textSize(12);

  for (int i = 0; i < 7; i++) {
    fill(185, 195, 210);
    text(calDayLabels[i], x + i * calCellW + calCellW / 2, labelY);
  }

  float gridTop = y + calHeaderH + 22;

  for (int day = 1; day <= 31; day++) {
    int slot = (day - 1) + calFirstDayOfWeek;
    int col = slot % 7;
    int row = slot / 7;

    float cellX = x + col * calCellW;
    float cellY = gridTop + row * calCellH;
    float cx = cellX + calCellW / 2;
    float cy = cellY + calCellH / 2;

    String fullDate = buildCalendarDate(day);
    boolean hasFlights = availableDates.contains(fullDate);

    boolean disabledForBack = which.equals("BACK") && !goDate.equals("") && dateToNumber(fullDate) < dateToNumber(goDate);
    boolean isSelected = which.equals("GO") ? fullDate.equals(goDate) : fullDate.equals(backDate);

    boolean hovered =
      mouseX >= cellX + 3 && mouseX <= cellX + calCellW - 3 &&
      mouseY >= cellY + 3 && mouseY <= cellY + calCellH - 3;

    if (isSelected) {
      fill(82, 156, 214);
      rect(cellX + 3, cellY + 3, calCellW - 6, calCellH - 6, 8);
    } else if (hovered && !disabledForBack) {
      fill(52, 66, 84);
      rect(cellX + 3, cellY + 3, calCellW - 6, calCellH - 6, 8);
    }

    if (disabledForBack) fill(110);
    else if (isSelected) fill(255);
    else if (hasFlights) fill(245);
    else fill(185);

    textAlign(CENTER, CENTER);
    textFont(bodyFont);
    textSize(16);
    text(str(day), cx, cy - 4);

    if (hasFlights && !disabledForBack) {
      fill(100, 220, 120);
      ellipse(cx, cy + 12, 6, 6);
    }
  }
}


// draws the boarding pass screen
void drawBarcodeScreen(String statusText) {
  background(18, 24, 32);

  float panelW = 580;
  float panelH = 340;
  float panelX = width / 2 - panelW / 2;
  float panelY = height / 2 - panelH / 2 - 30;

  noStroke();
  fill(28, 36, 46);
  rect(panelX, panelY, panelW, panelH, 18);

  fill(36, 46, 58);
  rect(panelX, panelY, panelW, 56, 18, 18, 0, 0);

  fill(240);
  textFont(titleFont);
  textAlign(CENTER, CENTER);
  textSize(24);
  text("BOARDING PASS", width / 2, panelY + 28);

  float passX = getBoardingPassX();
  float passY = panelY + 70;
  float passW = 440;
  float passH = 170;

  fill(255);
  stroke(180);
  strokeWeight(1.2);
  rect(passX, passY, passW, passH, 10);

  fill(40, 60, 90);
  textFont(boardFont);
  textAlign(LEFT, BASELINE);
  textSize(18);
  text("BOARDING PASS", passX + 22, passY + 34);

  fill(50);
  textFont(bodyFont);
  textSize(15);

  String flightCode = selectedGoFlight != null ? selectedGoFlight.getAirlineCode() + " " + selectedGoFlight.getFlightNumber() : "BA204";
  text("Passenger: user", passX + 22, passY + 68);
  text("Flight: " + flightCode, passX + 22, passY + 92);
  text("Gate: A12", passX + 22, passY + 116);
  text("Seat: 14C", passX + 22, passY + 140);

  stroke(36, 46, 58);
  strokeWeight(2);
  for (int i = 0; i < 72; i++) {
    line(passX + 235 + i * 2, passY + 42, passX + 235 + i * 2, passY + 138);
  }

  noStroke();
  fill(82, 156, 214, 140);
  rect(scanX, passY, 5, passH);

  scanX += 3;
  if (scanX > passX + passW) {
    scanX = passX;
  }

  fill(210, 220, 230);
  textAlign(CENTER, CENTER);
  textFont(bodyFont);
  textSize(16);
  text(statusText, width / 2, panelY + 295);
}


// draws a main button
void drawStandardButton(float x, float y, float w, float h, String label, boolean active) {
  boolean hov = overRect(x, y, w, h);

  fill(active ? color(82, 156, 214) : hov ? color(52, 66, 84) : color(35, 45, 58));
  stroke(active ? color(120, 190, 245) : color(70, 90, 110));
  strokeWeight(1.5);
  rect(x, y, w, h, 12);

  fill(240);
  textAlign(CENTER, CENTER);
  textFont(bodyFont);
  textSize(14);
  text(label, x + w / 2, y + h / 2);
}


// draws a secondary button
void drawSecondaryButton(float x, float y, float w, float h, String label) {
  boolean hov = overRect(x, y, w, h);

  fill(hov ? color(52, 66, 84) : color(35, 45, 58));
  stroke(70, 90, 110);
  strokeWeight(1.5);
  rect(x, y, w, h, 12);

  fill(240);
  textAlign(CENTER, CENTER);
  textFont(bodyFont);
  textSize(14);
  text(label, x + w / 2, y + h / 2);
}


// draws a scrollbar for the tables
void drawScrollbar(float x, float y, float h, float totalContentHeight, float maxScroll, float currentScroll) {
  if (maxScroll <= 0) return;

  noStroke();
  fill(40, 52, 64);
  rect(x, y, 6, h, 5);

  float thumbH = max(30, h * (h / totalContentHeight));
  float ratio = constrain(-currentScroll / maxScroll, 0, 1);
  float thumbY = y + ratio * (h - thumbH);

  fill(100, 170, 230);
  rect(x, thumbY, 6, thumbH, 5);
}


// handles clicks on the date selection screen
void handleDateScreenClicks() {
  float goCalX = goBtnX + goBtnW / 2 - calW / 2;
  float goCalY = goBtnY + goBtnH + 18;

  float backCalX = backBtnX + backBtnW / 2 - calW / 2;
  float backCalY = backBtnY + backBtnH + 18;

  if (showGoCalendar) {
    if (handleCalendarClick(goCalX, goCalY, "GO")) return;
    if (overRect(goCalX, goCalY, calW, calH)) return;
    if (!overRect(goBtnX, goBtnY, goBtnW, goBtnH)) {
      showGoCalendar = false;
    }
  }

  if (showBackCalendar) {
    if (handleCalendarClick(backCalX, backCalY, "BACK")) return;
    if (overRect(backCalX, backCalY, calW, calH)) return;
    if (!overRect(backBtnX, backBtnY, backBtnW, backBtnH)) {
      showBackCalendar = false;
    }
  }

  if (overRect(goBtnX, goBtnY, goBtnW, goBtnH)) {
    showGoCalendar = !showGoCalendar;
    showBackCalendar = false;
    return;
  }

  if (overRect(backBtnX, backBtnY, backBtnW, backBtnH)) {
    showBackCalendar = !showBackCalendar;
    showGoCalendar = false;
    return;
  }

  if (overRect(continueBtnX, continueBtnY, continueBtnW, continueBtnH)) {
    if (datesAreValid()) {
      updateFlightLists();
      sortCurrentFlights();
      tableState = TABLE_BARCODE;
      barcodeStartTime = millis();
      scanX = getBoardingPassX();
      showGoCalendar = false;
      showBackCalendar = false;
    }
  }
}


// handles clicking a calendar day
boolean handleCalendarClick(float x, float y, String which) {
  float gridTop = y + calHeaderH + 22;

  for (int day = 1; day <= 31; day++) {
    int slot = (day - 1) + calFirstDayOfWeek;
    int col = slot % 7;
    int row = slot / 7;

    float cellX = x + col * calCellW;
    float cellY = gridTop + row * calCellH;

    if (mouseX >= cellX + 3 && mouseX <= cellX + calCellW - 3 &&
      mouseY >= cellY + 3 && mouseY <= cellY + calCellH - 3) {

      String fullDate = buildCalendarDate(day);

      if (which.equals("GO")) {
        goDate = fullDate;

        if (!backDate.equals("") && dateToNumber(backDate) < dateToNumber(goDate)) {
          backDate = goDate;
        }

        showGoCalendar = false;
      } else {
        if (!goDate.equals("") && dateToNumber(fullDate) < dateToNumber(goDate)) {
          return true;
        }

        backDate = fullDate;
        showBackCalendar = false;
      }
      return true;
    }
  }
  return false;
}


// handles clicks on the flight selection screen
void handleFlightScreenClicks() {
  if (overRect(sortBtn1X, sortBtnY, sortBtnW, sortBtnH)) {
    sortByFlightNum();
    return;
  }

  if (overRect(sortBtn2X, sortBtnY, sortBtnW, sortBtnH)) {
    sortByDistance();
    return;
  }

  if (overRect(backToDatesBtnX, backToDatesBtnY, backToDatesBtnW, backToDatesBtnH)) {
    tableState = TABLE_DATE_SELECT;
    selectedGoFlight = null;
    selectedBackFlight = null;
    return;
  }

  if (overRect(confirmBtnX, confirmBtnY, confirmBtnW, confirmBtnH)) {
    if (selectedGoFlight != null && selectedBackFlight != null) {
      tableState = TABLE_BOOKED;
      scanX = getBoardingPassX();
    }
    return;
  }

  Flight clickedGo = getClickedFlight(goFlights, goTableX, goTableY, goTableW, goTableH, goScrollY);
  if (clickedGo != null) {
    selectedGoFlight = clickedGo;
    return;
  }

  Flight clickedBack = getClickedFlight(backFlights, backTableX, backTableY, backTableW, backTableH, backScrollY);
  if (clickedBack != null) {
    selectedBackFlight = clickedBack;
    return;
  }
}


// calculates positions and sizes
void calculateTableLayout() {
  goBtnW = 320;
  goBtnH = 110;
  goBtnX = width / 2 - goBtnW - 30;
  goBtnY = 190;

  backBtnW = 320;
  backBtnH = 110;
  backBtnX = width / 2 + 30;
  backBtnY = 190;

  continueBtnW = 220;
  continueBtnH = 55;
  continueBtnX = width / 2 - continueBtnW / 2;
  continueBtnY = 360;

  sortBtnW = 180;
  sortBtnH = 40;
  sortBtnY = 92;
  sortBtn1X = 40;
  sortBtn2X = sortBtn1X + sortBtnW + 18;

  backToDatesBtnW = 100;
  backToDatesBtnH = 40;
  backToDatesBtnX = width - 360;
  backToDatesBtnY = 92;

  confirmBtnW = 180;
  confirmBtnH = 42;
  confirmBtnX = width - 240;
  confirmBtnY = 90;

  cardX = 30;
  cardY = 150;
  cardW = width - 60;
  cardH = height - cardY - 30;

  float innerPad = 20;
  float tableGap = 24;

  goTableX = cardX + innerPad;
  goTableY = cardY + 60;
  goTableW = (cardW - innerPad * 2 - tableGap) / 2.0;
  goTableH = cardH - 85;

  backTableX = goTableX + goTableW + tableGap;
  backTableY = goTableY;
  backTableW = goTableW;
  backTableH = goTableH;

  calCellW = calW / 7.0;
  calCellH = (calH - calHeaderH - 30) / 6.0;
}


// checks whether mouse is over a rectangle
boolean overRect(float x, float y, float w, float h) {
  return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
}


// checks whether selected dates are valid
boolean datesAreValid() {
  return !goDate.equals("") && !backDate.equals("") && dateToNumber(backDate) >= dateToNumber(goDate);
}


// builds a date string for the current calendar month
String buildCalendarDate(int day) {
  return nf(calMonth, 2) + "/" + nf(day, 2) + "/" + calYear;
}


// returns the left x position of the boarding pass
float getBoardingPassX() {
  return width / 2 - 220;
}


// checks which flight row was clicked
Flight getClickedFlight(ArrayList<Flight> flights, float x, float y, float w, float h, float scrollY) {
  float rowH = 34;

  for (int i = 0; i < flights.size(); i++) {
    float rowTop = y + scrollY + i * rowH;
    if (rowTop + rowH < y || rowTop > y + h) continue;

    if (mouseX >= x && mouseX <= x + w - 14 &&
      mouseY >= rowTop && mouseY <= rowTop + rowH - 2) {
      return flights.get(i);
    }
  }
  return null;
}


// loads flight data from csv
void loadFlightData() {
  String[] lines = loadStrings("allFlights.csv");

  if (lines == null || lines.length == 0) {
    println("ERROR");
    return;
  }

  LinkedHashSet<String> uniqueDates = new LinkedHashSet<String>();

  int startLine = 0;
  if (trim(lines[0]).toLowerCase().startsWith("fl_date")) {
    startLine = 1;
  }

  originNameByFlight.clear();
  destNameByFlight.clear();

  for (int li = startLine; li < lines.length; li++) {
    String line = trim(lines[li]);
    if (line.equals("")) continue;

    String[] cols = parseCSVLine(line);
    if (cols.length < 18) continue;

    String cleanDate = extractDateOnly(cols[0]);

    String originName = cols[3];
    String destName = cols[7];

    Flight f = new Flight(
      cleanDate,
      cols[1],
      parseSafeInt(cols[2]),
      null,
      null,
      cols[11],
      cols[12],
      cols[13],
      cols[14],
      parseSafeInt(cols[15]),
      parseSafeInt(cols[16]),
      parseSafeInt(cols[17])
      );

    allFlights.add(f);
    uniqueDates.add(cleanDate);
    originNameByFlight.put(f, originName);
    destNameByFlight.put(f, destName);
  }

  availableDates.clear();
  availableDates.addAll(uniqueDates);
  Collections.sort(availableDates, new DateComparator());

  println("Loaded " + allFlights.size() + " flights.");
  println("Loaded " + availableDates.size() + " dates.");
}


// splits one csv line safely, including quoted values
String[] parseCSVLine(String line) {
  ArrayList<String> fields = new ArrayList<String>();
  StringBuilder sb = new StringBuilder();
  boolean inQuotes = false;

  for (int i = 0; i < line.length(); i++) {
    char c = line.charAt(i);

    if (c == '"') {
      if (inQuotes && i + 1 < line.length() && line.charAt(i + 1) == '"') {
        sb.append('"');
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (c == ',' && !inQuotes) {
      fields.add(trim(sb.toString()));
      sb.setLength(0);
    } else {
      sb.append(c);
    }
  }

  fields.add(trim(sb.toString()));
  return fields.toArray(new String[0]);
}


// picks default dates from the first available date
void setDefaultDates() {
  if (availableDates.size() > 0) {
    goDate = availableDates.get(0);
    backDate = availableDates.get(0);
  }
}


// updates the departure and return flight lists
void updateFlightLists() {
  goFlights.clear();
  backFlights.clear();

  goScrollY = 0;
  backScrollY = 0;
  selectedGoFlight = null;
  selectedBackFlight = null;

  for (Flight f : allFlights) {
    if (f.getFlightDate().equals(goDate)) goFlights.add(f);
    if (f.getFlightDate().equals(backDate)) backFlights.add(f);
  }
}


// sorts based on the current sort mode
void sortCurrentFlights() {
  if (currentSort.equals(SORT_DISTANCE)) {
    sortByDistance();
  } else {
    sortByFlightNum();
  }
}


// sorts flights by flight number
void sortByFlightNum() {
  Collections.sort(goFlights, new Comparator<Flight>() {
    public int compare(Flight a, Flight b) {
      return a.getFlightNumber() - b.getFlightNumber();
    }
  }
  );

  Collections.sort(backFlights, new Comparator<Flight>() {
    public int compare(Flight a, Flight b) {
      return a.getFlightNumber() - b.getFlightNumber();
    }
  }
  );

  currentSort = SORT_FLIGHT_NO;
}


// sorts flights by distance
void sortByDistance() {
  Collections.sort(goFlights, new Comparator<Flight>() {
    public int compare(Flight a, Flight b) {
      return round((float)a.getAirportDistanceInMiles()) - round((float)b.getAirportDistanceInMiles());
    }
  }
  );

  Collections.sort(backFlights, new Comparator<Flight>() {
    public int compare(Flight a, Flight b) {
      return round((float)a.getAirportDistanceInMiles()) - round((float)b.getAirportDistanceInMiles());
    }
  }
  );

  currentSort = SORT_DISTANCE;
}


// cleans a raw date value
String extractDateOnly(String rawDate) {
  rawDate = trim(rawDate);
  if (rawDate.equals("")) return "";

  if (rawDate.contains(" ")) {
    rawDate = split(rawDate, ' ')[0];
  }

  return normalizeDate(rawDate);
}


// makes sure the date has mm/dd/yyyy format
String normalizeDate(String d) {
  String[] p = split(d, '/');
  if (p.length == 3) {
    return nf(parseSafeInt(p[0]), 2) + "/" + nf(parseSafeInt(p[1]), 2) + "/" + parseSafeInt(p[2]);
  }
  return d;
}


// safely converts text to integer
int parseSafeInt(String value) {
  value = trim(value);
  if (value.equals("")) return 0;

  try {
    return round(Float.parseFloat(value));
  }
  catch (Exception e) {
    return 0;
  }
}


// used to sort date strings in correct order
class DateComparator implements Comparator<String> {
  public int compare(String a, String b) {
    return dateToNumber(a) - dateToNumber(b);
  }
}


// turns a date string into a number for comparison
int dateToNumber(String d) {
  String[] p = split(d, '/');
  if (p.length != 3) return 0;
  return parseSafeInt(p[2]) * 10000 + parseSafeInt(p[0]) * 100 + parseSafeInt(p[1]);
}

