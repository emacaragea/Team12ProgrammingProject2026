// Orla Kealy, 10:50 AM 12/03/2026
// Description: Created BarChart class and implemented basic bar chart rendering

// Orla Kealy, 16:00 PM 13/03/2026
// Description: Fixed bug where labels did not appear on screen
//              Added temporary error checking: if labels and values length mismatch, chart will be empty
//              Added unique colour to each bar

// Orla Kealy, 13:00 PM 14/03/2026
// Description: Added chart titles
//              Added axes and scale markings 
//              Implemented a hover effect over bars with tooltip

class BarChart
{
  String[] labels;
  int[] values;
  String title;
  float x, y, w, h;
  color[] barColors;
  float[] hoverScale;
  
  float animationProgress = 0;
  float animationSpeed = 0.03;

  BarChart(String title, String[] labels, int[] values, float x, float y, float w, float h, color[] barColors)
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
      this.title = title;
      
      // Initialise hover scale for each bar
      hoverScale = new float[labels.length];
      for (int i = 0; i < hoverScale.length; i++)
      {
        hoverScale[i] = 1.0;
      }

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
          this.barColors[i] = color(54, 110, 190);
        }
      }
    }

    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  void resetAnimation()
  {
    animationProgress = 0;
  }

  // Draws the bar chart
  void drawChart()
  {
    if (values.length > 0)
    {
      // Background
      fill(240);
      stroke(200);
      rect(x - 40, y - 40, w + 40, h + 80);
      
      // Animation progress
      animationProgress += animationSpeed;
      animationProgress = constrain(animationProgress, 0, 1);
        
      // Values
      int maxValue = max(values); // finds largest value to scale bars
      if (maxValue < 1)         
      {
        maxValue = 1;             // avoid division by zero
      }

      float barWidth = w / values.length;
      float actualBarWidth = barWidth * 0.7;
      float offset = (barWidth - actualBarWidth) / 2;
      
      // Draw title
      textSize(16);                     
      textAlign(CENTER);   
      fill(0);                          // title colour             
      text(title, x + w / 2, y - 10);   // draw title
      
      // Draw axes
      stroke(0);
      line(x, y + h, x + w, y + h);     // X axis
      line(x, y, x, y + h);             // Y axis
      
      // Draw ticks
      textSize(12);
      textAlign(RIGHT);
      
      for(int j = 0; j <= 5; j++)
      {
        float tickY = map(j, 0, 5, y + h, y);
        int tickValue = int(map(j, 0, 5, 0, maxValue));

        line(x - 5, tickY, x, tickY);
        fill(0);
        text(tickValue, x - 10, tickY);
      }
      
      // Tooltip variables
      String hoverLabel = null;
      int hoverValue = 0;

      // Draw bar chart
      for (int i = 0; i < values.length; i++)
      {
        // Scale bar heights relative to max value
        float targetHeight = map(values[i], 0, maxValue, 0, h);
        float barHeight = targetHeight * animationProgress;

        float barX = x + i * barWidth + offset;
        float barY = y + h - barHeight;
        
        // Detect hover
        boolean hovered = mouseX > barX && mouseX < barX + actualBarWidth && mouseY > barY && mouseY < y + h;
        color barColor = barColors[i];
        float hoverTarget;
        
        if (hovered)
        {
          barColor = color(min(red(barColor) + 40, 255), min(green(barColor) + 40, 255), min(blue(barColor) + 40, 255));  // brightens existing colour
          hoverTarget = 1.05;
        }
        else
        {
          hoverTarget = 1.0;
        }
        
        hoverScale[i] = lerp(hoverScale[i], hoverTarget, 0.1);
        float scaledWidth = actualBarWidth * hoverScale[i];
        float scaledHeight = barHeight * hoverScale[i];
        float scaledX = barX - (scaledWidth - actualBarWidth) / 2; 
        float scaledY = y + h - scaledHeight;
        
        // Draw bars
        fill(barColor);                               // bar colour
        noStroke();
        rect(scaledX, scaledY, scaledWidth, scaledHeight);  // draw bar

        // Draw labels
        fill(0);                                              // label colour
        textAlign(CENTER);
        text(labels[i], barX + actualBarWidth / 2, y + h + 15);   // draw label
        
        // Hover detection
        if (mouseX > barX && mouseX < barX + actualBarWidth &&
            mouseY > barY && mouseY < barY + barHeight)
        {
          hoverLabel = labels[i];
          hoverValue = values[i];
        }
      }
      
      // Tooltip
      if (hoverLabel != null)
      {
        fill(255);
        stroke(0);
        rect(mouseX, mouseY - 25, 80, 20, 4);
        
        fill(0);
        textAlign(CENTER, CENTER);
        text(hoverLabel + ": " + hoverValue, mouseX + 40, mouseY - 15);
      }
    }
  }
}