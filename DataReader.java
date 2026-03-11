import java.io.*;
public class DataReader{

    
	public static void main (String [] args throws Exception){
        System.out.println("Test");
		FileReader fr = new FileReader("/Users/jessm/Desktop/ProgrammingProject/flights2k.csv");
		BufferedReader br = new BufferedReader(fr);
		int i;
		while(i=br.red())!=-1){
			System.out.println((char)i);
		}
		br.close();
		fr.close();
	}
}