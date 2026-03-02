// This file intentionally contains a checkstyle violation (error-level).
// It verifies that the 'exclude' input prevents scanning of excluded directories.
// If scanned with google_checks.xml, this file MUST produce at least one error.
public class ExcludedFile {
  // violation: method name must start with lowercase letter (error with google_checks)
  public void BAD_method_name() {
    System.out.println("excluded");
  }
}
