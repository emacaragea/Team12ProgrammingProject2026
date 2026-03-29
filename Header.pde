//Ema Caragea, created a rough header class to be used across screens, 24/03/2026, 20:30

class Header {
  final int HEIGHT = 45;
  final color BAR_COLOR = color(82, 156, 214);
  final color STROKE_COLOR = color(0, 120, 200);

  void draw() {
    noStroke();
    fill(BAR_COLOR);
    rect(0, 0, width, HEIGHT);

    stroke(STROKE_COLOR);
    strokeWeight(1);
    line(0, HEIGHT, width, HEIGHT);
  }
}