// Orla Kealy, 10:50 AM 12/03/2026
// Description: Created reusable chart class for the flight data visualisation

// Orla Kealy, 16:00 PM 13/03/2026
// Description: Added a system to display multiple bar charts and pie charts on screen

// Orla Kealy, 18:00 PM 15/03/2026
// Description: Added filters to charts

// Orla Kealy, 10:30 AM 18/03/2026
// Description: Added scatterplots to charts

// Orla Kealy 21:00 PM 21/03/2026
// Description: Enable mousePressed for bar charts - for sorting buttons

class Charts
{
    ArrayList<BarChart> barCharts;
    ArrayList<PieChart> pieCharts;
    ArrayList<chartMultiSelectFilter> filters;
    ArrayList<ScatterPlot> scatterPlots;

    Charts()
    {
        barCharts = new ArrayList<BarChart>();
        pieCharts = new ArrayList<PieChart>();
        filters = new ArrayList<chartMultiSelectFilter>();
        scatterPlots = new ArrayList<ScatterPlot>();
    }

    // addBarChart
    // Adds and stores barChart object
    void addBarChart(String title, String[] labels, int[] values, float x, float y, float w, float h, color[] barColors, boolean enableFilter)
    {
        barCharts.add(new BarChart(title, labels, values, x, y, w, h, barColors));
        
        if (enableFilter)
        {
          filters.add(new chartMultiSelectFilter(labels, values, x + w + 30, y - 70));
        }
        else
        {
          filters.add(null);
        }
    }

    // addPieChart
    // Adds and stores pieChart object
    void addPieChart(String title, String[] labels, float[] values, float x, float y, float diameter, color[] sliceColors)
    {
        pieCharts.add(new PieChart(title, labels, values, x, y, diameter, sliceColors));
    }
    
    // addScatterPlot
    // Adds and stores scatterPlot object
    void addScatterPlot(String title, String xLabel, String yLabel, float[] xValues, float[] yValues, String[] labels, float x, float y, float w, float h)
    {
      scatterPlots.add(new ScatterPlot(title, xLabel, yLabel, xValues, yValues, labels, x, y, w, h));
    }

    // chartsDraw
    // Draws each bar chart, pie chart and scatter plot
    void chartsDraw()
    {
        for (int i = 0; i < barCharts.size(); i++)
        {
            BarChart bar = barCharts.get(i);
            chartMultiSelectFilter filter = filters.get(i);
            
            // Checks if filter is enabled for the bar chart
            if (filter != null)
            {
              filter.drawFilter();
              
              if (filter.changed)
              {
                bar.setData(filter.getFilteredLabels(), filter.getFilteredValues(), null);
                filter.changed = false;
              }
            }
            
            bar.drawChart();
        }

        for (PieChart pie : pieCharts)
        {
            pie.drawChart();
        }
        
        for (ScatterPlot scatter : scatterPlots)
        {
          scatter.drawChart();
        }
    }
    
    // mousePressed
    // Handles when mouse is pressed for barChart and chartMultiSelectFilter
    void mousePressed()
    {
      for (chartMultiSelectFilter filter : filters)
      {
        if (filter != null)
        {
          filter.mousePressed();
        }
      }
      
      for (BarChart chart : barCharts)
      {
        chart.handleMousePressed();
      }
    }
    
    // keyPressed
    // Handles when key is pressed for chartMultiSelectFilter search function
    void keyPressed(char key)
    {
      for (chartMultiSelectFilter filter : filters)
      {
        if (filter != null)
        {
          filter.keyPressed(key);
        }
      }
    }

    // clearCharts
    // Clears the charts when called
    void clearCharts()
    {
        barCharts.clear();
        pieCharts.clear();
        scatterPlots.clear();
        filters.clear();
    }
}