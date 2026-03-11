//2PM, 11/03/26, Jesse Margarites

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