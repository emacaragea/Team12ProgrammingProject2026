import processing.event.MouseEvent;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

// full table
//Jesse Margarits, 04/04, Trying to fix loading bug by implementing synchronized lists
List<Flight> fullTableAllFlights = Collections.synchronizedList(new ArrayList<Flight>());
List<Flight> fullTableDayFlights = Collections.synchronizedList(new ArrayList<Flight>());

String fullTableCurrentSort = "Flight No.";
String fullTableSelectedDate = "01/01/2022";


PFont fullTableTitleFont;

//Amanda de Moraes, 25/3, added variables for the general table, including layout dimensions, scroll state, and calendar state
// layout
float fullTableButtonW, fullTableButtonH, fullTableButtonY, fullTableButtonGap;
float fullTableButtonX1, fullTableButtonX2, fullTableButtonX3;
float fullTableCardX, fullTableCardY, fullTableCardW, fullTableCardH;

// book flight button
float fullTableBookBtnX, fullTableBookBtnY, fullTableBookBtnW, fullTableBookBtnH;

// calendar
float fullTableCalX, fullTableCalY, fullTableCalW, fullTableCalH;
float fullTableCalBtnX, fullTableCalBtnY, fullTableCalBtnW, fullTableCalBtnH;
float fullTableCellW, fullTableCellH;
float fullTableCalHeaderH = 36;
boolean fullTableCalOpen = false;

int fullTableCalYear = 2022;
int fullTableCalMonth = 1;
int[] fullTableDataDays = {
  1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
  17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
};
int fullTableFirstDOW = 6;

String[] fullTableDayLabels = {"Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"};

// scroll
float fullTableScrollY = 0;
float fullTableMaxScroll = 0;
float fullTableScrollSpeed = 30;

boolean fullTableDraggingScrollbar = false;
float fullTableDragOffsetY = 0;

volatile boolean generalTableValuesLoaded = false;



// setup
void fullTableSetup(Table table) {
  //Jesse Margarits, 04/04, Trying to fix loading bug by implementing Java threads
  fullTableTitleFont = createFont("Helvetica Bold", 14);

  final Table newTable = table;
  Thread tableThread = new Thread(new Runnable() {
    public void run() {
      fullTableCalculateLayout();
      fullTableLoadFlightData(newTable);
      fullTableFilterByDate();
      fullTableSortByFlightNum();
      generalTableValuesLoaded = true;
    }
  }
  );
  tableThread.start();
}


// Amanda de Moraes, 25/3, added method that draws the general table
void fullTableDraw() {
  pushStyle();
  background(18, 24, 32);
  fullTableDrawBackgroundDecor();
  fullTableDrawHeader();
  fullTableDrawButtons();
  fullTableDrawBookFlightButton();
  fullTableDrawTableCard();
  fullTableDrawTable();


  if (fullTableCalOpen) {
    fullTableDrawCalendar();
  }
  popStyle();
}


// Amanda de Moraes, 25/3, added method that handles mouse presses for the general table
void fullTableMousePressed() {
  if (fullTableOverBookFlightButton()) {
    currentView = CURRENT_VIEW_BOOK_FLIGHT;
    viewHistIndex++;
    viewHistory.add(viewHistIndex, currentView);
    return;
  }

  float tableTop = fullTableCardY + 55;
  float tableBottom = fullTableCardY + fullTableCardH - 10;
  float tableHeight = tableBottom - tableTop;
  float trackX = fullTableCardX + fullTableCardW - 18;
  float trackW = 10;

  if (fullTableMaxScroll > 0 &&
    mouseX >= trackX && mouseX <= trackX + trackW &&
    mouseY >= tableTop && mouseY <= tableBottom) {

    if (mouseY <= tableTop + 20) {
      fullTableScrollY = constrain(fullTableScrollY + fullTableScrollSpeed, -fullTableMaxScroll, 0);
      return;
    }

    if (mouseY >= tableTop + tableHeight - 20) {
      fullTableScrollY = constrain(fullTableScrollY - fullTableScrollSpeed, -fullTableMaxScroll, 0);
      return;
    }

    float totalContentHeight = fullTableDayFlights.size() * 32.0;
    float thumbAreaTop = tableTop + 22;
    float thumbAreaH = tableHeight - 44;
    float thumbH = max(30, thumbAreaH * (tableHeight / totalContentHeight));
    float scrollRatio = constrain(-fullTableScrollY / fullTableMaxScroll, 0, 1);
    float thumbY = thumbAreaTop + scrollRatio * (thumbAreaH - thumbH);

    if (mouseY >= thumbY && mouseY <= thumbY + thumbH) {
      fullTableDraggingScrollbar = true;
      fullTableDragOffsetY = mouseY - thumbY;
      return;
    }

    float clickRatio = constrain((mouseY - thumbAreaTop) / thumbAreaH, 0, 1);
    fullTableScrollY = -clickRatio * fullTableMaxScroll;
    return;
  }

  fullTableDraggingScrollbar = false;

  if (mouseX >= fullTableCalBtnX && mouseX <= fullTableCalBtnX + fullTableCalBtnW &&
    mouseY >= fullTableCalBtnY && mouseY <= fullTableCalBtnY + fullTableCalBtnH) {
    fullTableCalOpen = !fullTableCalOpen;
    return;
  }

  if (fullTableCalOpen) {
    float gridTop = fullTableCalY + fullTableCalHeaderH + 22;

    for (int day = 1; day <= 31; day++) {
      if (!fullTableHasDataForDay(day)) continue;

      int slot = day - 1 + fullTableFirstDOW;
      int col = slot % 7;
      int row = slot / 7;
      float cx = fullTableCalX + col * fullTableCellW + fullTableCellW / 2;
      float cy = gridTop + row * fullTableCellH + fullTableCellH / 2;

      if (dist(mouseX, mouseY, cx, cy) < fullTableCellW * 0.46) {
        fullTableSelectedDate = fullTableDayString(day);
        fullTableCalOpen = false;
        fullTableFilterByDate();

        if (fullTableCurrentSort.equals("Flight No.")) fullTableSortByFlightNum();
        else fullTableSortByDistance();

        return;
      }
    }

    if (mouseX < fullTableCalX || mouseX > fullTableCalX + fullTableCalW ||
      mouseY < fullTableCalY || mouseY > fullTableCalY + fullTableCalH) {
      fullTableCalOpen = false;
    }
    return;
  }

  if (mouseX >= fullTableButtonX1 && mouseX <= fullTableButtonX1 + fullTableButtonW &&
    mouseY >= fullTableButtonY && mouseY <= fullTableButtonY + fullTableButtonH) {
    fullTableSortByFlightNum();
  }

  if (mouseX >= fullTableButtonX2 && mouseX <= fullTableButtonX2 + fullTableButtonW &&
    mouseY >= fullTableButtonY && mouseY <= fullTableButtonY + fullTableButtonH) {
    fullTableSortByDistance();
  }
  if (mouseX >= fullTableButtonX3 && mouseX <= fullTableButtonX3 + fullTableButtonW &&
    mouseY >= fullTableButtonY && mouseY <= fullTableButtonY + fullTableButtonH) {
    fullTableSortByLateness();
  }
}
//Amanda de Moraes, 25/3, added method that handles mouse drags for the general table (for scrollbar dragging)
void fullTableMouseDragged() {
  if (!fullTableDraggingScrollbar) return;

  float tableTop = fullTableCardY + 55;
  float tableBottom = fullTableCardY + fullTableCardH - 10;
  float tableHeight = tableBottom - tableTop;
  float thumbAreaTop = tableTop + 22;
  float thumbAreaH = tableHeight - 44;
  float totalContentHeight = fullTableDayFlights.size() * 32.0;
  float thumbH = max(30, thumbAreaH * (tableHeight / totalContentHeight));

  float draggedRatio = constrain((mouseY - fullTableDragOffsetY - thumbAreaTop) / (thumbAreaH - thumbH), 0, 1);
  fullTableScrollY = -draggedRatio * fullTableMaxScroll;
  fullTableScrollY = constrain(fullTableScrollY, -fullTableMaxScroll, 0);
}

void fullTableMouseReleased() {
  fullTableDraggingScrollbar = false;
}

void fullTableMouseWheel(MouseEvent event) {
  fullTableScrollY -= event.getCount() * fullTableScrollSpeed;
  fullTableScrollY = constrain(fullTableScrollY, -fullTableMaxScroll, 0);
}


// Amanda de Moraes, 25/3, added method that calculates the layout for the general table
void fullTableCalculateLayout() {
  fullTableButtonW = width * 0.16;
  fullTableButtonH = height * 0.055;
  fullTableButtonY = height * 0.12;
  fullTableButtonGap = width * 0.09;//0.025;

  float totalBW = fullTableButtonW * 2 + fullTableButtonGap;
  fullTableButtonX1 = 30;//width / 3.0 - totalBW / 2.0;//-200;
  fullTableButtonX2 = fullTableButtonX1 + fullTableButtonW + fullTableButtonGap;
  fullTableButtonX3 = fullTableButtonX2 + fullTableButtonW + fullTableButtonGap;

  fullTableBookBtnW = 170;
  fullTableBookBtnH = fullTableButtonH;
  fullTableBookBtnX = width - fullTableBookBtnW - 40;
  fullTableBookBtnY = fullTableButtonY;

  fullTableCardX = 30;
  fullTableCardY = height * 0.21;
  fullTableCardW = width - 60;
  fullTableCardH = height - fullTableCardY - 30;

  fullTableCalBtnW = fullTableBookBtnW;
  fullTableCalBtnH = 30;
  fullTableCalBtnX = fullTableBookBtnX;
  fullTableCalBtnY = 57;

  fullTableCalW = fullTableCalBtnW;
  fullTableCalH = 230;
  fullTableCalX = fullTableCalBtnX;
  fullTableCalY = fullTableCalBtnY + fullTableCalBtnH + 6;

  fullTableCellW = fullTableCalW / 7.0;
  fullTableCellH = (fullTableCalH - fullTableCalHeaderH - 22) / 6.0;
}


// data
//Jesse Margarites, 7PM, 03/04, implementing a new loading screen for the general table
void fullTableLoadFlightData(Table table) {
  //generalTableValuesLoaded=false;
  //Table table = loadTable("flights_full.csv", "header");

  if (table == null) {
    println("Could not load allFlights.csv");
    return;
  }

  int total = table.getRowCount();

  //fullTableAllFlights.clear();
  //Jesse Margarits, 04/04, Trying to fix loading bug by creating a temp arrayList 
  List<Flight> temp = new ArrayList<Flight>();
  int counter =0;
  for (TableRow row : table.rows()) {
    temp.add(new Flight(
      fullTableGetSafeString(row, "FL_DATE"),
      fullTableGetSafeString(row, "MKT_CARRIER"),
      fullTableGetSafeIntFromString(fullTableGetSafeString(row, "MKT_CARRIER_FL_NUM")),
      new Airport(fullTableGetSafeString(row, "ORIGIN_CITY_NAME"), fullTableGetSafeInt(row, "ORIGIN_WAC")),
      new Airport(fullTableGetSafeString(row, "DEST_CITY_NAME"), fullTableGetSafeInt(row, "DEST_WAC")),
      fullTableGetSafeString(row, "CRS_DEP_TIME"),
      fullTableGetSafeString(row, "DEP_TIME"),
      fullTableGetSafeString(row, "CRS_ARR_TIME"),
      fullTableGetSafeString(row, "ARR_TIME"),
      fullTableGetSafeInt(row, "CANCELLED"),
      fullTableGetSafeInt(row, "DIVERTED"),
      fullTableGetSafeDouble(row, "DISTANCE")
      ));
    counter++;
    loadProgress = (float)(counter + 1) / total; 
    //Jesse Margarits, 04/04, Trying to fix loading bug by creating letting the thread sleeo every few lines
    if (counter %50 == 0) {
      try {
        Thread.sleep(1);
      }
      catch (InterruptedException e) {
      }
    }
  }
  fullTableAllFlights = Collections.synchronizedList(temp);
}

void fullTableFilterByDate() {
  fullTableDayFlights.clear();
  fullTableScrollY = 0;

  for (Flight f : fullTableAllFlights) {
    if (fullTableFormatDate(f.getFlightDate()).equals(fullTableSelectedDate)) {
      fullTableDayFlights.add(f);
    }
  }

  float rowH = 32;
  float tableTop = fullTableCardY + 55;
  float tableBottom = fullTableCardY + fullTableCardH - 10;
  float tableHeight = tableBottom - tableTop;
  float totalContent = fullTableDayFlights.size() * rowH;
  fullTableMaxScroll = max(0, totalContent - tableHeight);
}


// draw helpers
//Jesse Margarits, 04/04, Trying to fix loading bug by pushing and poping style on all methods
void fullTableDrawBackgroundDecor() {
  pushStyle();
  noStroke();
  fill(25, 35, 48, 70);
  ellipse(width - 160, 110, 280, 280);
  ellipse(130, height - 70, 220, 220);
  popStyle();
}

//Amanda de Moraes, 25/3, added method that draws the header for the general table
void fullTableDrawHeader() {
  pushStyle();
  fill(240);
  textAlign(LEFT, TOP);
  textSize(28);
  text("Flight Dashboard", 40, 24);

  fill(150, 165, 180);
  textSize(14);
  text("Showing " + fullTableDayFlights.size() + " flights for " + fullTableSelectedDate + "  |  Sorted by " + fullTableCurrentSort, 40, 62);

  fullTableDrawDateButton();
  popStyle();
}

//Amanda de Moraes, 25/3, added method that draws the date selection button for the general table
void fullTableDrawDateButton() {
  pushStyle();
  boolean hov = mouseX >= fullTableCalBtnX && mouseX <= fullTableCalBtnX + fullTableCalBtnW &&
    mouseY >= fullTableCalBtnY && mouseY <= fullTableCalBtnY + fullTableCalBtnH;

  fill(fullTableCalOpen ? color(82, 156, 214) : hov ? color(52, 66, 84) : color(35, 45, 58));
  stroke(fullTableCalOpen ? color(120, 190, 245) : color(70, 90, 110));
  strokeWeight(1.5);
  rect(fullTableCalBtnX, fullTableCalBtnY, fullTableCalBtnW, fullTableCalBtnH, 8);

  fill(240);
  textAlign(CENTER, CENTER);
  textSize(13);
  text("Date: " + fullTableSelectedDate, fullTableCalBtnX + fullTableCalBtnW / 2, fullTableCalBtnY + fullTableCalBtnH / 2);
  popStyle();
}

void fullTableDrawButtons() {
  fullTableDrawSortButton(fullTableButtonX1, fullTableButtonY, fullTableButtonW, fullTableButtonH, "Sort by Flight No.", fullTableCurrentSort.equals("Flight No."));
  fullTableDrawSortButton(fullTableButtonX2, fullTableButtonY, fullTableButtonW, fullTableButtonH, "Sort by Distance", fullTableCurrentSort.equals("Distance"));
  fullTableDrawSortButton(fullTableButtonX3, fullTableButtonY, fullTableButtonW, fullTableButtonH, "Sort by Lateness", fullTableCurrentSort.equals("Lateness"));

}

//Amanda de Moraes, 25/3, added method that draws the sort buttons for the general table
void fullTableDrawSortButton(float x, float y, float w, float h, String label, boolean active) {
  pushStyle();
  boolean hov = mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;

  fill(active ? color(82, 156, 214) : hov ? color(52, 66, 84) : color(35, 45, 58));
  stroke(active ? color(120, 190, 245) : color(70, 90, 110));
  rect(x, y, w, h, 12);

  fill(240);
  textAlign(CENTER, CENTER);
  textSize(14);
  text(label, x + w / 2, y + h / 2);
  popStyle();
}

//Amanda de Moraes, 25/3, added method that draws the "Book Flight" button for the general table
void fullTableDrawBookFlightButton() {
  pushStyle();
  boolean hov = fullTableOverBookFlightButton();

  fill(hov ? color(100, 170, 230) : color(82, 156, 214));
  stroke(120, 190, 245);
  strokeWeight(1.5);
  rect(fullTableBookBtnX, fullTableBookBtnY, fullTableBookBtnW, fullTableBookBtnH, 12);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(14);
  text("Book Flight", fullTableBookBtnX + fullTableBookBtnW / 2, fullTableBookBtnY + fullTableBookBtnH / 2);
  popStyle();
}

//Amanda de Moraes, 25/3, added method that checks if the mouse is hovering over the "Book Flight" button in the general table
boolean fullTableOverBookFlightButton() {
  return mouseX >= fullTableBookBtnX && mouseX <= fullTableBookBtnX + fullTableBookBtnW &&
    mouseY >= fullTableBookBtnY && mouseY <= fullTableBookBtnY + fullTableBookBtnH;
}


//Amanda de Moraes, 25/3, added method that draws the card background for the general table
void fullTableDrawTableCard() {
  pushStyle();
  noStroke();
  fill(28, 36, 46);
  rect(fullTableCardX, fullTableCardY, fullTableCardW, fullTableCardH, 18);

  fill(36, 46, 58);
  rect(fullTableCardX, fullTableCardY, fullTableCardW, 50, 18, 18, 0, 0);
  popStyle();
}

//Amanda de Moraes, 25/3, added method that draws the flight table for the general table
void fullTableDrawTable() {
  pushStyle();
  if (fullTableDayFlights.size() == 0) {
    fill(150, 165, 180);
    textAlign(CENTER, CENTER);
    textSize(18);
    text("No flights found for " + fullTableSelectedDate, width / 2, fullTableCardY + fullTableCardH / 2);
    return;
  }

  float pad = 24;
  float startX = fullTableCardX + pad;
  float endX = fullTableCardX + fullTableCardW - pad - 20;
  float usable = endX - startX;
  float headerY = fullTableCardY + 25;
  float rowH = 32;

  float colDate = startX;
  float colCarrier = startX + usable * 0.10;
  float colFlightNo = startX + usable * 0.20;
  float colOrigin = startX + usable * 0.34;
  float colDest = startX + usable * 0.47;
  float colDistance = startX + usable * 0.62;
  float colStatus = startX + usable * 0.76;
  float colDiverted = startX + usable * 0.90;

  textFont(fullTableTitleFont);
  fill(210, 220, 230);
  textAlign(LEFT, CENTER);
  textSize(14);
  text("Date", colDate, headerY);
  text("Carrier", colCarrier, headerY);
  text("Flight No.", colFlightNo, headerY);
  text("Origin", colOrigin, headerY);
  text("Destination", colDest, headerY);
  text("Distance", colDistance, headerY);
  text("Status", colStatus, headerY);
  text("Diverted", colDiverted, headerY);


  float tableTop = fullTableCardY + 55;
  float tableBottom = fullTableCardY + fullTableCardH - 10;
  float tableHeight = tableBottom - tableTop;

  float totalContentHeight = fullTableDayFlights.size() * rowH;
  fullTableMaxScroll = max(0, totalContentHeight - tableHeight);

  for (int i = 0; i < fullTableDayFlights.size(); i++) {
    Flight f = fullTableDayFlights.get(i);
    float rowTop = tableTop + fullTableScrollY + i * rowH;
    float y = rowTop + rowH / 2;

    if (rowTop + rowH < tableTop || rowTop > tableBottom) continue;

    fill(i % 2 == 0 ? color(33, 42, 54) : color(26, 34, 44));
    noStroke();
    rect(fullTableCardX + pad * 0.5, rowTop, fullTableCardW - pad - 16, rowH - 2, 8);

    fill(235, 240, 245);
    textAlign(LEFT, CENTER);
    textSize(13);

    text(fullTableFormatDate(f.getFlightDate()), colDate, y);
    text(f.getAirlineCode(), colCarrier, y);
    text(f.getAirlineCode() + str(f.getFlightNumber()), colFlightNo, y);
    text(fullTableAirportCode(f, true), colOrigin, y);
    text(fullTableAirportCode(f, false), colDest, y);
    text(round((float)f.getAirportDistanceInMiles()) + " mi", colDistance, y);

    fullTableDrawStatusPill(f, colStatus, y, fullTableCurrentSort);
    fullTableDrawCheckboxes(f, colDiverted, y, rowH);
  }

  fullTableDrawScrollbar(tableTop, tableHeight, totalContentHeight);
  popStyle();
}
    //Jesse Margarites, 11AM, 07/04, implemented diverted checkboxes

void fullTableDrawCheckboxes(Flight f, float colDiverted, float cy, float rowH){
    pushStyle();
    float checkbox_width = rowH/2;
    noFill();
    stroke(255, 255, 255);
    strokeWeight(1.2);
    float checkbox_x_coordinate = colDiverted;//+17
    float checkbox_y_coordinate = cy-13;

    //rect(checkbox_x_coordinate, checkbox_y_coordinate, checkbox_width, checkbox_width);
    if (f.getFlightDiverted() == 1) {
      strokeWeight(1.2);
      line(checkbox_x_coordinate+4, checkbox_y_coordinate+9, checkbox_x_coordinate+ checkbox_width/2-3, 
        checkbox_y_coordinate+ checkbox_width-5);
      line(checkbox_x_coordinate+ checkbox_width/2-3 , checkbox_y_coordinate+ checkbox_width-5, 
        checkbox_x_coordinate+ checkbox_width-3, checkbox_y_coordinate+3);

    }else{
      pushStyle();
      stroke(255, 255, 255);
      strokeWeight(1.2);
      line(checkbox_x_coordinate+4, checkbox_y_coordinate+4, checkbox_x_coordinate+ checkbox_width-4, 
        checkbox_y_coordinate+ checkbox_width-4);
      
      line(checkbox_x_coordinate+ checkbox_width-4, checkbox_y_coordinate+4, 
        checkbox_x_coordinate+4, checkbox_y_coordinate+ checkbox_width-4);

    }
    popStyle();

}

//Amanda de Moraes, 25/3, added method that draws the scrollbar for the flight table in the general table
void fullTableDrawScrollbar(float tableTop, float tableHeight, float totalContentHeight) {
  pushStyle();
  if (fullTableMaxScroll <= 0) return;

  float trackX = fullTableCardX + fullTableCardW - 18;
  float trackW = 10;

  noStroke();
  fill(40, 52, 64);
  rect(trackX, tableTop, trackW, tableHeight, 5);

  boolean upHov = mouseX >= trackX && mouseX <= trackX + trackW &&
    mouseY >= tableTop && mouseY <= tableTop + 20;
  fill(upHov ? color(100, 170, 230) : color(82, 156, 214));
  rect(trackX, tableTop, trackW, 20, 5);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(10);
  text("▲", trackX + trackW / 2, tableTop + 10);

  boolean downHov = mouseX >= trackX && mouseX <= trackX + trackW &&
    mouseY >= tableTop + tableHeight - 20 && mouseY <= tableTop + tableHeight;
  fill(downHov ? color(100, 170, 230) : color(82, 156, 214));
  rect(trackX, tableTop + tableHeight - 20, trackW, 20, 5);

  fill(255);
  text("▼", trackX + trackW / 2, tableTop + tableHeight - 10);

  float thumbAreaTop = tableTop + 22;
  float thumbAreaH = tableHeight - 44;
  float thumbH = max(30, thumbAreaH * (tableHeight / totalContentHeight));
  float scrollRatio = constrain(-fullTableScrollY / fullTableMaxScroll, 0, 1);
  float thumbY = thumbAreaTop + scrollRatio * (thumbAreaH - thumbH);

  boolean thumbHov = mouseX >= trackX && mouseX <= trackX + trackW &&
    mouseY >= thumbY && mouseY <= thumbY + thumbH;

  fill(fullTableDraggingScrollbar || thumbHov ? color(120, 190, 245) : color(82, 156, 214));
  rect(trackX, thumbY, trackW, thumbH, 5);
  popStyle();
}

void fullTableDrawStatusPill(Flight f, float x, float y, String fullTableCurrentSort) {
  pushStyle();
  String status = "On Time";
  int pillColor = color(70, 170, 120);

    //Jesse Margarites, 11AM, 07/04, implemented delayed status
    String actualArrivalTimeString;
    String scheduledArrivalTimeString;
    int actualArrivalTime;
    int scheduledArrivalTime;
    int delayedAmount;
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
    delayedAmount = Math.abs(actualArrivalTime-scheduledArrivalTime);
 


  if (f.getFlightCancelled() == 1) {
    status = "Canceled";
    pillColor = color(200, 70, 70);
  }
  else if ( actualArrivalTime > scheduledArrivalTime) {
    //Jesse Margarites & Niko Charles, 1PM, 08/04, implemented a delayed amount to sort by lateness

    if(!fullTableCurrentSort.equals("Lateness")){
      status="Delayed";
      pillColor = color(220, 150, 60);
    } else{
      status = Integer.toString(f.getDelayedAmount())+" min(s)";
      pillColor = color(220, 150, 60);

  }
}

  /*
  } else if (f.getFlightDiverted() == 1) {
    status = "Diverted";
    pillColor = color(220, 150, 60);
  }
    */

  fill(pillColor);
  noStroke();
  rect(x, y - 11, 90, 22, 11);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(12);
  text(status, x + 45, y);
  popStyle();
}

//Amanda de Moraes, 25/3, added method that draws the calendar for date selection in the general table
void fullTableDrawCalendar() {
  pushStyle();
  noStroke();
  fill(0, 0, 0, 80);
  rect(fullTableCalX + 4, fullTableCalY + 4, fullTableCalW, fullTableCalH, 14);

  fill(28, 36, 46);
  stroke(70, 90, 110);
  rect(fullTableCalX, fullTableCalY, fullTableCalW, fullTableCalH, 12);

  fill(36, 46, 58);
  noStroke();
  rect(fullTableCalX, fullTableCalY, fullTableCalW, fullTableCalHeaderH, 12, 12, 0, 0);

  fill(210, 225, 240);
  textAlign(CENTER, CENTER);
  textSize(13);
  text("January 2022", fullTableCalX + fullTableCalW / 2, fullTableCalY + fullTableCalHeaderH / 2);

  float labelY = fullTableCalY + fullTableCalHeaderH + 11;
  for (int d = 0; d < 7; d++) {
    fill(d == 0 || d == 6 ? color(150, 130, 180) : color(130, 145, 165));
    textAlign(CENTER, CENTER);
    textSize(10);
    text(fullTableDayLabels[d], fullTableCalX + d * fullTableCellW + fullTableCellW / 2, labelY);
  }

  float gridTop = fullTableCalY + fullTableCalHeaderH + 22;
  for (int day = 1; day <= 31; day++) {
    int slot = day - 1 + fullTableFirstDOW;
    int col = slot % 7;
    int row = slot / 7;
    float cx = fullTableCalX + col * fullTableCellW + fullTableCellW / 2;
    float cy = gridTop + row * fullTableCellH + fullTableCellH / 2;

    boolean hasData = fullTableHasDataForDay(day);
    boolean isSelected = fullTableSelectedDate.equals(fullTableDayString(day));
    boolean hovered = hasData && dist(mouseX, mouseY, cx, cy) < fullTableCellW * 0.46;

    if (isSelected) {
      fill(82, 156, 214);
      noStroke();
      ellipse(cx, cy, fullTableCellW * 0.78, fullTableCellW * 0.78);
    } else if (hovered) {
      fill(52, 66, 84);
      noStroke();
      ellipse(cx, cy, fullTableCellW * 0.78, fullTableCellW * 0.78);
    }

    if (hasData && !isSelected) {
      fill(100, 180, 120);
      noStroke();
      ellipse(cx, cy + fullTableCellH * 0.34, 4, 4);
    }

    if (!hasData) fill(55, 68, 85);
    else if (isSelected) fill(255);
    else fill(210, 225, 240);

    textAlign(CENTER, CENTER);
    textSize(11);
    text(str(day), cx, cy);
  }
  popStyle();
}


// Amanda de Moraes, 25/3, added methods that sort the flight data in the general table by flight number and distance
void fullTableSortByFlightNum() {
  fullTableDayFlights.sort((a, b) -> Integer.compare(a.getFlightNumber(), b.getFlightNumber()));
  fullTableCurrentSort = "Flight No.";
}

void fullTableSortByDistance() {
  fullTableDayFlights.sort((a, b) -> Double.compare(a.getAirportDistanceInMiles(), b.getAirportDistanceInMiles()));
  fullTableCurrentSort = "Distance";
}

void fullTableSortByLateness(){
  //fullTableDayFlights.sort((a,b) -> Integer.compare(a.getFlightCancelled(), b.getFlightCancelled()));
  fullTableDayFlights.sort((a, b) -> Integer.compare(a.getDelayedAmount(), b.getDelayedAmount()));
  fullTableCurrentSort = "Lateness";
}


// Amanda de Moraes, 25/3, added helper methods for the general table, including date formatting, safe data retrieval from the table, and checking if there is data for a given day
boolean fullTableHasDataForDay(int day) {
  for (int d : fullTableDataDays) {
    if (d == day) return true;
  }
  return false;
}

//Jesse Margarits, 04/04, added method that formats a day integer into a date string for the general table
String fullTableDayString(int day) {
  return nf(fullTableCalMonth, 2) + "/" + nf(day, 2) + "/" + fullTableCalYear;
}

//Amanda de Moraes, 25/3, added method that formats raw date strings from the flight data into a consistent format for the general table
String fullTableFormatDate(String rawDate) {
  rawDate = trim(rawDate);

  String datePart = rawDate.contains(" ") ? rawDate.split(" ")[0] : rawDate;
  String[] parts = datePart.split("/");

  if (parts.length == 3) {
    return nf(fullTableGetSafeIntFromString(parts[0]), 2) + "/" +
      nf(fullTableGetSafeIntFromString(parts[1]), 2) + "/" +
      fullTableGetSafeIntFromString(parts[2]);
  }

  return datePart;
}

//Amanda de Moraes, 25/3, added methods that safely retrieve string, integer, and double values from the flight data table for the general table
String fullTableGetSafeString(TableRow row, String column) {
  try {
    String v = row.getString(column);
    return v == null ? "" : trim(v);
  }
  catch (Exception e) {
    return "";
  }
}

//Amanda de Moraes, 25/3, added method that safely retrieves integer values from the flight data table for the general table, returning 0 if the value is missing or invalid
int fullTableGetSafeInt(TableRow row, String column) {
  try {
    String v = row.getString(column);
    if (v == null || trim(v).equals("")) return 0;
    return int(trim(v));
  }
  catch (Exception e) {
    return 0;
  }
}

//Amanda de Moraes, 25/3, added method that safely retrieves double values from the flight data table for the general table, returning 0 if the value is missing or invalid
double fullTableGetSafeDouble(TableRow row, String column) {
  try {
    String v = row.getString(column);
    if (v == null || trim(v).equals("")) return 0;
    return Double.parseDouble(trim(v));
  }
  catch (Exception e) {
    return 0;
  }
}

//Amanda de Moraes, 25/3, added method that safely retrieves integer values from strings for the general table, returning 0 if the value is missing or invalid
int fullTableGetSafeIntFromString(String value) {
  value = trim(value);
  if (value.equals("")) return 0;
  try {
    return Integer.parseInt(value);
  }
  catch (Exception e) {
    return 0;
  }
}

//Amanda de Moraes, 25/3, added method that safely retrieves the airport name for a flight's origin or destination for the general table
String fullTableAirportCode(Flight f, boolean origin) {
  try {
    if (origin) return f.getOriginAirport().getAirportName();
    return f.getDestinationAirport().getAirportName();
  }
  catch (Exception e) {
    return "";
  }
}

