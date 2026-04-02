// niko charles 10:00 25/03/2026
class TextLinks{
    String label;
    float x, y, w, h;
    Airport airport;


  TextLinks(String label, float x, float y, float w, float h, Airport airport) {
    this.label = label;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.airport = airport;
  }

  TextLinks(String label, float x, float y, float h){
    this.label = label;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.airport = null;
  }

  boolean isMouseOver(float mx, float my) {
    return mx >= x && mx <= x + w && my >= y - h && my <= y + h/2;
  }

  Airport getTextLinkAirport(){
    return airport;
  }
}