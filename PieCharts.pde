// Orla Kealy, 10:50 AM 12/03/2026
// Description: Created PieChart class and implemented basic pie chart rendering

// Orla Kealy, 16:00 PM 13/03/2026
// Description: Added chart labels
//              Added temporary error checking: if labels and values length mismatch, chart will be empty
//              Added unique colour to each slice

class PieChart
{
  String[] labels;
  float[] values;
  float x, y, diameter;
  color[] sliceColors;

  PieChart(String[] labels, float[] values, float x, float y, float diameter, color[] sliceColors)
  {
    // Checks data lengths - removes chart if not equal
    if (labels.length != values.length)
    {
      println("Error: labels and values must be same length");
      this.labels = new String[0];
      this.values = new float[0];
      this.sliceColors = new color[0];
    }
    else
    {
      this.labels = labels;
      this.values = values;

      // Checks if colour array is provided and has correct length
      if (sliceColors != null && sliceColors.length == labels.length)
      {
        this.sliceColors = sliceColors;
      }
      else
      {
        // Fallback: default blue for all bars
        this.sliceColors = new color[labels.length];
        for (int i = 0; i < labels.length; i++)
        {
          this.sliceColors[i] = color(200, 100, 300);
        }
      }
    }

    this.x = x;
    this.y = y;
    this.diameter = diameter;
  }

  // Draws the pie chart
  void drawChart()
  {
    if (values.length > 0)
    {
      float total = 0;

      for (int i = 0; i < values.length; i++)
      {
        total += values[i];
      }

      if (total > 0)
      {
        float startAngle = 0;

        for (int i = 0; i < values.length; i++)
        {
          // Calculate angle of slice
          float angle = map(values[i], 0, total, 0, TWO_PI);  

          // Draw the slice
          fill(sliceColors[i]);  // slice colour
          arc(x, y, diameter, diameter, startAngle, startAngle + angle, PIE);

          // Draw the labels
          float midAngle = startAngle + angle / 2;
          float labelRadius = diameter / 2 + 15;
          float labelX = x + cos(midAngle) * labelRadius;
          float labelY = y + sin(midAngle) * labelRadius;

          fill(0);  // label colour
          textAlign(CENTER, CENTER);
          text(labels[i], labelX, labelY);

          startAngle += angle;  // move to next slice
        }
      }
    }
  }
}