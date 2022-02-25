import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.Scanner;

class test {
    public static void main(String[] args) {
        File file = new File("A:\\Flutter\\anom\\anom.iml");
        try {
            Scanner reader = new Scanner(file);
            while (reader.hasNextLine()) {
                System.out.println(reader.nextLine().contains("\n"));
            }
            reader.close();
        } catch (FileNotFoundException e) {
            System.out.println("Java is Broken");
        }

    }
}