// Orla Kealy, 10:50 AM 12/03/2026
// Description: Created reusable chart class for the flight data visualisation

// Orla Kealy, 16:00 PM 13/03/2026
// Description: Added a system to display multiple bar charts and pie charts on screen

class Charts
{
    ArrayList<BarChart> barCharts;
    ArrayList<PieChart> pieCharts;

    Charts()
    {
        barCharts = new ArrayList<BarChart>();
        pieCharts = new ArrayList<PieChart>();
    }

    void addBarChart(String[] labels, int[] values, float x, float y, float w, float h, color[] barColors)
    {
        barCharts.add(new BarChart(labels, values, x, y, w, h, barColors));
    }

    void addPieChart(String[] labels, float[] values, float x, float y, float diameter, color[] sliceColors)
    {
        pieCharts.add(new PieChart(labels, values, x, y, diameter, sliceColors));
    }

    void draw()
    {
        for (BarChart bar : barCharts)
        {
            bar.drawChart();
        }

        for (PieChart pie : pieCharts)
        {
            pie.drawChart();
        }
    }

    void clearCharts()
    {
        barCharts.clear();
        pieCharts.clear();
    }
}