// Orla Kealy, 10:50 AM 12/03/2026
// Description: Created BarChart class and implemented basic bar chart rendering

class BarChart
{
  String[] labels;
  int[] values;

  float x, y, w, h;

  BarChart(String[] labels, int[] values, float x, float y, float w, float h)
  {
    this.labels = labels;
    this.values = values;
    this.x = x;
    this.y = y;
    this.h = h;
    this.w = w;
  }

  void drawChart()
  {
    int maxValue = max(values);
    float barWidth = w / values.length;

    textAlign(CENTER);

    for (int i = 0; i < values.length; i++)
    {
      float barHeight = map(values[i], 0, maxValue, 0, h);

      fill(100, 150, 255);
      rect(x + i * barWidth, y + h - barHeight, barWidth - 5, barHeight);

      fill(0);
      text(labels[i], x + i * barWidth, y + h + 15);
    }
  }
}


