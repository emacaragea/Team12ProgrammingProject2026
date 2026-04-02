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
      case "DOTHAN, AL": return new float[]{ 31.3006f, -87.3940f }; // change coordinates
  
      // ── Alaska ───────────────────────────────────────────
      case "ANC": return new float[]{ 61.1741f, -149.9961f };
      case "FAI": return new float[]{ 64.8151f, -147.8562f };
      case "JNU": return new float[]{ 58.3550f, -134.5763f };
      case "KTN": return new float[]{ 55.3556f, -131.7137f };
      case "SIT": return new float[]{ 57.0471f, -135.3616f };
  
      // ── Arizona ──────────────────────────────────────────
      case "PHX": return new float[]{ 33.4373f, -112.0078f };
      case "TUS": return new float[]{ 32.1161f, -110.9410f };
      case "FLG": return new float[]{ 35.1385f, -111.6709f };
      case "YUM": return new float[]{ 32.6566f, -114.6060f };
      case "PRC": return new float[]{ 34.6545f, -112.4198f };
  
      // ── Arkansas ─────────────────────────────────────────
      case "LIT": return new float[]{ 34.7294f, -92.2243f };
      case "XNA": return new float[]{ 36.2819f, -94.3068f };
      case "FSM": return new float[]{ 35.3366f, -94.3675f };
  
      // ── California ───────────────────────────────────────
      case "LAX": return new float[]{ 33.9425f, -118.4081f };
      case "SFO": return new float[]{ 37.6213f, -122.3790f };
      case "SAN": return new float[]{ 32.7336f, -117.1897f };
      case "SJC": return new float[]{ 37.3626f, -121.9290f };
      case "OAK": return new float[]{ 37.7213f, -122.2208f };
      case "SMF": return new float[]{ 38.6954f, -121.5908f };
      case "BUR": return new float[]{ 34.2007f, -118.3585f };
      case "LGB": return new float[]{ 33.8177f, -118.1516f };
      case "ONT": return new float[]{ 34.0560f, -117.6012f };
      case "SNA": return new float[]{ 33.6757f, -117.8682f };
      case "FAT": return new float[]{ 36.7762f, -119.7182f };
      case "SBP": return new float[]{ 35.2368f, -120.6424f };
      case "SBA": return new float[]{ 34.4262f, -119.8401f };
      case "MOD": return new float[]{ 37.6258f, -120.9544f };
      case "RDD": return new float[]{ 40.5090f, -122.2932f };
      case "ACV": return new float[]{ 40.9781f, -124.1087f };
  
      // ── Colorado ─────────────────────────────────────────
      case "DEN": return new float[]{ 39.8561f, -104.6737f };
      case "COS": return new float[]{ 38.8058f, -104.7008f };
      case "GJT": return new float[]{ 39.1224f, -108.5268f };
      case "DRO": return new float[]{ 37.1515f, -107.7538f };
      case "ASE": return new float[]{ 39.2232f, -106.8690f };
      case "HDN": return new float[]{ 40.4812f, -107.2218f };
      case "EGE": return new float[]{ 39.6426f, -106.9177f };
      case "MTJ": return new float[]{ 38.5098f, -107.8938f };
      case "PUB": return new float[]{ 38.2890f, -104.4968f };
  
      // ── Connecticut ──────────────────────────────────────
      case "BDL": return new float[]{ 41.9389f, -72.6832f };
      case "HVN": return new float[]{ 41.2638f, -72.8868f };
  
      // ── Delaware ─────────────────────────────────────────
      case "ILG": return new float[]{ 39.6787f, -75.6065f };
  
      // ── Florida ──────────────────────────────────────────
      case "MCO": return new float[]{ 28.4294f, -81.3089f };
      case "MIA": return new float[]{ 25.7959f, -80.2870f };
      case "TPA": return new float[]{ 27.9755f, -82.5332f };
      case "FLL": return new float[]{ 26.0726f, -80.1527f };
      case "JAX": return new float[]{ 30.4941f, -81.6879f };
      case "PBI": return new float[]{ 26.6832f, -80.0956f };
      case "RSW": return new float[]{ 26.5362f, -81.7552f };
      case "SRQ": return new float[]{ 27.3954f, -82.5544f };
      case "ECP": return new float[]{ 30.3580f, -85.7954f };
      case "PNS": return new float[]{ 30.4734f, -87.1866f };
      case "TLH": return new float[]{ 30.3965f, -84.3503f };
      case "GNV": return new float[]{ 29.6900f, -82.2717f };
      case "DAB": return new float[]{ 29.1799f, -81.0581f };
      case "MLB": return new float[]{ 28.1028f, -80.6453f };
      case "VPS": return new float[]{ 30.4832f, -86.5254f };
      case "EYW": return new float[]{ 24.5561f, -81.7596f };
  
      // ── Georgia ──────────────────────────────────────────
      case "ATL": return new float[]{ 33.6407f, -84.4277f };
      case "SAV": return new float[]{ 32.1276f, -81.2021f };
      case "AGS": return new float[]{ 33.3699f, -81.9645f };
      case "CSG": return new float[]{ 32.5163f, -84.9389f };
      case "ABY": return new float[]{ 31.5355f, -84.1945f };
      case "VLD": return new float[]{ 30.7825f, -83.2767f };
      case "MCN": return new float[]{ 32.6928f, -83.6492f };
  
      // ── Hawaii ───────────────────────────────────────────
      case "HNL": return new float[]{ 21.3187f, -157.9225f };
      case "OGG": return new float[]{ 20.8986f, -156.4305f };
      case "KOA": return new float[]{ 19.7388f, -156.0456f };
      case "LIH": return new float[]{ 21.9760f, -159.3389f };
      case "ITO": return new float[]{ 19.7205f, -155.0485f };
  
      // ── Idaho ────────────────────────────────────────────
      case "BOI": return new float[]{ 43.5644f, -116.2228f };
      case "SUN": return new float[]{ 43.5044f, -114.2963f };
      case "TWF": return new float[]{ 42.4818f, -114.4877f };
      case "PIH": return new float[]{ 42.9098f, -112.5959f };
      case "IDA": return new float[]{ 43.5146f, -112.0707f };
  
      // ── Illinois ─────────────────────────────────────────
      case "ORD": return new float[]{ 41.9742f, -87.9073f };
      case "MDW": return new float[]{ 41.7868f, -87.7522f };
      case "MLI": return new float[]{ 41.4485f, -90.5075f };
      case "BMI": return new float[]{ 40.4771f, -88.9159f };
      case "PIA": return new float[]{ 40.6642f, -89.6933f };
      case "CMI": return new float[]{ 40.0399f, -88.2781f };
      case "SPI": return new float[]{ 39.8441f, -89.6779f };
      case "RFD": return new float[]{ 42.1954f, -89.0972f };
  
      // ── Indiana ──────────────────────────────────────────
      case "IND": return new float[]{ 39.7173f, -86.2944f };
      case "SBN": return new float[]{ 41.7087f, -86.3173f };
      case "FWA": return new float[]{ 40.9785f, -85.1951f };
      case "EVV": return new float[]{ 38.0369f, -87.5324f };
  
      // ── Iowa ─────────────────────────────────────────────
      case "DSM": return new float[]{ 41.5340f, -93.6631f };
      case "CID": return new float[]{ 41.8847f, -91.7108f };
      case "SUX": return new float[]{ 42.4026f, -96.3844f };
      case "DBQ": return new float[]{ 42.4020f, -90.7095f };
  
      // ── Kansas ───────────────────────────────────────────
      case "ICT": return new float[]{ 37.6499f, -97.4331f };
      case "MHK": return new float[]{ 39.1410f, -96.6708f };
      case "TOP": return new float[]{ 39.0687f, -95.6632f };
  
      // ── Kentucky ─────────────────────────────────────────
      case "SDF": return new float[]{ 38.1744f, -85.7360f };
      case "CVG": return new float[]{ 39.0488f, -84.6678f };
      case "LEX": return new float[]{ 38.0365f, -84.6059f };
      case "OWB": return new float[]{ 37.7401f, -87.1668f };
      case "PAH": return new float[]{ 37.0607f, -88.7739f };
  
      // ── Louisiana ────────────────────────────────────────
      case "MSY": return new float[]{ 29.9934f, -90.2580f };
      case "BTR": return new float[]{ 30.5332f, -91.1496f };
      case "SHV": return new float[]{ 32.4466f, -93.8256f };
      case "LFT": return new float[]{ 30.2053f, -91.9877f };
      case "MLU": return new float[]{ 32.5109f, -92.0377f };
      case "AEX": return new float[]{ 31.3274f, -92.5498f };
      case "LCH": return new float[]{ 30.1261f, -93.2233f };
  
      // ── Maine ────────────────────────────────────────────
      case "BANGOR, ME": return new float[]{ 44.8074f, -68.8281f };
      case "PORTLAND, ME": return new float[]{ 43.6462f, -70.3093f };
      case "RKD": return new float[]{ 44.0601f, -69.0992f };
      case "PRESQUE ISLE/HOULTON, ME": return new float[]{ 46.6890f, -68.0448f };
  
      // ── Maryland ─────────────────────────────────────────
      case "BWI": return new float[]{ 39.1754f, -76.6683f };
      case "HGR": return new float[]{ 39.7079f, -77.7295f };
      case "SBY": return new float[]{ 38.3405f, -75.5103f };
  
      // ── Massachusetts ────────────────────────────────────
      case "BOS": return new float[]{ 42.3656f, -71.0096f };
      case "ORH": return new float[]{ 42.2673f, -71.8757f };
      case "ACK": return new float[]{ 41.2531f, -70.0600f };
      case "MVY": return new float[]{ 41.3931f, -70.6154f };
  
      // ── Michigan ─────────────────────────────────────────
      case "DTW": return new float[]{ 42.2162f, -83.3554f };
      case "GRR": return new float[]{ 42.8808f, -85.5228f };
      case "FNT": return new float[]{ 42.9654f, -83.7436f };
      case "LAN": return new float[]{ 42.7787f, -84.5874f };
      case "MBS": return new float[]{ 43.5329f, -84.0797f };
      case "AZO": return new float[]{ 42.2350f, -85.5521f };
      case "TVC": return new float[]{ 44.7418f, -85.5822f };
      case "MQT": return new float[]{ 46.3536f, -87.3954f };
  
      // ── Minnesota ────────────────────────────────────────
      case "MSP": return new float[]{ 44.8848f, -93.2223f };
      case "DLH": return new float[]{ 46.8421f, -92.1936f };
      case "RST": return new float[]{ 43.9083f, -92.5000f };
      case "HIB": return new float[]{ 47.3866f, -92.8390f };
      case "BRD": return new float[]{ 46.3983f, -94.1381f };
  
      // ── Mississippi ──────────────────────────────────────
      case "JAN": return new float[]{ 32.3112f, -90.0759f };
      case "GPT": return new float[]{ 30.4073f, -89.0701f };
      case "MEI": return new float[]{ 32.3326f, -88.7519f };
      case "TUP": return new float[]{ 34.2681f, -88.7699f };
  
      // ── Missouri ─────────────────────────────────────────
      case "STL": return new float[]{ 38.7487f, -90.3700f };
      case "MCI": return new float[]{ 39.2976f, -94.7139f };
      case "SGF": return new float[]{ 37.2457f, -93.3886f };
      case "COU": return new float[]{ 38.8181f, -92.2196f };
  
      // ── Montana ──────────────────────────────────────────
      case "BIL": return new float[]{ 45.8077f, -108.5428f };
      case "MSO": return new float[]{ 46.9163f, -114.0906f };
      case "GTF": return new float[]{ 47.4820f, -111.3709f };
      case "HLN": return new float[]{ 46.6068f, -111.9830f };
      case "BZN": return new float[]{ 45.7775f, -111.1531f };
  
      // ── Nebraska ─────────────────────────────────────────
      case "OMA": return new float[]{ 41.3032f, -95.8941f };
      case "LNK": return new float[]{ 40.8510f, -96.7592f };
      case "GRI": return new float[]{ 40.9675f, -98.3096f };
  
      // ── Nevada ───────────────────────────────────────────
      case "LAS": return new float[]{ 36.0840f, -115.1537f };
      case "RNO": return new float[]{ 39.4991f, -119.7681f };
  
      // ── New Hampshire ────────────────────────────────────
      case "MHT": return new float[]{ 42.9326f, -71.4357f };
      case "PSM": return new float[]{ 43.0779f, -70.8233f };
  
      // ── New Jersey ───────────────────────────────────────
      case "EWR": return new float[]{ 40.6895f, -74.1745f };
      case "ACY": return new float[]{ 39.4576f, -74.5772f };
  
      // ── New Mexico ───────────────────────────────────────
      case "ABQ": return new float[]{ 35.0402f, -106.6090f };
      case "SAF": return new float[]{ 35.6171f, -106.0883f };
      case "ROW": return new float[]{ 33.3016f, -104.5306f };
  
      // ── New York ─────────────────────────────────────────
      case "JFK": return new float[]{ 40.6413f, -73.7781f };
      case "LGA": return new float[]{ 40.7769f, -73.8740f };
      case "BUF": return new float[]{ 42.9405f, -78.7322f };
      case "ROC": return new float[]{ 43.1189f, -77.6724f };
      case "SYR": return new float[]{ 43.1112f, -76.1063f };
      case "ALB": return new float[]{ 42.7483f, -73.8017f };
      case "ISP": return new float[]{ 40.7952f, -73.1002f };
      case "BGM": return new float[]{ 42.2082f, -75.9798f };
      case "ELM": return new float[]{ 42.1599f, -76.8916f };
  
      // ── North Carolina ───────────────────────────────────
      case "CLT": return new float[]{ 35.2140f, -80.9431f };
      case "RDU": return new float[]{ 35.8776f, -78.7875f };
      case "GSO": return new float[]{ 36.0978f, -79.9373f };
      case "AVL": return new float[]{ 35.4362f, -82.5418f };
      case "ILM": return new float[]{ 34.2706f, -77.9026f };
      case "OAJ": return new float[]{ 34.8292f, -77.6121f };
      case "FAY": return new float[]{ 34.9912f, -78.8803f };
  
      // ── North Dakota ─────────────────────────────────────
      case "FAR": return new float[]{ 46.9207f, -96.8158f };
      case "BIS": return new float[]{ 46.7727f, -100.7467f };
      case "GFK": return new float[]{ 47.9493f, -97.1761f };
      case "MOT": return new float[]{ 48.2594f, -101.2800f };
  
      // ── Ohio ─────────────────────────────────────────────
      case "CMH": return new float[]{ 39.9980f, -82.8919f };
      case "CLE": return new float[]{ 41.4117f, -81.8498f };
      case "DAY": return new float[]{ 39.9024f, -84.2194f };
      case "TOL": return new float[]{ 41.5868f, -83.8078f };
      case "CAK": return new float[]{ 40.9161f, -81.4422f };
  
      // ── Oklahoma ─────────────────────────────────────────
      case "OKC": return new float[]{ 35.3931f, -97.6007f };
      case "TUL": return new float[]{ 36.1984f, -95.8881f };
      case "LAW": return new float[]{ 34.5677f, -98.4166f };
  
      // ── Oregon ───────────────────────────────────────────
      case "PDX": return new float[]{ 45.5887f, -122.5975f };
      case "EUG": return new float[]{ 44.1246f, -123.2119f };
      case "MFR": return new float[]{ 42.3742f, -122.8735f };
      case "RDM": return new float[]{ 44.2541f, -121.1500f };
  
      // ── Pennsylvania ─────────────────────────────────────
      case "PHL": return new float[]{ 39.8719f, -75.2411f };
      case "PIT": return new float[]{ 40.4915f, -80.2329f };
      case "ABE": return new float[]{ 40.6521f, -75.4408f };
      case "AVP": return new float[]{ 41.3385f, -75.7234f };
      case "MDT": return new float[]{ 40.1935f, -76.7634f };
      case "ERI": return new float[]{ 42.0831f, -80.1739f };
  
      // ── Rhode Island ─────────────────────────────────────
      case "PVD": return new float[]{ 41.7325f, -71.4280f };
  
      // ── South Carolina ───────────────────────────────────
      case "CHS": return new float[]{ 32.8986f, -80.0405f };
      case "CAE": return new float[]{ 33.9388f, -81.1195f };
      case "GSP": return new float[]{ 34.8957f, -82.2189f };
      case "MYR": return new float[]{ 33.6797f, -78.9283f };
      case "HHH": return new float[]{ 32.2241f, -80.6975f };
  
      // ── South Dakota ─────────────────────────────────────
      case "FSD": return new float[]{ 43.5820f, -96.7418f };
      case "RAP": return new float[]{ 44.0453f, -103.0574f };
      case "ABR": return new float[]{ 45.4491f, -98.4218f };
  
      // ── Tennessee ────────────────────────────────────────
      case "BNA": return new float[]{ 36.1245f, -86.6782f };
      case "MEM": return new float[]{ 35.0424f, -89.9767f };
      case "TYS": return new float[]{ 35.8110f, -83.9940f };
      case "CHA": return new float[]{ 35.0353f, -85.2038f };
      case "TRI": return new float[]{ 36.4752f, -82.4074f };
  
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
      // GRK - Killeen
      // ABI - Abilene
      // TYR - Tyler Pounds
      // CLL - College Station
      // SPS - Wichita Falls
      // BPT - Beaumont/Port Arthur
      // DRT - Del Rio
      // VCT - Victoria


  
      // ── Utah ─────────────────────────────────────────────
      case "SLC": return new float[]{ 40.7884f, -111.9778f };
      case "SGU": return new float[]{ 37.0363f, -113.5103f };
      case "CDC": return new float[]{ 37.7010f, -113.0988f };
      case "CNY": return new float[]{ 38.7560f, -109.7550f };
  
      // ── Vermont ──────────────────────────────────────────
      case "BTV": return new float[]{ 44.4720f, -73.1533f };
      case "RUT": return new float[]{ 43.5294f, -72.9496f };
  
      // ── Virginia ─────────────────────────────────────────
      case "DCA": return new float[]{ 38.8521f, -77.0377f };
      case "IAD": return new float[]{ 38.9531f, -77.4565f };
      case "ORF": return new float[]{ 36.8976f, -76.0173f };
      case "RIC": return new float[]{ 37.5052f, -77.3197f };
      case "ROA": return new float[]{ 37.3255f, -79.9754f };
      case "CHO": return new float[]{ 38.1386f, -78.4529f };
      case "LYH": return new float[]{ 37.3267f, -79.2004f };
      case "PHF": return new float[]{ 37.1319f, -76.4930f };
  
      // ── Washington ───────────────────────────────────────
      case "SEA": return new float[]{ 47.4502f, -122.3088f };
      case "GEG": return new float[]{ 47.6199f, -117.5338f };
      case "YKM": return new float[]{ 46.5682f, -120.5441f };
      case "PSC": return new float[]{ 46.2647f, -119.1193f };
      case "ALW": return new float[]{ 46.0949f, -118.2887f };
      case "CLM": return new float[]{ 48.1202f, -123.5000f };
      case "EAT": return new float[]{ 47.3988f, -120.2056f };
  
      // ── West Virginia ────────────────────────────────────
      case "CRW": return new float[]{ 38.3731f, -81.5932f };
      case "HTS": return new float[]{ 38.3667f, -82.5580f };
      case "CKB": return new float[]{ 39.2966f, -80.2282f };
      case "PKB": return new float[]{ 39.3451f, -81.4392f };
  
      // ── Wisconsin ────────────────────────────────────────
      case "MKE": return new float[]{ 42.9472f, -87.8966f };
      case "MSN": return new float[]{ 43.1399f, -89.3375f };
      case "GRB": return new float[]{ 44.4851f, -88.1296f };
      case "CWA": return new float[]{ 44.7776f, -89.6668f };
      case "ATW": return new float[]{ 44.2581f, -88.5191f };
      case "EAU": return new float[]{ 44.8658f, -91.4843f };
  
      // ── Wyoming ──────────────────────────────────────────
      case "JAC": return new float[]{ 43.6073f, -110.7377f };
      case "CPR": return new float[]{ 42.9080f, -106.4644f };
      case "CYS": return new float[]{ 41.1557f, -104.8119f };
      case "LAR": return new float[]{ 41.3121f, -105.6750f };
  
      default: return null;
    }
  }
  
  
  float[] stateBoundingBox(String st) {
    // Format: { maxLat, minLon, minLat, maxLon }
    switch (st.toUpperCase()) {
      case "AL": return new float[]{ 35.008f, -88.473f, 30.144f, -84.889f };
      case "Alaska": return new float[]{ 71.538f, -168.000f, 54.775f, -130.000f };
      case "Arizona": return new float[]{ 37.004f, -114.818f, 31.332f, -109.045f };
      case "Arkansas": return new float[]{ 36.500f, -94.618f, 33.004f, -89.644f };
      case "California": return new float[]{ 42.009f, -124.409f, 32.534f, -114.131f };
      case "Colorado": return new float[]{ 41.003f, -109.060f, 36.993f, -102.041f };
      case "Connecticut": return new float[]{ 42.050f, -73.728f, 40.950f, -71.787f };
      case "Delaware": return new float[]{ 39.839f, -75.789f, 38.451f, -75.047f };
      case "Florida": return new float[]{ 31.001f, -87.635f, 24.396f, -80.031f };
      case "Georgia": return new float[]{ 35.001f, -85.605f, 30.356f, -80.840f };
      case "Hawaii": return new float[]{ 22.236f, -160.247f, 18.910f, -154.807f };
      case "Idaho": return new float[]{ 49.001f, -117.243f, 41.988f, -111.044f };
      case "Illinois": return new float[]{ 42.508f, -91.513f, 36.970f, -87.020f };
      case "Indiana": return new float[]{ 41.761f, -88.098f, 37.772f, -84.785f };
      case "Iowa": return new float[]{ 43.501f, -96.639f, 40.376f, -90.140f };
      case "Kansas": return new float[]{ 40.003f, -102.052f, 36.993f, -94.588f };
      case "Kentucky": return new float[]{ 39.148f, -89.572f, 36.497f, -81.965f };
      case "Lousiana": return new float[]{ 33.019f, -94.043f, 28.928f, -88.817f };
      case "ME": return new float[]{ 47.460f, -71.084f, 43.059f, -66.950f };
      case "Maryland": return new float[]{ 39.723f, -79.488f, 37.912f, -74.986f };
      case "Massachusetts": return new float[]{ 42.887f, -73.508f, 41.187f, -69.928f };
      case "Michigan": return new float[]{ 48.306f, -90.418f, 41.696f, -82.122f };
      case "Minnesota": return new float[]{ 49.385f, -97.239f, 43.499f, -89.491f };
      case "Mississippi": return new float[]{ 35.008f, -91.655f, 30.173f, -88.098f };
      case "Missouri": return new float[]{ 40.614f, -95.774f, 35.996f, -89.099f };
      case "Montana": return new float[]{ 49.001f, -116.049f, 44.358f, -104.040f };
      case "Nebraska": return new float[]{ 43.001f, -104.054f, 39.999f, -95.308f };
      case "Nevada": return new float[]{ 42.002f, -120.006f, 35.002f, -114.040f };
      case "New Hampshire": return new float[]{ 45.306f, -72.557f, 42.697f, -70.610f };
      case "New Jersey": return new float[]{ 41.357f, -75.564f, 38.928f, -73.893f };
      case "New Mexico": return new float[]{ 37.000f, -109.050f, 31.332f, -103.002f };
      case "New York": return new float[]{ 45.015f, -79.762f, 40.496f, -71.856f };
      case "North Carolina": return new float[]{ 36.588f, -84.322f, 33.842f, -75.460f };
      case "North Dakota": return new float[]{ 49.001f, -104.049f, 45.935f, -96.554f };
      case "Ohio": return new float[]{ 41.978f, -84.820f, 38.403f, -80.519f };
      case "Oklahoma": return new float[]{ 37.002f, -103.002f, 33.616f, -94.431f };
      case "Oregon": return new float[]{ 46.236f, -124.566f, 41.992f, -116.464f };
      case "Pennsylvania": return new float[]{ 42.270f, -80.519f, 39.720f, -74.690f };
      case "Rhode Island": return new float[]{ 42.019f, -71.908f, 41.146f, -71.117f };
      case "South Carolina": return new float[]{ 35.215f, -83.354f, 32.034f, -78.542f };
      case "South Dakota": return new float[]{ 45.945f, -104.058f, 42.480f, -96.436f };
      case "Tennessee": return new float[]{ 36.678f, -90.311f, 34.983f, -81.647f };
      case "TX": return new float[]{ 36.500f, -106.646f, 25.837f, -93.508f };
      case "Utah": return new float[]{ 42.001f, -114.053f, 36.998f, -109.041f };
      case "Vermont": return new float[]{ 45.017f, -73.438f, 42.727f, -71.465f };
      case "Virginia": return new float[]{ 39.466f, -83.676f, 36.540f, -75.242f };
      case "Washington": return new float[]{ 49.002f, -124.733f, 45.544f, -116.916f };
      case "West Virginia": return new float[]{ 40.638f, -82.644f, 37.201f, -77.719f };
      case "Wisconsin": return new float[]{ 47.309f, -92.889f, 42.492f, -86.249f };
      case "Wyoming": return new float[]{ 45.006f, -111.056f, 40.995f, -104.053f };
      default: return null;
    }
  }
}