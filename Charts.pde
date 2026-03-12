// Orla Kealy, 10:50 AM 12/03/2026
// Description: Created reusable chart class for the flight data visualisation

BarChart bar;
PieChart pie;

void setup()
{
    size(800, 600);

    String[] barLabels = {"AA", "DL", "UA", "WN"};
    int[] barValues = {120, 80, 150, 90};

    String[] pieLabels = {"On Time", "Delayed", "Cancelled"};
    float[] pieValues = {70, 20, 10};

    bar = new BarChart(barLabels, barValues, 100, 100, 500, 500);
    pie = new PieChart(pieLabels, pieValues, 600, 200, 200);
}

void draw()
{
    background(255);
    bar.drawChart();
    pie.drawChart();
}