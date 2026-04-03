// Orla Kealy, 12:P0 AM 21/03/2026
// Description: Created StateHeatMap class and implemented basic heat map rendering
//              Implemented a hover effect over points with tooltip

// Orla Kealy, 21:00 PM 24/03/2026
// Description: Added a legend with airport flight data
//              Implemented resource path to state images - fallback if an error occurs

// Orla Kealy, 10:00 AM 30/03/2026
// Description: Updated dot visuals - implemented radar-like dots
//              Added an intro animation when map is first initialised

// Orla Kealy, 21:00PM 01/04/2026
// Description: Update coordinate data

class StateHeatMap {
  PImage stateImg;
  String stateCode;
  float minLon, maxLon, minLat, maxLat;
  
  // Dot visuals
  final float BASE_RADIUS = 6;
  final float MAX_RADIUS_SCALE = 18;

  // Tooltip layout
  final float HOVER_BOX_WIDTH = 130;
  final float HOVER_BOX_HEIGHT = 45;
  
  // Tooltip variables
  String hoverAirport = null;
  int hoverCount = 0;
  color hoverColor;
  float hoverX = 0;
  float hoverY = 0;
  int hoveredIndex = -1;
  
  // Animation variables
  float[] currentSizes;
  float[] hoverScales;   
  float[] coreSizes;     
  boolean introPlaying = true;
  int introStartTime;
  float[] introProgress;
  
  StateHeatMap(String stateCode, PImage stateImg)
  {
    this.stateCode = stateCode;
    this.stateImg = stateImg;
    
    float[] bounds = stateBoundingBox(stateCode);
    
    if (bounds != null)
    {
      maxLat = bounds[0];
      minLon = bounds[1];
      minLat = bounds[2];
      maxLon = bounds[3];
    }
  }
  
  // drawStateHeatMap
  // Renders the state heat map - prepares data, sets animations and drawing
  void drawStateHeatMap(float x, float y, String[] airports, int[] flightCounts) // e.g {"LAX", "SFO", "SAN"}
  {
    // Error check - ensure map doesn't crash if array lengths differ
    int safeLength = min(airports.length, flightCounts.length);
    int[] safeCounts = subset(flightCounts, 0, safeLength);
    
    // Compute thresholds for colour scaling
    float[] thresholds = getPercentileThresholds(safeCounts);
    int maxCount = getMaxCount(safeCounts);
    
    // Initialise animation array
    initialiseAnimation(safeLength);
    
    // Draw base map
    image(stateImg, x, y);
    
    // Draw animated dots relative to map position
    pushMatrix();
    translate(x, y);
    drawDots(airports, flightCounts, thresholds, maxCount, x, y);
    popMatrix();
    
    // Draw legend and tooltip
    drawLegend(x + stateImg.width + 20, y + 20, 120, thresholds);
    drawTooltip();
  }
  
  // initialiseAnimation
  // Resets animation arrays when dataset size changes, restarts intro animation
  void initialiseAnimation(int safeLength)
  {
    // Initialise animation array
    if (currentSizes == null || currentSizes.length != safeLength)
    {
      currentSizes = new float[safeLength];
      hoverScales = new float[safeLength];
      coreSizes = new float[safeLength];
      introProgress = new float[safeLength];
      
      // Restart intro animation
      introStartTime = millis();
      introPlaying = true;
      
      // Reset all animation values
      for (int i = 0; i < currentSizes.length; i++)
      {
        currentSizes[i] = 0;
        hoverScales[i] = 1.0;
        coreSizes[i] = 1.0;
        introProgress[i] = 0;
      }
    }
  }
  
  // drawDots
  // Handles rendering - position mapping, intro animation, hover interaction
  void drawDots(String[] airports, int[] counts, float[] thresholds, int maxCount, float x, float y)
  { 
    // Reset hover state
    hoveredIndex = -1;
    hoverAirport = null;
    hoverCount = 0;
    
    // Error check - ensure map doesn't crash if array lengths differ
    int safeLength = min(airports.length, counts.length);

    // Tracks intro animation completion
    boolean allDotsFinishedAnimating = true;
    
    // Detect hover
    for (int i = 0; i < safeLength; i++)
    {
      float[] latLon = airportLatLon(airports[i]);
      if (latLon == null) continue;  // Skip invalid locations

      float IMG_LEFT = 0;
      float IMG_TOP = 0;
      float IMG_RIGHT = stateImg.width;
      float IMG_BOTTOM = stateImg.height;

      // Convert geographic coordinates to screen space
      float pixelX = map(latLon[1], minLon, maxLon, IMG_LEFT, IMG_RIGHT);
      float pixelY = map(latLon[0], maxLat, minLat, IMG_TOP, IMG_BOTTOM);

      color dotColor = getPercentileColor(counts[i], thresholds);
      
      float targetSize = counts[i] / (float) maxCount;
      
      // Intro animation
      float delayPerDot = i * 80;
      float animationDuration = 600;

      float elapsed = millis() - introStartTime - delayPerDot;
      float progress = constrain(elapsed / animationDuration, 0, 1);
      
      introProgress[i] = progress;

      // Track if animation is ongoing
      if (progress < 1)
      {
        allDotsFinishedAnimating = false;
      }

      // Apply overshoot easing
      float overshoot = 1.4;
      float easedScale = 1 + (overshoot - 1) * sin(progress * PI);
      
      if (introPlaying)
      {
        currentSizes[i] = targetSize * easedScale;
      }
      else
      {
        currentSizes[i] = lerp(currentSizes[i], targetSize, 0.08f);
      }
         
      float radius = BASE_RADIUS + MAX_RADIUS_SCALE * pow(currentSizes[i], 0.7f);
      

      // Hover detection 
      if (dist(mouseX - x, mouseY - y, pixelX, pixelY) < radius)
      {
        hoveredIndex = i;
        hoverAirport = airports[i];
        hoverCount = counts[i];
        hoverColor = dotColor;
      }

      // Smooth hover scale — lerps to 1.35 when hovered, back to 1.0 otherwise
      float targetHover = (i == hoveredIndex) ? 1.35f : 1.0f;
      hoverScales[i] = lerp(hoverScales[i], targetHover, 0.10f);

      // Smooth core grow
      float targetCore = (i == hoveredIndex) ? 1.5f : 1.0f;
      coreSizes[i] = lerp(coreSizes[i], targetCore, 0.10f);

      drawRadar(pixelX, pixelY, dotColor, currentSizes[i], hoverScales[i], coreSizes[i], introProgress[i]);
    }

    // End intro animation once all dots are finished
    if (introPlaying && allDotsFinishedAnimating)
    {
      introPlaying = false;
    }
    
    // Store tooltip position
    if (hoveredIndex != -1)
    {
      hoverX = mouseX;
      hoverY = mouseY;
    }
  }

  // drawRadar
  // Renders a single airport marker using radar-style visual
  void drawRadar(float centerX, float centerY, color baseColor, float size, float hoverScale, float coreScale, float introFade)
  {
    float baseRadius = BASE_RADIUS + MAX_RADIUS_SCALE * pow(size, 0.7f);

    // Determine number of rings 
    int numRings;
    if (size < 0.2f)
    {
      numRings = 1;
    }  
    else if (size < 0.45f) 
    {
      numRings = 2;
    }
    else if (size < 0.75f) 
    {
      numRings = 3;
    }
    else 
    {
      numRings = 4;
    }              

    // Ring spread
    float spread = baseRadius * (0.6 + 0.7 * size) * hoverScale;

    // Core radius
    float coreRadius = BASE_RADIUS * (0.9 + size * 0.6f) * coreScale;
    
    // Fade in during intro
    float alphaMultiplier = introPlaying ? introFade : 1.0;

    // Draw rings
    for (int ringIndex = 1; ringIndex <= numRings; ringIndex++)
    {
      float ringPosition = ringIndex / (float) numRings;

      float ringRadius = coreRadius + spread * pow(ringPosition, 1.3f);
      float ringAlpha = lerp(120, 15, ringPosition) * alphaMultiplier;
      float strokeWidth = lerp(5.5f, 2.5f, ringPosition);

      strokeWeight(strokeWidth);
      stroke(red(baseColor), green(baseColor), blue(baseColor), ringAlpha);
      noFill();
      ellipse(centerX, centerY, ringRadius * 2, ringRadius * 2);
    }

    // Reset stroke
    noStroke();

    // Core
    fill(red(baseColor), green(baseColor), blue(baseColor), 230 * alphaMultiplier);
    ellipse(centerX, centerY, coreRadius * 2, coreRadius * 2);

    // Subtle highlight
    fill(255, 255, 255, 70 * alphaMultiplier);
    ellipse(centerX, centerY, coreRadius * 0.6f, coreRadius * 0.6f);
  }
  
  // drawTooltip
  // Displays information about currently hovered airport
  void drawTooltip()
  {
    if (hoverAirport == null)
    {
      return;
    }

    pushStyle();
    
    // Position
    float boxX = min(mouseX + 10, width - HOVER_BOX_WIDTH);
    float boxY = min(mouseY + 10, height - HOVER_BOX_HEIGHT);
        
    // Background
    fill(0, 180);
    noStroke();
    rect(boxX, boxY, HOVER_BOX_WIDTH, HOVER_BOX_HEIGHT, 6);
        
    // Accent bar
    fill(hoverColor);
    rect(boxX, boxY, 5, 45, 6, 0, 0, 6);
        
    // Text
    fill(255, 255, 255);
    textAlign(LEFT, TOP);
        
    // Airport 
    fill(255, 255, 255);
    textSize(13);
    text(hoverAirport, boxX + 10, boxY + 6);
        
    // Flight count
    fill(255, 255, 255);
    textSize(12);
    text("Flights: " + hoverCount, boxX + 10, boxY + 24);

    popStyle();
  }
  
  // drawLegend
  // Renders vertical colour legend showing percentile bands and value ranges
  void drawLegend(float x, float y, float h, float[] thresholds)
  {
    strokeWeight(1);
    
    int bandCount = 5;
    float bandHeight = h / bandCount;
    
    color[] colors = {color(0, 0, 255), color(0, 200, 0), color(255, 220, 0), color(255, 140, 0), color(255, 0, 0)};
    
    // Draw bands
    for (int i = 0; i < bandCount; i++)
    {
      fill(colors[i]);
      noStroke();
      rect(x, y + h - (i + 1) * bandHeight, 20, bandHeight);
    }
    
    // Border
    noFill();
    stroke(0);
    rect(x, y, 20, h);
    
    // Labels
    fill(255, 255, 255);
    textSize(12);
    textAlign(LEFT, CENTER);
    
    String[] labels = {"0-30%", "30-50%", "50-70%", "70-90%", "90-100%"};
    
    for (int i = 0; i < bandCount; i++)
    {
      float textY = y + h - (i + 0.5f) * bandHeight;
      
      String label = labels[i] + " (" + (int)(thresholds[i]) + "-" + (int)(thresholds[i + 1]) + ")";
      fill(255, 255, 255);
      text(label, x + 25, textY);
    }
    fill(255, 255, 255);
    text("Number of Flights", x, y - 10);
  }
  
  color getPercentileColor(int value, float[] t)
  {
    color heatColor;
    
    if (value >= t[4])
    {
      heatColor = color(255, 0, 0);      // red
    }
    else if (value >= t[3])
    {
      heatColor = color(255, 140, 0);    // orange
    }
    else if (value >= t[2])
    {
      heatColor = color(255, 220, 0);    // yellow
    }
    else if (value >= t[1])
    {
      heatColor = color(0, 200, 0);       // green
    }
    else
    {
      heatColor = color(0, 0, 255);       // light blue
    }
    
    return heatColor;
  }
  
  int getMaxCount(int[] counts)
  {
    int maxCount = 1;
    
    for (int c : counts)
    {
      if (c > maxCount)
      {
        maxCount = c;
      }
    }
    
    return maxCount;
  }
  
  float[] getPercentileThresholds(int[] counts)
  {
    if (counts == null || counts.length == 0 || counts.length < 2)
    {
      return new float[] {0, 0, 0, 0, 0, 0};
    }
    
    int[] sorted = sort(counts.clone()); 

    return new float[] {
      sorted[(int)(0.0f * (sorted.length - 1))],
      sorted[(int)(0.3f * (sorted.length - 1))],
      sorted[(int)(0.5f * (sorted.length - 1))],
      sorted[(int)(0.7f * (sorted.length - 1))],
      sorted[(int)(0.9f * (sorted.length - 1))],
      sorted[sorted.length - 1]
    };
  }
  
  
  
  // DATA
  float[] airportLatLon(String iata) {
    switch (iata.toUpperCase()) {
      // ── Alabama ──────────────────────────────────────────
      case "BIRMINGHAM, AL": return new float[]{ 33.5629f, -86.7535f };
      case "HUNTSVILLE, AL": return new float[]{ 34.6372f, -86.7751f };
      case "MOBILE, AL": return new float[]{ 30.6912f, -88.2428f };
      case "MONTGOMERY, AL": return new float[]{ 32.3006f, -86.3940f };
      case "DOTHAN, AL": return new float[]{ 31.3006f, -85.3940f }; 
  
      // ── Alaska ───────────────────────────────────────────
      case "ANCHORAGE, AK": return new float[]{ 61.1741f, -148.9961f };
      case "FAIRBANKS, AK": return new float[]{ 64.8151f, -147.8562f };
      case "JUNEAU, AK": return new float[]{ 58.3550f, -134.5763f };
      case "KETCHIKAN, AK": return new float[]{ 55.3556f, -131.7137f };
      case "SITKA, AK": return new float[]{ 57.0471f, -135.3616f };
      case "KOTZEBUE, AK": return new float[]{ 67.8151f, -154.1562f };
      case "ADAK ISLAND, AK": return new float[]{ 56.0471f, -166.3616f };
      case "KODIAK, AK": return new float[]{ 57.1741f, -151.9961f };
      case "BETHEL, AK": return new float[]{ 62.0471f, -158.0616f };
      case "BARROW, AK": return new float[]{ 69.0471f, -154.3616f };
      case "NOME, AK": return new float[]{ 66.0471f, -157.3616f };
      case "DILLINGHAM, AK": return new float[]{ 58.6471f, -153.0616f };
      case "KING SALMON, AK": return new float[]{ 59.6471f, -154.0616f };
      case "CORDOVA, AK": return new float[]{ 60.8151f, -145.8562f };
      case "YAKUTAT, AK": return new float[]{ 59.6550f, -139.5763f };
      case "PETERSBURG, AK": return new float[]{ 57.3550f, -132.5763f };
      case "WRANGELL, AK": return new float[]{ 56.7556f, -132.0137f };
      case "DEADHORSE, AK": return new float[]{ 70.2471f, -150.3616f };
  
      // ── Arizona ──────────────────────────────────────────
      case "PHOENIX, AZ": return new float[]{ 33.4373f, -112.0078f };
      case "TUCSON, AZ": return new float[]{ 32.3161f, -110.9410f }; 
      case "FLAGSTAFF, AZ": return new float[]{ 35.1385f, -111.6709f };
      case "YUMA, AZ": return new float[]{ 32.6566f, -114.6060f };
      case "PRESCOTT, AZ": return new float[]{ 34.6545f, -112.4198f };
  
      // ── Arkansas ─────────────────────────────────────────
      case "LITTLE ROCK, AR": return new float[]{ 34.7294f, -92.2243f };
      case "TEXARKANA, AR": return new float[]{ 33.6819f, -93.8068f }; 
      case "FORT SMITH, AR": return new float[]{ 35.3366f, -94.1675f };
      case "FAYETTEVILLE, AR": return new float[]{ 35.7819f, -93.3068f }; 
  
      // ── California ───────────────────────────────────────
      case "LOS ANGELES, CA": return new float[]{ 33.9425f, -118.4081f };
      case "SAN FRANCISCO, CA": return new float[]{ 37.6213f, -122.3790f };
      case "SAN DIEGO, CA": return new float[]{ 32.7336f, -117.1897f };
      case "SAN JOSE, CA": return new float[]{ 37.3626f, -121.9290f };
      case "OAKLAND, CA": return new float[]{ 37.7213f, -122.2208f };
      case "SACRAMENTO, CA": return new float[]{ 38.6954f, -121.5908f };
      case "BURBANK, CA": return new float[]{ 34.2007f, -118.3585f };
      case "LONG BEACH, CA": return new float[]{ 33.8177f, -118.1516f };
      case "ONTARIO, CA": return new float[]{ 34.0560f, -117.6012f };
      case "SANTA ANA, CA": return new float[]{ 33.6757f, -117.8682f };
      case "FRESNO, CA": return new float[]{ 36.7762f, -119.7182f };
      case "SAN LUIS OBISPO, CA": return new float[]{ 35.2368f, -120.6424f };
      case "SANTA BARBARA, CA": return new float[]{ 34.4262f, -119.8401f };
      case "REDDING, CA": return new float[]{ 40.5090f, -122.2932f };
      case "ARCATA/EUREKA, CA": return new float[]{ 40.9781f, -124.1087f };
      case "PALM SPRINGS, CA": return new float[]{ 33.4425f, -117.4081f };
      case "BAKERSFIELD, CA": return new float[]{ 34.8262f, -118.8401f };
      case "MONTEREY, CA": return new float[]{ 37.0213f, -120.3790f };
      case "SANTA ROSA, CA": return new float[]{ 38.6954f, -122.5908f };
      case "STOCKTON, CA": return new float[]{ 37.6954f, -121.5908f };
      case "BISHOP, CA": return new float[]{ 37.7762f, -118.9182f };
      case "SANTA MARIA, CA": return new float[]{ 35.2368f, -120.2424f };
  
      // ── Colorado ─────────────────────────────────────────
      case "DENVER, CO": return new float[]{ 39.8561f, -104.6737f };
      case "COLORADO SPRINGS, CO": return new float[]{ 38.8058f, -104.7008f };
      case "GRAND JUNCTION, CO": return new float[]{ 39.1224f, -108.5268f };
      case "DURANGO, CO": return new float[]{ 37.3515f, -107.7538f };
      case "ASPEN, CO": return new float[]{ 39.2232f, -106.8690f };
      case "HAYDEN, CO": return new float[]{ 40.4812f, -107.2218f };
      case "EAGLE, CO": return new float[]{ 39.6426f, -106.9177f };
      case "MONTROSE, CO": return new float[]{ 38.5098f, -107.8938f };
      case "PUEBLO, CO": return new float[]{ 38.2890f, -104.4968f };
      case "GUNNISON, CO": return new float[]{ 38.8058f, -106.7008f };
      case "ALAMOSA, CO": return new float[]{ 37.5515f, -105.7538f };
  
      // ── Connecticut ──────────────────────────────────────
      case "HARTFORD, CT": return new float[]{ 41.9389f, -72.6832f };
  
      // ── Delaware ─────────────────────────────────────────
      case "WILMINGTON, DE": return new float[]{ 39.6787f, -75.6065f }; 
  
      // ── Florida ──────────────────────────────────────────
      case "ORLANDO, FL": return new float[]{ 28.4294f, -81.3089f };
      case "MIAMI, FL": return new float[]{ 25.7959f, -80.2870f };
      case "TAMPA, FL": return new float[]{ 27.9755f, -82.5332f };
      case "FORT LAUDERDALE, FL": return new float[]{ 26.0726f, -80.1527f };
      case "JACKSONVILLE, FL": return new float[]{ 30.4941f, -81.6879f };
      case "WEST PALM BEACH/PALM BEACH": return new float[]{ 26.6832f, -80.0956f };
      case "FORT MYERS, FL": return new float[]{ 26.5362f, -81.7552f };
      case "SARASOTA/BRADENTON, FL": return new float[]{ 27.3954f, -82.5544f };
      case "PANAMA CITY, FL": return new float[]{ 30.3580f, -85.7954f };
      case "PENSACOLA, FL": return new float[]{ 30.4734f, -87.1866f };
      case "TALLAHASSEE, FL": return new float[]{ 30.3965f, -84.3503f };
      case "GAINESVILLE, FL": return new float[]{ 29.6900f, -82.2717f };
      case "DAYTONA BEACH, FL": return new float[]{ 29.1799f, -81.2581f };
      case "MELBOURNE, FL": return new float[]{ 28.1028f, -80.9453f };
      case "VALPARAISO, FL": return new float[]{ 30.4832f, -86.5254f };
      case "KEY WEST, FL": return new float[]{ 24.5561f, -81.7596f };
      case "PUNTA GORDA, FL": return new float[]{ 27.0362f, -81.9552f };
      case "ST. PETERSBURG, FL": return new float[]{ 27.6755f, -82.8332f };
      case "SANFORD, FL": return new float[]{ 28.8294f, -81.2089f };
  
      // ── Georgia ──────────────────────────────────────────
      case "ATLANTA, GA": return new float[]{ 33.6407f, -84.4277f };
      case "SAVANNAH, GA": return new float[]{ 32.1276f, -81.2021f };
      case "AUGUSTA, GA": return new float[]{ 33.3699f, -81.9645f };
      case "COLUMBUS, GA": return new float[]{ 32.5163f, -84.9389f };
      case "ALBANY, GA": return new float[]{ 31.5355f, -84.1945f };
      case "VALDOSTA, GA": return new float[]{ 30.7825f, -83.2767f };
      case "BRUNSWICK, GA": return new float[]{ 31.1276f, -81.6021f };
  
      // ── Hawaii ───────────────────────────────────────────
      case "HONOLULU, HI": return new float[]{ 21.3187f, -157.9225f };
      case "KAHULUI, HI": return new float[]{ 20.8986f, -156.4305f };
      case "KONA, HI": return new float[]{ 19.7388f, -156.0456f };
      case "LIHUE, HI": return new float[]{ 21.9760f, -159.3389f };
      case "HILO, HI": return new float[]{ 19.7205f, -155.5485f };
  
      // ── Idaho ────────────────────────────────────────────
      case "BOISE, ID": return new float[]{ 43.5644f, -116.2228f };
      case "SUN VALLEY/HAILEY/KETCHUM, ID": return new float[]{ 43.5044f, -114.2963f };
      case "TWIN FALLS, ID": return new float[]{ 42.4818f, -114.4877f };
      case "POCATELLO, ID": return new float[]{ 42.9098f, -112.5959f };
      case "IDAHO FALLS, ID": return new float[]{ 43.5146f, -112.0707f };
      case "LEWISTON, ID": return new float[]{ 45.8644f, -116.5228f };
  
      // ── Illinois ─────────────────────────────────────────
      case "CHICAGO, IL": return new float[]{ 41.9742f, -87.9073f };
      case "MOLINE, IL": return new float[]{ 41.4485f, -90.5075f };
      case "BLOOMINGTON/NORMAL, IL": return new float[]{ 40.4771f, -88.9159f };
      case "PEORIA, IL": return new float[]{ 40.6642f, -89.6933f };
      case "CHAMPAIGN/URBANA, IL": return new float[]{ 40.0399f, -88.2781f };
      case "SPRINGFIELD, IL": return new float[]{ 39.8441f, -89.6779f };
      case "ROCKFORD, IL": return new float[]{ 42.1954f, -89.0972f };
      case "BELLEVILLE, IL": return new float[]{ 38.8441f, -90.3779f };
      case "DECATUR, IL": return new float[]{ 39.8441f, -89.2779f };
  
      // ── Indiana ──────────────────────────────────────────
      case "INDIANAPOLIS, IN": return new float[]{ 39.7173f, -86.2944f };
      case "SOUTH BEND, IN": return new float[]{ 41.7087f, -86.3173f };
      case "FORT WAYNE, IN": return new float[]{ 40.9785f, -85.1951f };
      case "EVANSVILLE, IN": return new float[]{ 38.0369f, -87.5324f };
  
      // ── Iowa ─────────────────────────────────────────────
      case "DES MOINES, IA": return new float[]{ 41.5340f, -93.6631f };
      case "CEDAR RAPIDS/IOWA CITY, IA": return new float[]{ 41.8847f, -91.7108f };
      case "SIOUX CITY, IA": return new float[]{ 42.4026f, -96.3844f };
      case "DUBUQUE, IA": return new float[]{ 42.4020f, -90.7095f };
      case "WATERLOO, IA": return new float[]{ 42.3847f, -92.7108f };
      case "FORT DODGE, IA": return new float[]{ 42.3847f, -93.9108f };
      case "MASON CITY, IA": return new float[]{ 43.0340f, -93.6631f };
  
      // ── Kansas ───────────────────────────────────────────
      case "WICHITA, KS": return new float[]{ 37.6499f, -97.4331f };
      case "MANHATTAN/FT. RILEY, KS": return new float[]{ 39.1410f, -96.6708f };
      case "GARDEN CITY, KS": return new float[]{ 37.7687f, -98.8632f }; 
      case "DODGE CITY, KS": return new float[]{ 37.6499f, -98.4331f };
      case "SALINA, KS": return new float[]{ 38.7499f, -97.5331f };
      case "HAYS, KS": return new float[]{ 38.7499f, -98.1331f };
      case "LIBERAL, KS": return new float[]{ 37.2499f, -101.1331f };
  
      // ── Kentucky ─────────────────────────────────────────
      case "LOUISVILLE, KY": return new float[]{ 38.4744f, -85.3360f };
      case "CINCINNATI, OH": return new float[]{ 38.1744f, -85.7360f }; 
      case "LEXINGTON, KY": return new float[]{ 38.0365f, -84.6059f };
      case "OWENSBORO, KY": return new float[]{ 37.7401f, -87.1668f };
      case "PADUCAH, KY": return new float[]{ 37.0607f, -88.7739f };
  
      // ── Louisiana ────────────────────────────────────────
      case "NEW ORLEANS, LA": return new float[]{ 29.9934f, -90.2580f };
      case "BATON ROUGE, LA": return new float[]{ 30.5332f, -91.1496f };
      case "SHREVEPORT, LA": return new float[]{ 32.4466f, -93.8256f };
      case "LAFAYETTE, LA": return new float[]{ 30.2053f, -91.9877f };
      case "MONROE, LA": return new float[]{ 32.5109f, -92.0377f };
      case "ALEXANDRIA, LA": return new float[]{ 31.3274f, -92.5498f };
      case "LAKE CHARLES, LA": return new float[]{ 30.1261f, -93.2233f };
  
      // ── Maine ────────────────────────────────────────────
      case "BANGOR, ME": return new float[]{ 44.8074f, -68.8281f };
      case "PORTLAND, ME": return new float[]{ 43.6462f, -70.3093f };
      case "PRESQUE ISLE/HOULTON, ME": return new float[]{ 46.6890f, -68.0448f };
  
      // ── Maryland ─────────────────────────────────────────
      case "BALTIMORE, MD": return new float[]{ 39.1754f, -76.6683f };
      case "HAGERSTOWN, MD": return new float[]{ 39.6079f, -77.7295f };
      case "SALISBURY, MD": return new float[]{ 38.3405f, -75.5103f };
  
      // ── Massachusetts ────────────────────────────────────
      case "BOSTON, MA": return new float[]{ 42.3656f, -71.0096f };
      case "WORCESTER, MA": return new float[]{ 42.2673f, -71.8757f };
  
      // ── Michigan ─────────────────────────────────────────
      case "DETROIT, MI": return new float[]{ 42.2162f, -83.3554f };
      case "GRAND RAPIDS, MI": return new float[]{ 42.8808f, -85.5228f };
      case "FLINT, MI": return new float[]{ 42.9654f, -83.7436f };
      case "LANSING, MI": return new float[]{ 42.7787f, -84.5874f };
      case "SAGINAW/BAY CITY/MIDLAND, MI": return new float[]{ 43.5329f, -84.0797f };
      case "KALAMAZOO, MI": return new float[]{ 42.2350f, -85.5521f };
      case "TRAVERSE CITY, MI": return new float[]{ 44.7418f, -85.5822f };
      case "MARQUETTE, MI": return new float[]{ 46.3536f, -87.3954f };
      case "ESCANABA, MI": return new float[]{ 46.0536f, -87.3954f };
      case "ALPENA, MI": return new float[]{ 44.5162f, -83.6554f };
      case "SAULT STE. MARIE, MI": return new float[]{ 46.3536f, -84.3954f };
      case "IRON MOUNTAIN, MI": return new float[]{ 46.2536f, -88.3954f };
      case "PELLSTON, MI": return new float[]{ 45.3536f, -84.3954f };
      case "MUSKEGON, MI": return new float[]{ 43.1808f, -85.7228f };
      case "HANCOCK/HOUGHTON, MI": return new float[]{ 46.8536f, -87.9954f };
  
      // ── Minnesota ────────────────────────────────────────
      case "MINNEAPOLIS, MN": return new float[]{ 44.8848f, -93.2223f };
      case "DULUTH, MN": return new float[]{ 46.8421f, -92.1936f };
      case "ROCHESTER, MN": return new float[]{ 43.9083f, -92.5000f };
      case "HIBBING, MN": return new float[]{ 47.3866f, -92.8390f };
      case "BRAINERD, MN": return new float[]{ 46.3983f, -94.1381f };
      case "BEMIDJI, MN": return new float[]{ 47.3866f, -94.8390f };
      case "INTERNATIONAL FALLS, MN": return new float[]{ 48.4866f, -93.1390f };
      case "ST. CLOUD, MN": return new float[]{ 45.0848f, -93.6223f };
  
      // ── Mississippi ──────────────────────────────────────
      case "JACKSON/VICKSBURG, MS": return new float[]{ 32.3112f, -90.0759f };
      case "GULFPORT/BILOXI, MS": return new float[]{ 30.8073f, -89.0701f };
      case "MERIDIAN, MS": return new float[]{ 32.3326f, -88.7519f };
      case "COLUMBUS, MS": return new float[]{ 34.3326f, -88.7519f };
      case "HATTIESBURG/LAUREL, MS": return new float[]{ 31.3326f, -88.7519f };
  
      // ── Missouri ─────────────────────────────────────────
      case "ST. LOUIS, MO": return new float[]{ 38.7487f, -90.3700f };
      case "KANSAS CITY, MO": return new float[]{ 39.2976f, -94.7139f };
      case "SPRINGFIELD, MO": return new float[]{ 37.2457f, -93.3886f };
      case "COLUMBIA, MO": return new float[]{ 38.8181f, -92.2196f };
      case "CAPE GIRARDEAU, MO": return new float[]{ 36.7487f, -90.0700f };
      case "FORT LEONARD WOOD, MO": return new float[]{ 37.4181f, -92.0196f };
      case "JOPLIN, MO": return new float[]{ 37.0976f, -94.2139f };
  
      // ── Montana ──────────────────────────────────────────
      case "BILLINGS, MT": return new float[]{ 45.8077f, -108.5428f };
      case "MISSOULA, MT": return new float[]{ 46.9163f, -114.0906f };
      case "GREAT FALLS, MT": return new float[]{ 47.4820f, -111.3709f };
      case "HELENA, MT": return new float[]{ 46.6068f, -111.9830f };
      case "BOZEMAN, MT": return new float[]{ 45.7775f, -111.1531f };
      case "KALISPELL, MT": return new float[]{ 48.3163f, -114.8906f };
      case "BUTTE, MT": return new float[]{ 45.6077f, -110.5428f };
  
      // ── Nebraska ─────────────────────────────────────────
      case "OMAHA, NE": return new float[]{ 41.3032f, -95.8941f };
      case "LINCOLN, NE": return new float[]{ 40.8510f, -96.7592f };
      case "GRAND ISLAND, NE": return new float[]{ 40.9675f, -98.3096f };
      case "SCOTTSBLUFF, NE": return new float[]{ 42.3032f, -102.8941f };
      case "KEARNEY, NE": return new float[]{ 40.8510f, -98.8592f };
      case "NORTH PLATTE, NE": return new float[]{ 41.3032f, -99.8941f };
  
      // ── Nevada ───────────────────────────────────────────
      case "LAS VEGAS, NV": return new float[]{ 36.0840f, -115.1537f };
      case "RENO, NV": return new float[]{ 39.4991f, -119.7681f };
      case "ELKO, NV": return new float[]{ 41.0840f, -115.1537f };
  
      // ── New Hampshire ────────────────────────────────────
      case "MANCHESTER, NH": return new float[]{ 42.9326f, -71.4357f };
      case "PORTSMOUTH, NH": return new float[]{ 43.0779f, -70.8233f };
  
      // ── New Jersey ───────────────────────────────────────
      case "NEWARK, NJ": return new float[]{ 40.6895f, -74.1745f };
      case "ATLANTIC CITY, NJ": return new float[]{ 39.4576f, -74.5772f };
      case "TRENTON, NJ": return new float[]{ 40.0895f, -74.8745f };
  
      // ── New Mexico ───────────────────────────────────────
      case "ALBUQUERQUE, NM": return new float[]{ 35.0402f, -106.6090f };
      case "SANTA FE, NM": return new float[]{ 35.6171f, -106.0883f };
      case "ROSWELL, NM": return new float[]{ 33.3016f, -104.5306f };
      case "HOBBS, NM": return new float[]{ 33.0016f, -103.2306f };
  
      // ── New York ─────────────────────────────────────────
      case "NEW YORK, NY": return new float[]{ 40.6413f, -73.7781f };
      case "BUFFALO, NY": return new float[]{ 42.9405f, -78.7322f };
      case "ROCHESTER, NY": return new float[]{ 43.1189f, -77.6724f };
      case "SYRACUSE, NY": return new float[]{ 43.1112f, -76.1063f };
      case "ALBANY, NY": return new float[]{ 42.7483f, -73.8017f };
      case "ISLIP, NY": return new float[]{ 40.7952f, -73.1002f };
      case "BINGHAMTON, NY": return new float[]{ 42.2082f, -75.9798f };
      case "ELMIRA/CORNING, NY": return new float[]{ 42.1599f, -76.8916f };
      case "WHITE PLAINS, NY": return new float[]{ 40.8413f, -73.5781f };
      case "ITHACA/CORTLAND, NY": return new float[]{ 42.1112f, -76.5063f };
      case "WATERTOWN, NY": return new float[]{ 43.8112f, -76.1063f };
      case "NEWBURGH, NY": return new float[]{ 41.3413f, -73.7781f };
      case "PLATTSBURGH, NY": return new float[]{ 44.1112f, -74.1063f };
      case "OGDENSBURG, NY": return new float[]{ 44.0112f, -75.4063f };
      case "NIAGARA FALLS, NY": return new float[]{ 43.0405f, -78.8322f };
  
      // ── North Carolina ───────────────────────────────────
      case "CHARLOTTE, NC": return new float[]{ 35.2140f, -80.9431f };
      case "RALEIGH/DURHAM, NC": return new float[]{ 35.8776f, -78.7875f };
      case "GREENSBORO/HIGH POINT, NC": return new float[]{ 36.0978f, -79.9373f };
      case "ASHEVILLE, NC": return new float[]{ 35.4362f, -82.5418f };
      case "WILMINGTON, NC": return new float[]{ 34.2706f, -77.9026f };
      case "JACKSONVILLE/CAMP LEJEUNE, NC": return new float[]{ 34.8292f, -77.6121f };
      case "FAYETTEVILLE, NC": return new float[]{ 34.9912f, -78.8803f };
      case "NEW BERN/MOREHEAD/BEAUFORT, NC": return new float[]{ 34.9912f, -76.6803f };
      case "GREENVILLE, NC": return new float[]{ 35.4912f, -76.9803f };
      case "CONCORD, NC": return new float[]{ 35.6140f, -80.9431f };
  
      // ── North Dakota ─────────────────────────────────────
      case "FARGO, ND": return new float[]{ 46.9207f, -96.8158f };
      case "BISMARCK/MANDAN, ND": return new float[]{ 46.7727f, -100.7467f };
      case "GRAND FORKS, ND": return new float[]{ 47.9493f, -97.1761f };
      case "MINOT, ND": return new float[]{ 48.2594f, -101.2800f };
      case "WILLISTON, ND": return new float[]{ 48.2594f, -103.2800f };
      case "DICKINSON, ND": return new float[]{ 46.9594f, -102.2800f };
      case "DEVILS LAKE, ND": return new float[]{ 48.1493f, -98.6761f };
      case "JAMESTOWN, ND": return new float[]{ 47.0493f, -98.6761f };
  
      // ── Ohio ─────────────────────────────────────────────
      case "COLUMBUS, OH": return new float[]{ 39.9980f, -82.8919f };
      case "CLEVELAND, OH": return new float[]{ 41.4117f, -81.8498f };
      case "DAYTON, OH": return new float[]{ 39.9024f, -84.2194f };
      case "TOLEDO, OH": return new float[]{ 41.5868f, -83.8078f };
      case "AKRON, OH": return new float[]{ 40.9161f, -81.4422f };
  
      // ── Oklahoma ─────────────────────────────────────────
      case "OKLAHOMA CITY, OK": return new float[]{ 35.3931f, -97.6007f };
      case "TULSA, OK": return new float[]{ 36.1984f, -95.8881f };
      case "LAWTON/FORT SILL, OK": return new float[]{ 34.5677f, -98.4166f };
      case "STILLWATER, OK": return new float[]{ 36.1984f, -96.9881f };
  
      // ── Oregon ───────────────────────────────────────────
      case "PORTLAND, OR": return new float[]{ 45.5887f, -122.5975f };
      case "EUGENE, OR": return new float[]{ 44.1246f, -123.2119f };
      case "MEDFORD, OR": return new float[]{ 42.3742f, -122.8735f };
      case "BEND/REDMOND, OR": return new float[]{ 44.2541f, -121.1500f };
      case "NORTH BEND/COOS BAY, OR": return new float[]{ 43.7246f, -123.9119f };
  
      // ── Pennsylvania ─────────────────────────────────────
      case "PHILADELPHIA, PA": return new float[]{ 40.0719f, -75.2411f };
      case "PITTSBURGH, PA": return new float[]{ 40.4915f, -80.2329f };
      case "ALLENTOWN/BETHLEHEM/EASTON, PA": return new float[]{ 40.6521f, -75.4408f };
      case "SCRANTON/WILKES-BARRE, PA": return new float[]{ 41.3385f, -75.7234f };
      case "HARRISBURG, PA": return new float[]{ 40.1935f, -76.7634f };
      case "ERIE, PA": return new float[]{ 41.8831f, -80.1739f };
      case "STATE COLLEGE, PA": return new float[]{ 41.0915f, -77.8329f };
      case "LATROBE, PA": return new float[]{ 40.1915f, -79.9329f };
      case "JOHNSTOWN, PA": return new float[]{ 40.1915f, -79.4329f };
  
      // ── Rhode Island ─────────────────────────────────────
      case "PROVIDENCE, RI": return new float[]{ 41.7325f, -71.4280f };
  
      // ── South Carolina ───────────────────────────────────
      case "CHARLESTON, SC": return new float[]{ 32.8986f, -80.0405f };
      case "COLUMBIA, SC": return new float[]{ 33.9388f, -81.1195f };
      case "GREER, SC": return new float[]{ 34.8957f, -82.2189f };
      case "MYRTLE BEACH, SC": return new float[]{ 33.6797f, -78.9283f };
      case "HILTON HEAD, SC": return new float[]{ 32.2241f, -80.6975f };
      case "FLORENCE, SC": return new float[]{ 33.9986f, -80.0405f };
  
      // ── South Dakota ─────────────────────────────────────
      case "SIOUX FALLS, SD": return new float[]{ 43.5820f, -96.7418f };
      case "RAPID CITY, SD": return new float[]{ 44.0453f, -103.0574f };
      case "ABERDEEN, SD": return new float[]{ 45.4491f, -98.4218f };
      case "PIERRE, SD": return new float[]{ 44.6453f, -100.8574f };
      case "WATERTOWN, SD": return new float[]{ 45.1491f, -98.1218f };
  
      // FIX !!
      // ── Tennessee ────────────────────────────────────────
      case "NASHVILLE, TN": return new float[]{ 36.1245f, -86.6782f };
      case "MEMPHIS, TN": return new float[]{ 35.3424f, -89.9767f };
      case "KNOXVILLE, TN": return new float[]{ 35.8110f, -83.9940f };
      case "CHATTANOOGA, TN": return new float[]{ 35.3353f, -85.2038f };
      case "BRISTOL/JOHNSON CITY/KINGSPORT, TN": return new float[]{ 36.4752f, -82.4074f };
  
      // ── Texas ────────────────────────────────────────────
      case "DALLAS/FORT WORTH, TX": return new float[]{ 32.8998f, -97.0403f };
      case "IAH": return new float[]{ 29.9902f, -95.3368f };
      case "HOUSTON, TX": return new float[]{ 29.6454f, -95.2789f };
      case "DAL": return new float[]{ 32.8471f, -96.8518f };
      case "AUSTIN, TX": return new float[]{ 30.1975f, -97.6664f };
      case "SAN ANTONIO, TX": return new float[]{ 29.5337f, -98.4698f };
      case "EL PASO, TX": return new float[]{ 31.8072f, -106.3779f };
      case "LUBBOCK, TX": return new float[]{ 33.6636f, -101.8228f };
      case "AMARILLO, TX": return new float[]{ 35.2194f, -101.7059f };
      case "MIDLAND/ODESSA, TX": return new float[]{ 31.9425f, -102.2019f };
      case "CORPUS CHRISTI, TX": return new float[]{ 27.7704f, -97.5012f };
      case "ABI": return new float[]{ 32.4113f, -99.6819f };
      case "HARLINGEN/SAN BENITO, TX": return new float[]{ 26.2285f, -97.6544f };
      case "MISSION/MCALLEN/EDINBURG, TX": return new float[]{ 26.1758f, -98.2386f };
      case "LAREDO, TX": return new float[]{ 27.5438f, -99.4616f };
      case "BROWNSVILLE, TX": return new float[]{ 25.9068f, -97.4259f };
      case "TXK": return new float[]{ 33.4539f, -93.9910f };
      case "LONGVIEW, TX": return new float[]{ 32.3840f, -94.7115f };
      case "SAN ANGELO, TX": return new float[]{ 31.3577f, -100.4963f };
      case "WACO, TX": return new float[]{ 31.6113f, -97.2305f };

      // ── Utah ─────────────────────────────────────────────
      case "SALT LAKE CITY, UT": return new float[]{ 40.7884f, -111.9778f };
      case "ST. GEORGE, UT": return new float[]{ 37.3363f, -113.5103f };
      case "CEDAR CITY, UT": return new float[]{ 37.7010f, -113.0988f };
      case "PROVO, UT": return new float[]{ 40.4884f, -111.7778f };
      case "OGDEN, UT": return new float[]{ 41.0884f, -111.9778f };
      case "MOAB, UT": return new float[]{ 38.8884f, -109.4778f };
      case "VERNAL, UT": return new float[]{ 40.4884f, -109.2778f };
  
      // ── Vermont ──────────────────────────────────────────
      case "BURLINGTON, VT": return new float[]{ 44.4720f, -73.1533f };
  
      // ── Virginia ─────────────────────────────────────────
      case "WASHINGTON, DC": return new float[]{ 38.8521f, -77.4377f };
      case "NORFOLK, VA": return new float[]{ 36.8976f, -76.3173f };
      case "RICHMOND, VA": return new float[]{ 37.5052f, -77.3197f };
      case "ROANOKE, VA": return new float[]{ 37.3255f, -79.9754f };
      case "CHARLOTTESVILLE, VA": return new float[]{ 38.1386f, -78.4529f };
      case "LYNCHBURG, VA": return new float[]{ 37.3267f, -79.2004f };
      case "NEWPORT NEWS/WILLIAMSBURG, VA": return new float[]{ 37.1319f, -76.4930f };
      case "STAUNTON, VA": return new float[]{ 38.3386f, -79.0529f };
  
      // ── Washington ───────────────────────────────────────
      case "SEATTLE, WA": return new float[]{ 47.4502f, -122.3088f };
      case "SPOKANE, WA": return new float[]{ 47.6199f, -117.5338f };
      case "YAKIMA, WA": return new float[]{ 46.5682f, -120.5441f };
      case "PASCO/KENNEWICK/RICHLAND, WA": return new float[]{ 46.2647f, -119.1193f };
      case "WALLA WALLA, WA": return new float[]{ 46.0949f, -118.2887f };
      case "WENATCHEE, WA": return new float[]{ 47.3988f, -120.2056f };
      case "PULLMAN, WA": return new float[]{ 46.6199f, -117.3338f };
      case "EVERETT, WA": return new float[]{ 47.7502f, -122.3088f };
      case "BELLINGHAM, WA": return new float[]{ 48.0502f, -122.5088f };
  
      // ── West Virginia ────────────────────────────────────
      case "CHARLESTON/DUNBAR, WV": return new float[]{ 38.3731f, -81.5932f };
      case "ASHLAND, WV": return new float[]{ 38.3667f, -82.2580f };
      case "CLARKSBURG/FAIRMONT, WV": return new float[]{ 39.2966f, -80.2282f };
      case "LEWISBURG, WV": return new float[]{ 39.0451f, -81.4392f };
  
      // ── Wisconsin ────────────────────────────────────────
      case "MILWAUKEE, WI": return new float[]{ 42.9472f, -87.8966f };
      case "MADISON, WI": return new float[]{ 43.1399f, -89.3375f };
      case "GREEN BAY, WI": return new float[]{ 44.4851f, -88.1296f };
      case "MOSINEE, WI": return new float[]{ 44.7776f, -89.6668f };
      case "APPLETON, WI": return new float[]{ 44.2581f, -88.5191f };
      case "EAU CLAIRE, WI": return new float[]{ 44.8658f, -91.4843f };
      case "LA CROSSE, WI": return new float[]{ 43.8658f, -91.0843f };
      case "RHINELANDER, WI": return new float[]{ 45.3658f, -89.8843f };
  
      // ── Wyoming ──────────────────────────────────────────
      case "JACKSON, WY": return new float[]{ 43.6073f, -110.7377f };
      case "CASPER, WY": return new float[]{ 42.9080f, -106.4644f };
      case "CHEYENNE, WY": return new float[]{ 41.1557f, -104.8119f };
      case "LARAMIE, WY": return new float[]{ 41.3121f, -105.6750f };
      case "CODY, WY": return new float[]{ 44.6073f, -108.7377f };
      case "GILLETTE, WY": return new float[]{ 44.2080f, -106.1644f };
      case "ROCK SPRINGS, WY": return new float[]{ 41.6073f, -109.2377f };
      case "SHERIDAN, WY": return new float[]{ 44.8080f, -107.1644f };
      case "RIVERTON/LANDER, WY": return new float[]{ 43.0073f, -108.7377f };
      // CODY, GILETTE, ROCK SPRINGS, SHERIDAN, RIVERTON/LANDER
  
      default: return null;
    }
  }
  
  
  float[] stateBoundingBox(String st) {
    // Format: { maxLat, minLon, minLat, maxLon }
    switch (st.toUpperCase()) {
      case "AL": return new float[]{ 35.008f, -88.473f, 30.144f, -84.889f };
      case "AK": return new float[]{ 71.538f, -168.000f, 54.775f, -130.000f };
      case "AZ": return new float[]{ 37.004f, -114.818f, 31.332f, -109.045f };
      case "AR": return new float[]{ 36.500f, -94.618f, 33.004f, -89.644f };
      case "CA": return new float[]{ 42.009f, -124.409f, 32.534f, -114.131f };
      case "CO": return new float[]{ 41.003f, -109.060f, 36.993f, -102.041f };
      case "CT": return new float[]{ 42.050f, -73.728f, 40.950f, -71.787f };
      case "DE": return new float[]{ 39.839f, -75.789f, 38.451f, -75.047f };
      case "FL": return new float[]{ 31.001f, -87.635f, 24.396f, -80.031f };
      case "GA": return new float[]{ 35.001f, -85.605f, 30.356f, -80.840f };
      case "HI": return new float[]{ 22.236f, -160.247f, 18.910f, -154.807f };
      case "ID": return new float[]{ 49.001f, -117.243f, 41.988f, -111.044f };
      case "IL": return new float[]{ 42.508f, -91.513f, 36.970f, -87.020f };
      case "IN": return new float[]{ 41.761f, -88.098f, 37.772f, -84.785f };
      case "IA": return new float[]{ 43.501f, -96.639f, 40.376f, -90.140f };
      case "KS": return new float[]{ 40.003f, -102.052f, 36.993f, -94.588f };
      case "KY": return new float[]{ 39.148f, -89.572f, 36.497f, -81.965f };
      case "LA": return new float[]{ 33.019f, -94.043f, 28.928f, -88.817f };
      case "ME": return new float[]{ 47.460f, -71.084f, 43.059f, -66.950f };
      case "MD": return new float[]{ 39.723f, -79.488f, 37.912f, -74.986f };
      case "MA": return new float[]{ 42.887f, -73.508f, 41.187f, -69.928f };
      case "MI": return new float[]{ 48.306f, -90.418f, 41.696f, -82.122f };
      case "MN": return new float[]{ 49.385f, -97.239f, 43.499f, -89.491f };
      case "MS": return new float[]{ 35.008f, -91.655f, 30.173f, -88.098f };
      case "MO": return new float[]{ 40.614f, -95.774f, 35.996f, -89.099f };
      case "MT": return new float[]{ 49.001f, -116.049f, 44.358f, -104.040f };
      case "NE": return new float[]{ 43.001f, -104.054f, 39.999f, -95.308f };
      case "NV": return new float[]{ 42.002f, -120.006f, 35.002f, -114.040f };
      case "NH": return new float[]{ 45.306f, -72.557f, 42.697f, -70.610f };
      case "NJ": return new float[]{ 41.357f, -75.564f, 38.928f, -73.893f };
      case "NM": return new float[]{ 37.000f, -109.050f, 31.332f, -103.002f };
      case "NY": return new float[]{ 45.015f, -79.762f, 40.496f, -71.856f };
      case "NC": return new float[]{ 36.588f, -84.322f, 33.842f, -75.460f };
      case "ND": return new float[]{ 49.001f, -104.049f, 45.935f, -96.554f };
      case "OH": return new float[]{ 41.978f, -84.820f, 38.403f, -80.519f };
      case "OK": return new float[]{ 37.002f, -103.002f, 33.616f, -94.431f };
      case "OR": return new float[]{ 46.236f, -124.566f, 41.992f, -116.464f };
      case "PA": return new float[]{ 42.270f, -80.519f, 39.720f, -74.690f };
      case "RI": return new float[]{ 42.019f, -71.908f, 41.146f, -71.117f };
      case "SC": return new float[]{ 35.215f, -83.354f, 32.034f, -78.542f };
      case "SD": return new float[]{ 45.945f, -104.058f, 42.480f, -96.436f };
      case "TN": return new float[]{ 36.678f, -90.311f, 34.983f, -81.647f };
      case "TX": return new float[]{ 36.500f, -106.646f, 25.837f, -93.508f };
      case "UT": return new float[]{ 42.001f, -114.053f, 36.998f, -109.041f };
      case "VT": return new float[]{ 45.017f, -73.438f, 42.727f, -71.465f };
      case "VA": return new float[]{ 39.466f, -83.676f, 36.540f, -75.242f };
      case "WA": return new float[]{ 49.002f, -124.733f, 45.544f, -116.916f };
      case "WV": return new float[]{ 40.638f, -82.644f, 37.201f, -77.719f };
      case "WI": return new float[]{ 47.309f, -92.889f, 42.492f, -86.249f };
      case "WY": return new float[]{ 45.006f, -111.056f, 40.995f, -104.053f };
      default: return null;
    }
  }
}