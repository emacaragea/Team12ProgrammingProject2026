// Ema Caragea, MapView class handles zoom and pan, 18/03/2026, 15:00

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
  }

  // converts screen mouse position to map position accounting for zoom
  float mapMouseX() {
    return (mouseX - offsetX) / zoom;
  }

  float mapMouseY() {
    return (mouseY - offsetY) / zoom;
  }
}