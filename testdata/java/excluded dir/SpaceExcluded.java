// This file intentionally contains a checkstyle violation (error-level).
// It verifies that the 'exclude' input correctly handles paths with spaces.
// If scanned with google_checks.xml, this file MUST produce at least one error.
public class SpaceExcluded {
  // violation: method name must start with lowercase letter (error with google_checks)
  public void SPACE_path_test() {
    System.out.println("excluded dir with space");
  }
}
