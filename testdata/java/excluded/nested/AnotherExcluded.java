// This file intentionally contains a checkstyle violation (error-level).
// It verifies that nested directories inside an excluded path are also excluded.
// If scanned with google_checks.xml, this file MUST produce at least one error.
public class AnotherExcluded {
  // violation: method name must start with lowercase letter (error with google_checks)
  public void NESTED_bad_name() {
    System.out.println("nested excluded");
  }
}
