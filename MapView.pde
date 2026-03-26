// Ema Caragea, added edge clamping to MapView, 21/3/2026
//Ema Caragea, made edges of map non-draggable and non-zoomable, 26/3/2026, 17:00

class MapView {
  float zoom;
  float offsetX;
  float offsetY;
  float dragStartX;
  float dragStartY;
  float offsetStartX;
  float offsetStartY;
  boolean dragging;

  MapView() {
    zoom     = 1.0;
    offsetX  = 0;
    offsetY  = 0;
    dragging = false;
  }

  void begin() {
    pushMatrix();
    translate(offsetX, offsetY);
    scale(zoom);
  }

  void end() {
    popMatrix();
  }

  void startDrag() {
    dragging     = true;
    dragStartX   = mouseX;
    dragStartY   = mouseY;
    offsetStartX = offsetX;
    offsetStartY = offsetY;
  }

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

  void handleZoom(float count) {
    float zoomFactor = -count * 0.1;
    float newZoom    = zoom + zoomFactor;

    if (newZoom < 1.0) {
      newZoom = 1.0;
    }
    if (newZoom > 6.0) {
      newZoom = 6.0;
    }

    float zoomRatio = newZoom / zoom;
    offsetX = mouseX - zoomRatio * (mouseX - offsetX);
    offsetY = mouseY - zoomRatio * (mouseY - offsetY);
    zoom    = newZoom;
    clampOffset();  // stop zooming past edges
  }

  // prevents the map from being dragged or zoomed outside the window
  void clampOffset() {
    // left edge — offsetX cannot go above 0 (map cant slide right past left edge)
    if (offsetX > 0) {
      offsetX = 0;
    }
    // right edge — map right side cant go left of screen right edge
    if (offsetX < width - width * zoom) {
      offsetX = width - width * zoom;
    }
    // top edge — offsetY cannot go above 0
    if (offsetY > 0) {
      offsetY = 0;
    }
    // bottom edge — map bottom cant go above screen bottom edge
    if (offsetY < height - height * zoom) {
      offsetY = height - height * zoom;
    }
  }

  float mapMouseX() {
    return (mouseX - offsetX) / zoom;
  }

  float mapMouseY() {
    return (mouseY - offsetY) / zoom;
  }
}