//2PM, 11/03/26, Jesse Margarites
//Used a faster method than loadBytes and loadStrings with the BufferedReader.
//This makes it easier to read it line by line with a scanner
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
final static int SCREEN_WIDTH = 500;
final static int SCREEN_HEIGHT = 450;

void setup() {
  
  BufferedReader reader;
  try {
    reader = new BufferedReader(new FileReader(sketchPath("flights_full.csv")));  //using sketchPath to correctly find this file from any machine
    String line = reader.readLine();
    while (line != null) {
      println(line);
      line = reader.readLine();
    }
    reader.close();
  } catch(Exception e) {
    System.out.println(e);
  }
}

void draw() {
  
}