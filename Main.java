import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.zip.Adler32;
import java.util.zip.Checksum;

class Main{
    public static void main(String[] args){
        Checksum sum = new Adler32();
        sum.update(1);
        System.out.println(sum.getValue());
    }
}