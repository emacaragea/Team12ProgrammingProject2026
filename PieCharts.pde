// Orla Kealy, 10:50 AM 12/03/2026
// Description: Created PieChart class and implemented basic pie chart rendering

// Orla Kealy, 16:00 PM 13/03/2026
// Description: Added chart labels
//              Added temporary error checking: if labels and values length mismatch, chart will be empty
//              Added unique colour to each bar

// Orla Kealy, 13:00 PM 14/03/2026
// Description: Added chart title
//              Implemented a hover effect over slices with tooltip

// Orla Kealy 22:00 PM 21/03/2026
// Description: Added animation when pie chart is created
//              Improved code clarity and added comments

class PieChart
{
  // Data
  String[] labels;
  float[] values;
  String title;
  color[] sliceColors;

  // Layout
  float x, y, diameter;
  
  // Animation
  float[] explodeAmount;
  float animationProgress = 0;
  float animationSpeed = 0.03;

  PieChart(String title, String[] labels, float[] values, float x, float y, float diameter, color[] sliceColors)
  {
    this.x = x;
    this.y = y;
    this.diameter = diameter;
    this.title = title;
    
    // Guard: ensures matching array lengths
    if (labels.length != values.length)
    {
      println("PieChart error: labels and values arrays must be the same length.");
      this.labels = new String[0];
      this.values = new float[0];
      this.sliceColors = new color[0];
      return;
    }
    
    // Initialise data
    this.labels = labels;
    this.values = values;
    explodeAmount = new float[labels.length];

    // Initialise colours 
    // Fallback: Default blue palette, if array lengths do not match
    if (sliceColors != null && sliceColors.length == labels.length)
    {
      this.sliceColors = sliceColors;
    }
    else
    {
      this.sliceColors = new color[labels.length];
      for (int i = 0; i < labels.length; i++)
      {
        this.sliceColors[i] = color(54, 110, 190);
      }
    }
    
    // Reset animation
    animationProgress = 0;
  }

  // drawChart
  // Called by Charts.chartsDraw()
  // Main render method
  void drawChart()
  {
    if (values.length == 0)
    {
      return;
    }
    
    // Background
    fill(20, 28, 38);
    stroke(200);
    rect(x - diameter / 2 - 50, y - diameter / 2 - 40, diameter + 90, diameter + 80);
      
    // Title
    fill(255);
    textAlign(CENTER);
    textSize(16);
    text(title, x, y - diameter + 40);
      
    float total = 0;
    for (int i = 0; i < values.length; i++)
    {
      total += values[i];
    }

    // If all values are zero, exit early
    if (total <= 0)
    {
      return;
    }
    
    // Advance animation
    animationProgress = constrain(animationProgress + animationSpeed, 0, 1);
    
    // Slices
    String hoverLabel   = null;
    float  hoverValue   = 0;
    float  hoverPercent = 0;

    float startAngle = 0;

    for (int i = 0; i < values.length; i++)
    {
      float fullAngle = map(values[i], 0, total, 0, TWO_PI);
      float angle     = fullAngle * animationProgress;
      float endAngle  = startAngle + angle;
      float midAngle  = startAngle + angle / 2;

      // Hover detection - only detect once animation has completed
      boolean hovered = false;

      if (animationProgress >= 1)
      {
        float dx         = mouseX - x;
        float dy         = mouseY - y;
        float mouseDist  = sqrt(dx * dx + dy * dy);
        float mouseAngle = atan2(dy, dx);

        if (mouseAngle < 0) 
        {
          mouseAngle += TWO_PI;
        }

        hovered = mouseDist  < diameter / 2 &&
                  mouseAngle > startAngle    &&
                  mouseAngle < endAngle;
      }

      // Explode animation
      explodeAmount[i] = lerp(explodeAmount[i], hovered ? 12 : 0, 0.15);

      float offsetX = cos(midAngle) * explodeAmount[i];
      float offsetY = sin(midAngle) * explodeAmount[i];

      // Colour highlight
      color sliceColor = sliceColors[i];

      if (hovered)
      {
        sliceColor = color(min(red(sliceColor)   + 40, 255), min(green(sliceColor) + 40, 255), min(blue(sliceColor)  + 40, 255));

        hoverLabel   = labels[i];
        hoverValue   = values[i];
        hoverPercent = (values[i] / total) * 100;
      }

      // Draw slice
      fill(sliceColor);
      stroke(20, 28, 38);
      arc(x + offsetX, y + offsetY,
          diameter, diameter,
          startAngle, endAngle, PIE);

      // Draw label - only once animation has completed
      if (animationProgress >= 1)
      {
        float labelX = x + offsetX + cos(midAngle) * diameter * 0.65;
        float labelY = y + offsetY + sin(midAngle) * diameter * 0.65;

        fill(255);
        textSize(12);
        textAlign(CENTER, CENTER);
        text(labels[i], labelX, labelY);
      }

      startAngle = endAngle;
    }

    // Tooltip
    if (hoverLabel != null)
    {
      fill(255);
      stroke(0);
      rect(mouseX, mouseY - 25, 140, 22, 4);

      fill(0);
      textAlign(CENTER, CENTER);
      text(hoverLabel + ": " + hoverValue + " (" + nf(hoverPercent, 0, 1) + "%)",
           mouseX + 70, mouseY - 15);
    }
  }
}