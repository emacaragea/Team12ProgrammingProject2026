// Orla Kealy, 10:50 AM 12/03/2026
// Description: Created BarChart class and implemented basic bar chart rendering

// Orla Kealy, 16:00 PM 13/03/2026
// Description: Fixed bug where labels did not appear on screen
//              Added temporary error checking: if labels and values length mismatch, chart will be empty
//              Added unique colour to each bar

class BarChart
{
  String[] labels;
  int[] values;
  float x, y, w, h;
  color[] barColors;

  BarChart(String[] labels, int[] values, float x, float y, float w, float h, color[] barColors)
  {
    // Checks data lengths - removes chart if not equal
    if (labels.length != values.length)
    {
      println("Error: labels and values must be same length.");

      this.labels = new String[0];
      this.values = new int[0];
      this.barColors = new color[0];
    }
    else
    {
      this.labels = labels;
      this.values = values;

      // Checks if colour array is provided and has correct length
      if (barColors != null && barColors.length == labels.length)
      {
        this.barColors = barColors;
      }
      else
      {
        // Fallback: default blue for all bars
        this.barColors = new color[labels.length];
        for (int i = 0; i < labels.length; i++)
        {
          this.barColors[i] = color(100, 150, 255);
        }
      }
    }

    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  // Draws the bar chart
  void drawChart()
  {
    if (values.length > 0)
    {
      int maxValue = max(values); // finds largest value to scale bars
      if (maxValue < 1)         
      {
        maxValue = 1;             // avoid division by zero
      }

      float barWidth = w / values.length;

      textAlign(CENTER);
      textSize(12);

      for (int i = 0; i < values.length; i++)
      {
        // Scale bar heights relative to max value
        float barHeight = map(values[i], 0, maxValue, 0, h);

        float barX = x + i * barWidth;
        float barY = y + h - barHeight;

        fill(barColors[i]);                           // bar colour
        rect(barX, barY, barWidth * 0.8, barHeight);  // draw bar

        fill(0);                                              // label colour
        text(labels[i], barX + barWidth * 0.4, y + h + 15);   // draw label
      }
    }
  }
}


