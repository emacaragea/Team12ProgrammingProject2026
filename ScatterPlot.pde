// Orla Kealy, 10:30 AM 18/03/2026
// Description: Created PieChart class and implemented basic pie chart rendering
//              Implemented a hover effect over points with tooltip

// Orla Kealy, 22:00 PM 21/03/2026
// Description: Added animation when pie chart is created
//              Ensured clean, round numbers for x-axis and y-axis labels
//              Improved code clarity and added comments

class ScatterPlot
{
  // Data
  float[] xValues;
  float[] yValues;
  String[] labels;
  
  // Titles
  String title;
  String xLabel;
  String yLabel;
  
  // Layout
  float x, y, w, h;
  
  // Axis bounds
  float minX, maxX, minY, maxY;
  
  // Appearance
  color pointColor = color(60,120,220);
  float basePointSize = 6;
  color gridColor = color(220, 150);
  float hoverPointSize = 12;
  
  float[] pointSizes;
  float[] screenX;
  float[] screenY;
  
  // Animation
  float[] spawnScale;
  int[] spawnPhase;          // 0 = growing, 1 = shrinking, 2 = done
  boolean spawned = false;
  int[] drawOrder;
  int[] orderIndexOf;
  
  ScatterPlot(String title, String xLabel, String yLabel, float[] xValues, float[] yValues, String[] labels,
              float x, float y, float w, float h)
  {
    this.title = title;
    this.xLabel = xLabel;
    this.yLabel = yLabel;
    
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    
    // Guard: ensures matching array lengths
    if (xValues.length != yValues.length)
    {
      println("ScatterPlot error: labels and values arrays must be the same length.");
      this.xValues = new float[0];
      this.yValues = new float[0];
      this.labels  = new String[0];
      return;
    }
    
    this.xValues = xValues;
    this.yValues = yValues;
    this.labels = labels;
    
    initialisePoints();
  }
  
  // initialisePoints
  // Calculates bounds, screen positions and resets point sizes
  void initialisePoints()
  {
    calculateBounds();
    updateScreenPositions();
    
    pointSizes = new float[xValues.length];
    for (int i = 0; i < pointSizes.length; i++)
    {
      pointSizes[i] = basePointSize;
    }
    
    // Initialise spawn animation — points start at 3x size and spring back to 1.0
    spawnScale = new float[xValues.length];
    spawnPhase = new int[xValues.length];
    spawned = false;
    
    for (int i = 0; i < spawnScale.length; i++)
    {
      spawnScale[i] = 1.0;     // start normal size
      spawnPhase[i] = 0;       // start in grow phase
    }
  }
  
  // setData
  // Replaces the current dataset, recalculates data
  void setData(float[] newX, float[] newY, String[] newLabels)
  {
    // Guard: ensures matching array lengths
    if (newX.length != newY.length)
    {
      println("ScatterPlot error: labels and values arrays must be the same length.");
      return;
    }
    
    xValues = newX;
    yValues = newY;
    labels = newLabels;

    initialisePoints();
  }
  
  // setAxisLabels
  // Allows axis labels to be updated independently
  void setAxisLabels(String xLabel, String yLabel)
  {
    this.xLabel = xLabel;
    this.yLabel = yLabel;
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
  
  // calculateBounds
  // Sets axis min/max and adds 10% padding
  void calculateBounds()
  {
    // Axes start at zero
    minX = 0;
    minY = 0;

    // Snap axis ceilings to get clean round numbers for tick labels
    maxX += getMaxTick(max(xValues));
    maxY += getMaxTick(max(yValues));
  }
  
  // updateScreenPositions
  // Maps each data point
  void updateScreenPositions()
  {
    screenX = new float[xValues.length];
    screenY = new float[yValues.length];

    for (int i = 0; i < xValues.length; i++)
    {
      screenX[i] = map(xValues[i], minX, maxX, x, x + w);
      screenY[i] = map(yValues[i], minY, maxY, y + h, y);
    }
    
    // Sort point indices by screenX - stagger goes from left to right
    drawOrder = new int[xValues.length];

    for (int i = 0; i < drawOrder.length; i++)
    {
      drawOrder[i] = i;
    }

    for (int i = 0; i < drawOrder.length - 1; i++)
    {
      for (int j = i + 1; j < drawOrder.length; j++)
      {
        if (screenX[drawOrder[i]] > screenX[drawOrder[j]])
        {
          int temp = drawOrder[i];
          drawOrder[i] = drawOrder[j];
          drawOrder[j] = temp;
        }
      }
    }

    // Build reverse lookup 
    orderIndexOf = new int[xValues.length];

    for (int i = 0; i < drawOrder.length; i++)
    {
      orderIndexOf[drawOrder[i]] = i;
    }
  }
  
  // drawChart
  // Called by Charts.chartsDraw()
  // Main render method
  void drawChart()
  {
    if (xValues.length == 0)
    {
      return;
    }
    
    drawGridAndTicks();
    drawAxes();
    drawPoints();
    drawLabels();
  }
  
  // drawGridAndTicks
  // Draws vertical and horizontal grid lines, with tick marks and labels
  void drawGridAndTicks()
  {
    int gridLines = 5;

    float xStep = (maxX - minX) / gridLines;
    float yStep = (maxY - minY) / gridLines;

    for (int i = 0; i <= gridLines; i++)
    {
      // Vertical grid line and X ticks
      float valueX = minX + i * xStep;
      float px = map(valueX, minX, maxX, x, x + w);

      stroke(gridColor);
      line(px, y, px, y + h);

      stroke(0);
      line(px, y + h, px, y + h + 6);
      
      fill(0);
      textAlign(CENTER, TOP);
      textSize(11);
      text(nf(valueX, 0, 0), px, y + h + 8);  

      // Horizontal grid line and Y ticks
      float valueY = minY + i * yStep;
      float py = map(valueY, minY, maxY, y + h, y);

      stroke(gridColor);
      line(x, py, x + w, py);
      
      stroke(0);
      line(x - 6, py, x, py);
      
      fill(0);
      textAlign(RIGHT, CENTER);
      textSize(11);
      text(nf(valueY, 0, 0), x - 8, py);
    }
  }
  
  // drawAxes
  // Draws X and Y axes 
  void drawAxes()
  {
    stroke(0);
    strokeWeight(2);
    
    line(x, y + h, x + w, y + h);
    line(x, y, x, y + h);
    
    strokeWeight(1);
  }
  
  // drawPoints
  // Finds closest hovered point, then draws all points
  void drawPoints()
  {
    if (!spawned)
    {
      boolean allDone = true;

      for (int i = 0; i < xValues.length; i++)
      {
        // Stagger effect
        int orderIndex = orderIndexOf[i];
        boolean prevStarted = (orderIndex == 0) || (spawnPhase[drawOrder[orderIndex - 1]] > 0);

        if (!prevStarted) continue;

        float speedUp   = 0.08; // grow speed
        float speedDown = 0.12; // shrink speed

        // Growing: 1x - 3x
        if (spawnPhase[i] == 0) 
        {
          spawnScale[i] += speedUp;

          if (spawnScale[i] >= 3.0)
          {
            spawnScale[i] = 3.0;
            spawnPhase[i] = 1;
          }

          allDone = false;
        }
        // Shrinking 3x - 1x
        else if (spawnPhase[i] == 1)
        {
          spawnScale[i] -= speedDown;

          if (spawnScale[i] <= 1.0)
          {
            spawnScale[i] = 1.0;
            spawnPhase[i] = 2;
          }

          allDone = false;
        }
      }

      if (allDone) spawned = true;
    }
    
    int hoveredIndex  = -1;
    float closestDist = Float.MAX_VALUE;

    // First pass: find closest hovered point
    if (spawned)
    {
      for (int i = 0; i < xValues.length; i++)
      {
        float dx = mouseX - screenX[i];
        float dy = mouseY - screenY[i];
        float d  = dx * dx + dy * dy;

        if (d < sq(hoverPointSize) && d < closestDist)
        {
          closestDist  = d;
          hoveredIndex = i;
        }
      }
    }
    
    // Second pass: draw points
    for (int i = 0; i < xValues.length; i++)
    {
      float px = screenX[i];
      float py = screenY[i];

      boolean hovering = (i == hoveredIndex);
      
      // Animate point size toward hover or base target
      float targetSize = hovering ? hoverPointSize : basePointSize;
      pointSizes[i]    = lerp(pointSizes[i], targetSize, 0.2);
      
      // Multiply by spawnScale so pop-in animation affects draw size
      float drawSize = pointSizes[i] * spawnScale[i];
      
      // Brighten hovered point's colour
      color c = pointColor;
      
      if (hovering)
      {
        c = color(min(red(c) + 40, 255), min(green(c) + 40, 255), min(blue(c) + 40, 255));
      }
      
      fill(c);
      noStroke();
      ellipse(px, py, drawSize, drawSize);
    }

    // Draw tooltip once
    if (hoveredIndex != -1)
    {
      drawTooltip(hoveredIndex);
    }
  }
  
  // drawTooltip
  // Draws info box near cursor, showing point's label and values
  void drawTooltip(int index)
  {
    String tooltip =
      labels[index] +
      "\nX: " + nf(xValues[index], 0, 2) +
      "\nY: " + nf(yValues[index], 0, 2);

    float boxWidth  = 120;
    float boxHeight = 50;

    float tx = constrain(mouseX + 10, 0, width  - boxWidth);
    float ty = constrain(mouseY - 50, 0, height - boxHeight);

    fill(0);
    noStroke();
    rect(tx, ty, boxWidth, boxHeight, 4);
    
    fill(255);
    textAlign(LEFT, TOP);
    text(tooltip, tx + 5, ty + 5);
  }
  
  // drawLabels
  // Draws the chart title, X axis and Y axis label
  void drawLabels()
  {
    fill(0);
    textAlign(CENTER);
    
    // Chart title
    textSize(16);
    text(title, x + w / 2, y - 15);
    
    // X-axis label
    textSize(12);
    text(xLabel, x + w / 2, y + h + 30);
    
    // Y-axis label - rotated 90 degrees
    pushMatrix();
    translate(x - 35, y + h / 2);
    rotate(-HALF_PI);
    text(yLabel, 0, 0);
    popMatrix();
  }
}