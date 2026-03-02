import java.util.*;

// This file intentionally contains checkstyle violations.
// It verifies that nested directories inside an excluded path are also excluded from scanning.
public class AnotherExcluded {
  // violation: missing javadoc, bad naming
  public static int bad_CONSTANT = 42;

  // violation: missing javadoc
  public void methodWith_Bad_Name() {
    // violation: line too long
    String longString = "Another intentionally long line that exceeds the maximum line length allowed by google_checks configuration to ensure a violation is generated if this file is ever scanned by checkstyle during testing";
    System.out.println(longString);
  }
}
