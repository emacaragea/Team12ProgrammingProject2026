// Orla Kealy, 10:50 AM 12/03/2026
// Description: Created PieChart class and implemented basic pie chart rendering

class PieChart
{
  String[] labels;
  float[] values;
  float x, y, radius;

  PieChart(String[] labels, float[] values, float x, float y, float radius)
  {
    this.labels = labels;
    this.values = values;
    this.x = x;
    this.y = y;
    this.radius = radius;
  }

  void drawChart()
  {
    float total = 0;

    for(int i = 0; i < values.length; i++)
    {
      total += values[i];
    }

    float startAngle = 0;

    for (int i = 0; i < values.length; i++)
    {
      float angle = map(values[i], 0, total, 0, TWO_PI);

      fill(200, 100, 300);
      arc(x, y, radius, radius, startAngle, startAngle + angle, PIE);

      startAngle += angle;
    }
  }
}