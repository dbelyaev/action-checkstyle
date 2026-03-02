import java.util.*;
import java.io.*;

// This file intentionally contains checkstyle violations.
// It is used to verify that the 'exclude' input correctly prevents scanning of excluded directories.
// If this file is scanned with google_checks.xml, it MUST produce errors.
public class ExcludedFile {
  // violation: missing javadoc, wrong naming convention
  public static String BAD_method_name(String x) {
    // violation: line too long
    String result = "This line is intentionally very long to trigger a LineLength violation in checkstyle when scanning with default google_checks configuration which limits line length to 100 characters, so we keep going to make sure";
    if(x == null){
      return result;
    }
    return x + result;
  }

  // violation: missing javadoc
  public void AnotherBadMethod() {
    int x = 1;
    int y = 2;
    int z = 3;
    System.out.println(x + y + z);
  }
}
