// Orla Kealy, 10:30 AM 18/03/2026
// Description: Created PieChart class and implemented basic pie chart rendering
//              Implemented a hover effect over points with tooltip


class ScatterPlot
{
  float[] xValues;
  float[] yValues;
  String[] labels;
  
  String title;
  String xLabel;
  String yLabel;
  
  float x, y, w, h;
  float minX, maxX, minY, maxY;
  
  color pointColor = color(60,120,220);
  float basePointSize = 6;
  color gridColor = color(220, 150);
  float hoverPointSize = 12;
  
  float[] pointSizes;
  float[] screenX;
  float[] screenY;
  
  ScatterPlot(String title, String xLabel, String yLabel, float[] xValues, float[] yValues, String[] labels,
              float x, float y, float w, float h)
  {
    this.title = title;
    this.xLabel = xLabel;
    this.yLabel = yLabel;
    this.xValues = xValues;
    this.yValues = yValues;
    this.labels = labels;
    
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    
    if (xValues.length != yValues.length)
    {
      println("Error: x and y arrays values must match");
      return;
    }
    
    calculateBounds();
    updateScreenPositions();
    
    pointSizes = new float[xValues.length];
    for (int i = 0; i < pointSizes.length; i++)
    {
      pointSizes[i] = basePointSize;
    }
  }
  
  void setAxisLabels(String xLabel, String yLabel)
  {
    this.xLabel = xLabel;
    this.yLabel = yLabel;
  }
  
  void setData(float[] newX, float[] newY, String[] newLabels)
  {
    xValues = newX;
    yValues = newY;
    labels = newLabels;

    calculateBounds();
    updateScreenPositions();

    pointSizes = new float[xValues.length];
    for (int i = 0; i < pointSizes.length; i++)
    {
      pointSizes[i] = basePointSize;
    }
  }
  
  void calculateBounds()
  {
    minX = 0;
    minY = 0;
    
    maxX = max(xValues);
    maxY = max(yValues);

    float xPad = maxX * 0.1;
    float yPad = maxY * 0.1;

    maxX += xPad;
    maxY += yPad;
  }
  
  void updateScreenPositions()
  {
    screenX = new float[xValues.length];
    screenY = new float[yValues.length];

    for (int i = 0; i < xValues.length; i++)
    {
      screenX[i] = map(xValues[i], minX, maxX, x, x + w);
      screenY[i] = map(yValues[i], minY, maxY, y + h, y);
    }
  }
  
  void display()
  {
    drawGridAndTicks();
    drawAxes();
    drawPoints();
    drawLabels();
  }
  
  void drawGridAndTicks()
  {
    int gridLines = 5;

    float xStep = (maxX - minX) / gridLines;
    float yStep = (maxY - minY) / gridLines;

    stroke(gridColor);

    for (int i = 0; i <= gridLines; i++)
    {
      float valueX = minX + i * xStep;
      float px = map(valueX, minX, maxX, x, x + w);

      line(px, y, px, y + h);

      stroke(0);
      line(px, y + h, px, y + h + 6);
      
      fill(0);
      textAlign(CENTER, TOP);
      text(nf(valueX, 0, 0), px, y + h + 8);
      
      stroke(gridColor);       
    }

    for (int i = 0; i <= gridLines; i++)
    {
      float valueY = minY + i * yStep;
      float py = map(valueY, minY, maxY, y + h, y);

      line(x, py, x + w, py);
      
      stroke(0);
      line(x - 6, py, x, py);
      
      fill(0);
      textAlign(RIGHT, CENTER);
      text(nf(valueY, 0, 0), x - 8, py);

      stroke(gridColor);
    }
  }
  
  void drawAxes()
  {
    stroke(0);
    strokeWeight(2);
    
    line(x, y + h, x + w, y + h);
    line(x, y, x, y + h);
    
    strokeWeight(1);
  }
  
  void drawPoints()
  {
    int hoveredIndex = -1;
    float closestDist = Float.MAX_VALUE;

    // Find closest hovered point
    for (int i = 0; i < xValues.length; i++)
    {
      float dx = mouseX - screenX[i];
      float dy = mouseY - screenY[i];
      float d = dx*dx + dy*dy;

      if (d < sq(hoverPointSize) && d < closestDist)
      {
        closestDist = d;
        hoveredIndex = i;
      }
    }

    // Draw points
    for (int i = 0; i < xValues.length; i++)
    {
      float px = screenX[i];
      float py = screenY[i];

      boolean hovering = (i == hoveredIndex);
      
      float targetSize = hovering ? hoverPointSize : basePointSize;
      pointSizes[i] = lerp(pointSizes[i], targetSize, 0.2);
      
      color c = pointColor;
      
      if (hovering)
      {
        c = color(min(red(c) + 40, 255), min(green(c) + 40, 255), min(blue(c) + 40, 255));
      }
      
      fill(c);
      noStroke();
      ellipse(px, py, pointSizes[i], pointSizes[i]);
    }

    // Draw tooltip - ensures drawn only once
    if (hoveredIndex != -1)
    {
      drawTooltip(hoveredIndex);
    }
  }
  
  void drawTooltip(int index)
  {
    String tooltip =
      labels[index] +
      "\nX: " + nf(xValues[index], 0, 2) +
      "\nY: " + nf(yValues[index], 0, 2);

    float boxWidth = 120;
    float boxHeight = 50;

    float tx = constrain(mouseX + 10, 0, width - boxWidth);
    float ty = constrain(mouseY - 50, 0, height - boxHeight);

    fill(0);
    noStroke();
    rect(tx, ty, boxWidth, boxHeight, 4);
    
    fill(255);
    textAlign(LEFT, TOP);
    text(tooltip, tx + 5, ty + 5);
  }
  
  void drawLabels()
  {
    fill(0);
    
    textAlign(CENTER);
    textSize(16);
    text(title, x + w / 2, y - 15);
    
    textSize(12);
    text(xLabel, x + w / 2, y + h + 30);
    
    pushMatrix();
    translate(x - 35, y + h / 2);
    rotate(-HALF_PI);
    text(yLabel, 0, 0);
    popMatrix();
  }
}