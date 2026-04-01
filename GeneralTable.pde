import processing.event.MouseEvent;
import java.util.ArrayList;

// full table
ArrayList<Flight> fullTableAllFlights = new ArrayList<Flight>();
ArrayList<Flight> fullTableDayFlights = new ArrayList<Flight>();

String fullTableCurrentSort = "Flight No.";
String fullTableSelectedDate = "01/01/2022";

PFont fullTableTitleFont;

// layout
float fullTableButtonW, fullTableButtonH, fullTableButtonY, fullTableButtonGap;
float fullTableButtonX1, fullTableButtonX2;
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
  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,
  17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
};
int fullTableFirstDOW = 6;

String[] fullTableDayLabels = {"Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"};

// scroll
float fullTableScrollY = 0;
float fullTableMaxScroll = 0;
float fullTableScrollSpeed = 30;

boolean fullTableDraggingScrollbar = false;
float fullTableDragOffsetY = 0;


// setup
void fullTableSetup() {
  fullTableTitleFont = createFont("Helvetica Bold", 14);
  fullTableCalculateLayout();
  fullTableLoadFlightData();
  fullTableFilterByDate();
  fullTableSortByFlightNum();
}


// main draw
void fullTableDraw() {
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
}


// mouse
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
}

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


// layout
void fullTableCalculateLayout() {
  fullTableButtonW = width * 0.16;
  fullTableButtonH = height * 0.055;
  fullTableButtonY = height * 0.12;
  fullTableButtonGap = width * 0.025;

  float totalBW = fullTableButtonW * 2 + fullTableButtonGap;
  fullTableButtonX1 = width / 2.0 - totalBW / 2.0;
  fullTableButtonX2 = fullTableButtonX1 + fullTableButtonW + fullTableButtonGap;

  fullTableBookBtnW = 170;
  fullTableBookBtnH = fullTableButtonH;
  fullTableBookBtnX = width - fullTableBookBtnW - 40;
  fullTableBookBtnY = fullTableButtonY;

  fullTableCardX = 30;
  fullTableCardY = height * 0.21;
  fullTableCardW = width - 60;
  fullTableCardH = height - fullTableCardY - 30;

  fullTableCalBtnW = 190;
  fullTableCalBtnH = 30;
  fullTableCalBtnX = width - fullTableCalBtnW - 120;
  fullTableCalBtnY = 57;

  fullTableCalW = fullTableCalBtnW;
  fullTableCalH = 230;
  fullTableCalX = fullTableCalBtnX;
  fullTableCalY = fullTableCalBtnY + fullTableCalBtnH + 6;

  fullTableCellW = fullTableCalW / 7.0;
  fullTableCellH = (fullTableCalH - fullTableCalHeaderH - 22) / 6.0;
}


// data
void fullTableLoadFlightData() {
  Table table = loadTable("allFlights.csv", "header");

  if (table == null) {
    println("Could not load allFlights.csv");
    return;
  }

  fullTableAllFlights.clear();

  for (TableRow row : table.rows()) {
    fullTableAllFlights.add(new Flight(
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
  }
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
void fullTableDrawBackgroundDecor() {
  noStroke();
  fill(25, 35, 48, 70);
  ellipse(width - 160, 110, 280, 280);
  ellipse(130, height - 70, 220, 220);
}

void fullTableDrawHeader() {
  fill(240);
  textAlign(LEFT, TOP);
  textSize(28);
  text("Flight Dashboard", 40, 24);

  fill(150, 165, 180);
  textSize(14);
  text("Showing " + fullTableDayFlights.size() + " flights for " + fullTableSelectedDate + "  |  Sorted by " + fullTableCurrentSort, 40, 62);

  fullTableDrawDateButton();
}

void fullTableDrawDateButton() {
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
}

void fullTableDrawButtons() {
  fullTableDrawSortButton(fullTableButtonX1, fullTableButtonY, fullTableButtonW, fullTableButtonH, "Sort by Flight No.", fullTableCurrentSort.equals("Flight No."));
  fullTableDrawSortButton(fullTableButtonX2, fullTableButtonY, fullTableButtonW, fullTableButtonH, "Sort by Distance", fullTableCurrentSort.equals("Distance"));
}

void fullTableDrawSortButton(float x, float y, float w, float h, String label, boolean active) {
  boolean hov = mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;

  fill(active ? color(82, 156, 214) : hov ? color(52, 66, 84) : color(35, 45, 58));
  stroke(active ? color(120, 190, 245) : color(70, 90, 110));
  rect(x, y, w, h, 12);

  fill(240);
  textAlign(CENTER, CENTER);
  textSize(14);
  text(label, x + w / 2, y + h / 2);
}

void fullTableDrawBookFlightButton() {
  boolean hov = fullTableOverBookFlightButton();

  fill(hov ? color(100, 170, 230) : color(82, 156, 214));
  stroke(120, 190, 245);
  strokeWeight(1.5);
  rect(fullTableBookBtnX, fullTableBookBtnY, fullTableBookBtnW, fullTableBookBtnH, 12);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(14);
  text("Book Flight", fullTableBookBtnX + fullTableBookBtnW / 2, fullTableBookBtnY + fullTableBookBtnH / 2);
}

boolean fullTableOverBookFlightButton() {
  return mouseX >= fullTableBookBtnX && mouseX <= fullTableBookBtnX + fullTableBookBtnW &&
         mouseY >= fullTableBookBtnY && mouseY <= fullTableBookBtnY + fullTableBookBtnH;
}

void fullTableDrawTableCard() {
  noStroke();
  fill(28, 36, 46);
  rect(fullTableCardX, fullTableCardY, fullTableCardW, fullTableCardH, 18);

  fill(36, 46, 58);
  rect(fullTableCardX, fullTableCardY, fullTableCardW, 50, 18, 18, 0, 0);
}

void fullTableDrawTable() {
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

    fullTableDrawStatusPill(f, colStatus, y);
  }

  fullTableDrawScrollbar(tableTop, tableHeight, totalContentHeight);
}

void fullTableDrawScrollbar(float tableTop, float tableHeight, float totalContentHeight) {
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
}

void fullTableDrawStatusPill(Flight f, float x, float y) {
  String status = "On Time";
  int pillColor = color(70, 170, 120);

  if (f.getFlightCancelled() == 1) {
    status = "Canceled";
    pillColor = color(200, 70, 70);
  } else if (f.getFlightDiverted() == 1) {
    status = "Diverted";
    pillColor = color(220, 150, 60);
  }

  fill(pillColor);
  noStroke();
  rect(x, y - 11, 90, 22, 11);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(12);
  text(status, x + 45, y);
}

void fullTableDrawCalendar() {
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
}


// sort
void fullTableSortByFlightNum() {
  fullTableDayFlights.sort((a, b) -> Integer.compare(a.getFlightNumber(), b.getFlightNumber()));
  fullTableCurrentSort = "Flight No.";
}

void fullTableSortByDistance() {
  fullTableDayFlights.sort((a, b) -> Double.compare(a.getAirportDistanceInMiles(), b.getAirportDistanceInMiles()));
  fullTableCurrentSort = "Distance";
}


// small helpers
boolean fullTableHasDataForDay(int day) {
  for (int d : fullTableDataDays) {
    if (d == day) return true;
  }
  return false;
}

String fullTableDayString(int day) {
  return nf(fullTableCalMonth, 2) + "/" + nf(day, 2) + "/" + fullTableCalYear;
}

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

String fullTableGetSafeString(TableRow row, String column) {
  try {
    String v = row.getString(column);
    return v == null ? "" : trim(v);
  } catch (Exception e) {
    return "";
  }
}

int fullTableGetSafeInt(TableRow row, String column) {
  try {
    String v = row.getString(column);
    if (v == null || trim(v).equals("")) return 0;
    return int(trim(v));
  } catch (Exception e) {
    return 0;
  }
}

double fullTableGetSafeDouble(TableRow row, String column) {
  try {
    String v = row.getString(column);
    if (v == null || trim(v).equals("")) return 0;
    return Double.parseDouble(trim(v));
  } catch (Exception e) {
    return 0;
  }
}

int fullTableGetSafeIntFromString(String value) {
  value = trim(value);
  if (value.equals("")) return 0;
  try {
    return Integer.parseInt(value);
  } catch (Exception e) {
    return 0;
  }
}

String fullTableAirportCode(Flight f, boolean origin) {
  try {
    if (origin) return f.getOriginAirport().getAirportName();
    return f.getDestinationAirport().getAirportName();
  } catch (Exception e) {
    return "";
  }
}