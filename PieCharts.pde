// Orla Kealy, 10:50 AM 12/03/2026
// Description: Created PieChart class and implemented basic pie chart rendering

// Orla Kealy, 16:00 PM 13/03/2026
// Description: Added chart labels
//              Added temporary error checking: if labels and values length mismatch, chart will be empty
//              Added unique colour to each bar

// Orla Kealy, 13:00 PM 14/03/2026
// Description: Added chart title
//              Implemented a hover effect over slices with tooltip

class PieChart
{
  String[] labels;
  float[] values;
  String title;

  float x, y, diameter;
  color[] sliceColors;
  float[] explodeAmount;

  PieChart(String title, String[] labels, float[] values, float x, float y, float diameter, color[] sliceColors)
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
      this.title = title;
      explodeAmount = new float[labels.length];
      
      for (int i = 0; i < explodeAmount.length; i++)
      {
        explodeAmount[i] = 0;
      }

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
          this.sliceColors[i] = color(54, 110, 190);
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
      // Background
      fill(240);
      stroke(200);
      rect(x - diameter / 2 - 50, y - diameter / 2 - 40, diameter + 90, diameter + 80);
      // Title
      fill(0);
      textAlign(CENTER);
      textSize(16);
      text(title, x, y - diameter / 2 - 10);
      
      float total = 0;

      for (int i = 0; i < values.length; i++)
      {
        total += values[i];
      }

      if (total > 0)
      {
        float startAngle = 0;
        
        String hoverLabel = null;
        float hoverValue = 0;
        float hoverPercent = 0;

        for (int i = 0; i < values.length; i++)
        {
          // Calculate angle of slice
          float angle = map(values[i], 0, total, 0, TWO_PI);  
          float endAngle = startAngle + angle;
          float midAngle = startAngle + angle / 2;
          
          // Detect hover
          float dx = mouseX - x;
          float dy = mouseY - y;
          float dist = sqrt(dx * dx + dy * dy);
          float mouseAngle = atan2(dy, dx);
          
          if (mouseAngle < 0)
          {
            mouseAngle += TWO_PI;
          }
          
          boolean hovered = dist < diameter / 2 && mouseAngle > startAngle && mouseAngle < endAngle;
          
          // Explode offset
          float target;
          float scale;
          
          if (hovered)
          {
            target = 12;
            scale = 1.05;
          }
          else
          {
            target = 0;
            scale = 1.0;
          }
          
          explodeAmount[i] = lerp(explodeAmount[i], target, 0.15);
          float explode = explodeAmount[i];
          
          float offsetX = cos(midAngle) * explode;
          float offsetY = sin(midAngle) * explode;
          
          
          // Colour highlight
          color sliceColor = sliceColors[i];
          
          if (hovered)
          {
            sliceColor = color(min(red(sliceColor) + 40, 255), min(green(sliceColor) + 40, 255), min(blue(sliceColor) + 40, 255));
            hoverLabel = labels[i];
            hoverValue = values[i];
            hoverPercent = (values[i] / total) * 100;
          }
          
          // Draw the slice
          fill(sliceColor);  // slice colour
          stroke(255);
          arc(x + offsetX, y + offsetY, diameter * scale, diameter * scale, startAngle, endAngle, PIE);

          // Draw the labels         
          float labelRadius = diameter * 0.65;
          float labelX = x + offsetX + cos(midAngle) * labelRadius;
          float labelY = y + offsetY + sin(midAngle) * labelRadius;

          fill(0);  // label colour
          textSize(12);
          textAlign(CENTER, CENTER);
          text(labels[i], labelX, labelY);

          startAngle = endAngle;  // move to next slice
        }
        
        // Tooltip
        if (hoverLabel != null)
        {
          fill(255);
          stroke(0);
          rect(mouseX, mouseY - 25, 140, 22, 4);
          
          fill(0);
          textAlign(CENTER, CENTER);
          text(hoverLabel + ": " + hoverValue + " (" + nf(hoverPercent, 0, 1) + "%)", mouseX + 70, mouseY - 15);
        }
      }
    }
  }
}