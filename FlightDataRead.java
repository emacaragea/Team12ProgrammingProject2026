//2PM, 11/03/26, Jesse Margarites
//Used a faster method than loadBytes and loadStrings with the BufferedReader. This makes it easier to read it line by line with a scanner

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

public class FlightDataRead {

 public static void main(String[] args) {
  BufferedReader reader;

  try {
   reader = new BufferedReader(new FileReader("flights_full.csv"));
   String line = reader.readLine();

   while (line != null) {
    System.out.println(line);
    line = reader.readLine();
   }

   reader.close();
  } catch(Exception e){System.out.println(e);}
   
  
 }

}