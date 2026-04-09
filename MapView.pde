// Ema Caragea, added edge clamping to MapView, 21/3/2026
//Ema Caragea, made edges of map non-draggable and non-zoomable, 26/3/2026, 17:00
//Ema Caragea, MapView is a separate class so FlightMapScreen stays clean, all pan/zoom logic lives here, 21/03/2026

class MapView {
  float zoom;
  float offsetX;   // how far the map has been panned horizontally
  float offsetY;   // how far the map has been panned vertically
  float dragStartX;
  float dragStartY;
  float offsetStartX; // stores where the offset was when dragging started, so drag delta is calculated correctly
  float offsetStartY;
  boolean dragging;

  // starts fully zoomed out and centred
  MapView() {
    zoom     = 1.0;
    offsetX  = 0;
    offsetY  = 0;
    dragging = false;
  }

  // called before drawing map content 
  void begin() {
    pushMatrix();
    translate(offsetX, offsetY);
    scale(zoom);
  }

  // called after drawing map content and restores the coordinate system
  void end() {
    popMatrix();
  }

  // snapshots the current offset so drag delta can be calculated cleanly in updateDrag, 21/03/2026
  void startDrag() {
    dragging     = true;
    dragStartX   = mouseX;
    dragStartY   = mouseY;
    offsetStartX = offsetX;
    offsetStartY = offsetY;
  }

  // updates pan offset as mouse moves, then clamps so the map cant be dragged off screen
  void updateDrag() {
    if (dragging) {
      offsetX = offsetStartX + (mouseX - dragStartX);
      offsetY = offsetStartY + (mouseY - dragStartY);
      clampOffset();  // stop dragging past edges
    }
  }

  void stopDrag() {
    dragging = false;
  }

  // zooms centered on the mouse cursor so the point under the cursor stays fixed during zoom
  void handleZoom(float count) {
    float zoomFactor = -count * 0.1;
    float newZoom    = zoom + zoomFactor;

    // clamp zoom between 1x (fully zoomed out) and 6x, 26/03/2026
    if (newZoom < 1.0) {
      newZoom = 1.0;
    }
    if (newZoom > 6.0) {
      newZoom = 6.0;
    }

    // adjusts offset so the pixel under the mouse cursor stays in the same screen position after zooming
    float zoomRatio = newZoom / zoom;
    offsetX = mouseX - zoomRatio * (mouseX - offsetX);
    offsetY = mouseY - zoomRatio * (mouseY - offsetY);
    zoom    = newZoom;
    clampOffset();  // stop zooming past edges
  }

  // prevents the map from being dragged or zoomed outside the window edges
  void clampOffset() {
    // left edge, offsetX cannot go above 0 (map cant slide right past left edge)
    if (offsetX > 0) {
      offsetX = 0;
    }
    // right edge, map right side cant go left of screen right edge
    if (offsetX < width - width * zoom) {
      offsetX = width - width * zoom;
    }
    // top edge, offsetY cannot go above 0
    if (offsetY > 0) {
      offsetY = 0;
    }
    // bottom edge, map bottom cant go above screen bottom edge
    if (offsetY < height - height * zoom) {
      offsetY = height - height * zoom;
    }
  }

  // converts screen mouse coordinates to map coordinates, accounting for current pan and zoom
  // used by FlightArc and AirportCoordinates so hover/click detection works correctly when zoomed in
  float mapMouseX() {
    return (mouseX - offsetX) / zoom;
  }

  float mapMouseY() {
    return (mouseY - offsetY) / zoom;
  }
}