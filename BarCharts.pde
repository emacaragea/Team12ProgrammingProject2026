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

// Orla Kealy 18:00 PM 15/03/2026
// Description: Added data filter option to charts
//              Improved safe handling of changing data size
//              Fixed bug where labels overlapped

// Orla Kealy 21:00 PM 21/03/2026
// Description: Added sort buttons to charts (ascending/descending)
//              Improved code clarity and added comments

class BarChart
{
  // Data
  String[] labels;
  int[] values;
  String title;
  color[] barColors;
  
  // Original order - used to restore after sorting
  String[] originalLabels;
  int[] originalValues;
  color[] originalColors;
  
  // Layout
  float x, y, w, h;
  
  // Hover
  float[] hoverScale;
  
  // Sort buttons - 0 = original, 1 = descending, 2 = ascending
  int sortMode = 0;              
  float sortButtonX, sortButtonY;
  float sortButtonW, sortButtonH;
  float sortButtonGap;
  
  // Animation
  float animationProgress = 0;
  float animationSpeed = 0.03;
  

  BarChart(String title, String[] labels, int[] values, float x, float y, float w, float h, color[] barColors)
  {
    this.title = title;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    
    // Sort button location - top-left area of chart
    sortButtonX = x - 40;
    sortButtonY = y - 40;
    sortButtonH = constrain(h * 0.06, 18, 32);
    sortButtonW = sortButtonH;
    sortButtonGap = constrain(sortButtonW * 0.08, 1, 3);
    
    setData(labels, values, barColors);
  }
  
  // setData
  // Called on construction and when the filter changes - resets sort state and animation
  void setData(String[] labels, int[] values, color[] barColors)
  {
    // Guard: ensures matching array lengths
    if (labels.length != values.length)
    {
      println("BarChart error: labels and values arrays must be the same length.");
      this.labels = new String[0];
      this.values = new int[0];
      this.barColors = new color[0];
      return;
    }
    
    // If nothing changed, don't reset
    if (!dataChanged(labels, values))
    {
      return;
    }
    
    // Remember active sort
    int previousSortMode = sortMode;
    
    // Initialise new data
    this.labels = labels;
    this.values = values;
    
    // Initialise hover scales
    hoverScale = new float[labels.length];
    for (int i = 0; i < hoverScale.length; i++)
    {
      hoverScale[i] = 1.0;
    }
    
    // Initialise colours 
    // Fallback: Default blue palette, if array lengths do not match
    if (barColors != null && barColors.length == labels.length)
    {
      this.barColors = barColors;
    }
    else
    {
      this.barColors = new color[labels.length];
      for (int i = 0; i < labels.length; i++)
      {
        this.barColors[i] = color(54, 110, 190);
      }
    }
    
    // Clone original order - for sorting
    originalLabels = labels.clone();
    originalValues = values.clone();
    originalColors = this.barColors.clone();
    
    // Reset sort mode and animation
    sortMode = 0;
    animationProgress = 0;
    
    // Re-apply previous sort to new data
    sortMode = previousSortMode;
    if (sortMode == 1)
    {
      sortData(true);
    }
    else if (sortMode == 2)
    {
      sortData(false);
    }
  }
  
  // dataChanged
  // Returns true if incoming arrays differ from currently displayed data
  boolean dataChanged(String[] newLabels, int[] newValues)
  {
    // If labels are null or length differs, data has definitely changed —
    // return immediately before the loop tries to index this.labels
    if (this.labels == null || this.labels.length != newLabels.length)
    {
      return true;
    }  

    for (int i = 0; i < newLabels.length; i++)
    {
      if (!newLabels[i].equals(this.labels[i]) || newValues[i] != this.values[i])
      {
        return true;
      }
    }

    return false;
  }
  
  // sortData
  // Sorts data according to mode - keeping labels, values, colours and hoverScales in sync
  void sortData(boolean descending)
  {
    for (int i = 0; i < values.length - 1; i++)
    {
      for (int j = i + 1; j < values.length; j++)
      {
        boolean shouldSwap = descending ? (values[j] > values[i]) : (values[j] < values[i]);
        
        if (shouldSwap)
        {
          // Swap values
          int tempValue = values[i];
          values[i] = values[j];
          values[j] = tempValue;
        
          // Swap labels
          String tempLabel = labels[i];
          labels[i] = labels[j];
          labels[j] = tempLabel;
          
          // Swap colours
          color tempColor = barColors[i];
          barColors[i] = barColors[j];
          barColors[j] = tempColor;
          
          // Swap hoverScale
          float tempScale = hoverScale[i];
          hoverScale[i] = hoverScale[j];
          hoverScale[j] = tempScale;
        }
      }
    }
  }
  
  // restoreOriginal
  // Puts data back into the order it was in when setData was last called
  void restoreOriginal()
  {
    labels = originalLabels.clone();
    values = originalValues.clone();
    barColors = originalColors.clone();
    
    // Reset hover scales
    hoverScale = new float[labels.length];
    
    for (int i = 0; i < hoverScale.length; i++)
    {
      hoverScale[i] = 1.0;
    }
  }
  
  // handleMousePressed
  // Called by Charts.mousePressed()
  // Cycles the sort mode and applies the corresponding sort, then restarts animation
  void handleMousePressed()
  {
    // Check each of the three mode buttons individually
    for (int mode = 0; mode < 3; mode++)
    {
      float btnX = sortButtonX + mode * (sortButtonW + sortButtonGap);

      if (mouseX > btnX && mouseX < btnX + sortButtonW &&
        mouseY > sortButtonY && mouseY < sortButtonY + sortButtonH)
      {
        sortMode = mode;

        switch (sortMode)
        {
          case 0: restoreOriginal(); break;   // original order
          case 1: sortData(true);    break;   // descending
          case 2: sortData(false);   break;   // ascending
        }

        // Restart animation
        animationProgress = 0;
      }
    }
  }
  
  // getMaxTick
  // Returns round clean numbers for the Y axis (e.g 1000, 1500, 2000)
  float getMaxTick(float maxValue)
  {
    float exponent = floor(log(maxValue) / log(10));
    float magnitude = pow(10, exponent);
    float fraction = maxValue / magnitude;
    
    // Chooses smallest 'nice' multiplier
    float maxTick;
    if (fraction <= 1)
    {
      maxTick = 1;
    }
    else if (fraction <= 1.5)
    {
      maxTick = 1.5;
    }
    else if (fraction <= 2)
    {
      maxTick = 2;
    }
    else if (fraction <= 3)
    {
      maxTick = 3;
    }
    else if (fraction <= 5)
    {
      maxTick = 5;
    }
    else
    {
      maxTick = 10;
    }
    
    return maxTick * magnitude;
  }

  // drawChart
  // Called by Charts.chartsDraw()
  // Main render method
  void drawChart()
  {
      //Jesse Margarites, 12PM, 24/03, Fixing aesthetics
      pushStyle();
    if (values.length == 0)
    {
      return;
    }
    
    // Background 
    fill(BACKGROUND_COLOR);
    stroke(200);
    rect(x - 60, y - 70, w + 120, h + 100);
      
    // Grid lines
    fill(169,169,169);
    stroke(220);
    for (int j = 0; j <= 5; j++)
    {
      float tickY = map(j, 0, 5, y + h, y);
      line(x, tickY, x + w, tickY);
    }
      
    // Animation progress
    animationProgress += animationSpeed;
    animationProgress = constrain(animationProgress, 0, 1);
      
    // Y-axis scale
    float rawMax = max(values); // finds largest value to scale bars
    if (rawMax < 1)         
    {
      rawMax = 1;               // avoid division by zero
    }
    float maxTick = getMaxTick(rawMax);

    // Bar geometry
    float barWidth = w / values.length;
    float actualBarWidth = barWidth * 0.7;            // 30% gap between bars
    float offset = (barWidth - actualBarWidth) / 2;
      
    // Draw title
    textSize(16);                     
    textAlign(CENTER);   
    fill(255, 255, 255);                          // title colour             
    text(title, x + w / 2, y - 10);   // draw title
      
    // Draw axes
   // stroke(0);

    line(x, y + h, x + w, y + h);     // X axis
    fill(255, 255, 255); 
    line(x, y, x, y + h);             // Y axis
    fill(255, 255, 255); 
      
    // Draw ticks
    textSize(12);
    textAlign(RIGHT);
      
    int numTicks = 5;
    float tickStep = maxTick / numTicks;
      
    for(int j = 0; j <= numTicks; j++)
    {
      float tickValue = j * tickStep;
      float tickY = map(tickValue, 0, maxTick, y + h, y);

      line(x - 5, tickY, x, tickY);
      fill(255, 255, 255);
      text(nfc(tickValue, 0), x - 10, tickY);
    }
      
    // Draw sort buttons
    String[] buttonIcons   = { "•", "↓", "↑" };

    for (int mode = 0; mode < 3; mode++)
    {
      float btnX = sortButtonX + mode * (sortButtonW + sortButtonGap);

      boolean isActive  = (sortMode == mode);
      boolean isHovered = (mouseX > btnX && mouseX < btnX + sortButtonW &&
                           mouseY > sortButtonY && mouseY < sortButtonY + sortButtonH);

      // Active button: dark fill. Hovered: light grey. Default: white
      if (isActive)
      {
        fill(60);
        stroke(60);
      }
      else if (isHovered)
      {
        fill(220);
        stroke(180);
      }
      else
      {
        fill(245);
        stroke(200);
      }

      // Rounded square button
      if (mode == 0)
      {
        rect(btnX, sortButtonY, sortButtonW, sortButtonH, 6, 0, 0, 6);
      }
      else if (mode == 1)
      {
        rect(btnX, sortButtonY, sortButtonW, sortButtonH, 0, 0, 0, 0);
      }
      else
      {
        rect(btnX, sortButtonY, sortButtonW, sortButtonH, 0, 6, 6, 0);
      }

      // Icon: white on dark when active, dark on light otherwise
      fill(isActive ? 255 : 80);
      textAlign(CENTER, CENTER);
      textSize(14);
      text(buttonIcons[mode], btnX + sortButtonW / 2, sortButtonY + sortButtonH / 2);
    }
      
    // Tooltip variables
    String hoverLabel = null;
    int hoverValue = 0;

    // Draw bar chart
    for (int i = 0; i < values.length; i++)
    {
      // Scale bar heights relative to max value
      float targetHeight = map(values[i], 0, maxTick, 0, h);
      float barHeight = targetHeight * animationProgress;

      float barX = x + i * barWidth + offset;
      float barY = y + h - barHeight;
        
      // Hover detection and highlight
      boolean hovered = (mouseX > barX && mouseX < barX + actualBarWidth && mouseY > barY && mouseY < y + h);
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
        
      // Animate bar when hovered
      hoverScale[i] = lerp(hoverScale[i], hoverTarget, 0.1);
      float scaledWidth = actualBarWidth * hoverScale[i];
      float scaledHeight = barHeight * hoverScale[i];
      float scaledX = barX - (scaledWidth - actualBarWidth) / 2;
      float scaledY = y + h - scaledHeight;
        
      // Draw bars
      fill(barColor);                               // bar colour
      noStroke();
      rect(scaledX, scaledY, scaledWidth, scaledHeight);  // draw bar
        
      // Hover detection for tooltip info
      if (mouseX > scaledX && mouseX < scaledX + scaledWidth &&
                mouseY > scaledY && mouseY < scaledY + scaledHeight)
      {
        hoverLabel = labels[i];
        hoverValue = values[i];
      }
    }
      
    // Draw labels
    fill(255, 255, 255);
    textAlign(CENTER);
    textSize(11);

    int labelStep = max(1, labels.length / 15);  // aim for ~15 visible labels
    
    for (int j = 0; j < labels.length; j++)
    {
      if (j % labelStep == 0)
      {
        float labelX = x + j * barWidth + barWidth / 2;
   
        pushMatrix();
        translate(labelX, y + h + 15);
        rotate(-PI/4);   // rotate slightly to avoid overlap
        //text(labels[j], 0, 0);
        popMatrix();
      }
    }
      
    // Tooltip
    if (hoverLabel != null)
    {
      fill(255);
      stroke(0);
      //rect(mouseX, mouseY - 25, 80, 20, 4);
      rect(mouseX, mouseY - 25, 200, 20, 4);
        
      fill(0);
      textAlign(CENTER, CENTER);
      text(hoverLabel + ": " + hoverValue, mouseX + 100, mouseY - 15);
    }
    popStyle();
  }
}