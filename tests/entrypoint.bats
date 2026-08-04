#!/usr/bin/env bats
#
# Container-level tests for entrypoint.sh.
#
# These assert on what the action actually REPORTS, which the workflow-level
# tests cannot do: those run the action with the default filter-mode 'added',
# so reviewdog discards every violation outside the PR diff. Since testdata/
# is untouched by a typical PR, an exclude regression there produces no
# violations to fail on and the job passes regardless. Here we force
# -filter-mode=nofilter with the local reporter, so every violation surfaces
# on stdout and can be grepped.
#
# Scope boundary: these drive the container by setting INPUT_* directly, so
# they do NOT exercise the action.yml input wiring - a renamed input would
# leave this suite green. The remaining jobs in .github/workflows/test-other.yml
# cover that mapping through `uses: ./`.
#
# Requires: docker, bats. The image is built once (see setup_file).

setup_file() {
  export IMAGE="action-checkstyle-test:bats"
  docker build -q -t "$IMAGE" "$BATS_TEST_DIRNAME/.." >/dev/null
}

# Runs the action in the container against the repo checkout.
# Usage: run_action [ENV=VALUE ...]
run_action() {
  local -a env_args=()
  local kv
  for kv in "$@"; do
    env_args+=(-e "$kv")
  done
  docker run --rm \
    -v "$BATS_TEST_DIRNAME/..:/github/workspace" \
    -e GITHUB_WORKSPACE=/github/workspace \
    -e INPUT_REPORTER=local \
    -e INPUT_FILTER_MODE=nofilter \
    -e INPUT_FAIL_LEVEL=none \
    -e INPUT_LEVEL=info \
    -e INPUT_WORKDIR=/github/workspace/testdata/java \
    -e INPUT_CHECKSTYLE_CONFIG=google_checks.xml \
    "${env_args[@]}" \
    "$IMAGE" 2>&1
}

# --- fixture sanity -----------------------------------------------------
# Without this the exclude tests below could pass vacuously: if the fixture
# stopped producing violations, "not found in output" would be trivially true.

@test "fixture: excluded files DO produce violations when not excluded" {
  run run_action
  [ "$status" -eq 0 ]
  [[ "$output" == *"ExcludedFile.java"* ]]
  [[ "$output" == *"SpaceExcluded.java"* ]]
  [[ "$output" == *"AnotherExcluded.java"* ]]
}

@test "fixture: the non-excluded file always produces violations" {
  run run_action
  [ "$status" -eq 0 ]
  [[ "$output" == *"Application.java"* ]]
}

# --- exclude ------------------------------------------------------------

@test "exclude: an excluded directory is not analyzed" {
  run run_action "INPUT_EXCLUDE=testdata/java/excluded"
  [ "$status" -eq 0 ]
  [[ "$output" != *"ExcludedFile.java"* ]]
  # unrelated files must still be analyzed
  [[ "$output" == *"Application.java"* ]]
}

@test "exclude: subdirectories of an excluded directory are excluded too" {
  run run_action "INPUT_EXCLUDE=testdata/java/excluded"
  [ "$status" -eq 0 ]
  [[ "$output" != *"AnotherExcluded.java"* ]]
}

@test "exclude: a directory name containing a space is excluded" {
  run run_action "INPUT_EXCLUDE=testdata/java/excluded dir"
  [ "$status" -eq 0 ]
  [[ "$output" != *"SpaceExcluded.java"* ]]
  [[ "$output" == *"Application.java"* ]]
}

@test "exclude: multiple newline-separated entries all apply" {
  run run_action "INPUT_EXCLUDE=testdata/java/excluded
testdata/java/excluded dir"
  [ "$status" -eq 0 ]
  [[ "$output" != *"ExcludedFile.java"* ]]
  [[ "$output" != *"AnotherExcluded.java"* ]]
  [[ "$output" != *"SpaceExcluded.java"* ]]
  [[ "$output" == *"Application.java"* ]]
}

@test "exclude: entries are whitespace-trimmed" {
  run run_action "INPUT_EXCLUDE=   testdata/java/excluded   "
  [ "$status" -eq 0 ]
  [[ "$output" != *"ExcludedFile.java"* ]]
}

@test "exclude: a path that does not exist is tolerated, not fatal" {
  run run_action "INPUT_EXCLUDE=testdata/java/does-not-exist-yet"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Application.java"* ]]
}

# --- properties_file ----------------------------------------------------

@test "properties_file: a variable from the file is resolved into the config" {
  # max-line-length=50 makes Application.java's long line a violation;
  # without the properties file Checkstyle cannot resolve ${max-line-length}
  # and fails, so seeing a LineLength violation proves substitution happened.
  run run_action \
    "INPUT_CHECKSTYLE_CONFIG=/github/workspace/testdata/properties_file/test_checks.xml" \
    "INPUT_PROPERTIES_FILE=/github/workspace/testdata/properties_file/additional.properties"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Line is longer than 50"* ]]
}

@test "properties_file: omitting it when the config needs a variable fails loudly" {
  run run_action \
    "INPUT_CHECKSTYLE_CONFIG=/github/workspace/testdata/properties_file/test_checks.xml"
  [ "$status" -ne 0 ]
}

# --- failure modes ------------------------------------------------------

@test "invalid checkstyle config fails with a non-zero exit code" {
  run run_action "INPUT_CHECKSTYLE_CONFIG=nonexistent_config.xml"
  [ "$status" -ne 0 ]
}

# --- Checkstyle exit-code handling --------------------------------------
# Checkstyle exits with the NUMBER of error-severity violations, which
# collides with 254 (internal exception) and 255 (invalid arguments). The
# entrypoint distinguishes the two cases by whether usable XML was produced;
# nothing tested that branch until now.

@test "exit code 254 with valid XML is forwarded, not treated as a hard failure" {
  # The fixture is generated to produce exactly 254 error-severity violations,
  # so Checkstyle exits 254 while writing a perfectly good report. Aborting
  # here would drop a full set of findings on the floor.
  run run_action \
    "INPUT_WORKDIR=/github/workspace/testdata/exit_codes/src" \
    "INPUT_CHECKSTYLE_CONFIG=/github/workspace/testdata/exit_codes/checks.xml"
  [ "$status" -eq 0 ]
  [[ "$output" != *"Checkstyle failed with exit code"* ]]
  [[ "$output" == *"ExactlyTwoFiftyFour.java"* ]]
}

@test "a Checkstyle failure without usable XML aborts with its exit code" {
  # The other side of the same branch: a missing config makes Checkstyle exit
  # 255 and write a plain-text error where the XML would be, which must abort.
  run run_action "INPUT_CHECKSTYLE_CONFIG=/github/workspace/no-such-config.xml"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Checkstyle failed with exit code"* ]]
}

@test "nonexistent workdir fails with a clear message" {
  run run_action "INPUT_WORKDIR=/github/workspace/no/such/dir"
  [ "$status" -ne 0 ]
  [[ "$output" == *"workdir does not exist"* ]]
}

# --- checkstyle_version validation --------------------------------------

@test "version validation: path traversal in the version is rejected" {
  # Without validation this rewrites the download URL to an arbitrary path on
  # github.com, and the fetched JAR is then executed by `java -jar`.
  run run_action "INPUT_CHECKSTYLE_VERSION=../../../../../../attacker/repo/releases/download/v1/evil.jar?"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Invalid checkstyle_version"* ]]
  # must be rejected before any download is attempted
  [[ "$output" != *"Failed to download"* ]]
}

@test "version validation: shell metacharacters are rejected" {
  run run_action 'INPUT_CHECKSTYLE_VERSION=10.0;id'
  [ "$status" -ne 0 ]
  [[ "$output" == *"Invalid checkstyle_version"* ]]
}

@test "version validation: whitespace-bearing values are rejected" {
  run run_action "INPUT_CHECKSTYLE_VERSION=10.0 --no-check-certificate"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Invalid checkstyle_version"* ]]
}

@test "version validation: a leading, trailing or doubled dot is rejected" {
  run run_action "INPUT_CHECKSTYLE_VERSION=.10.0"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Invalid checkstyle_version"* ]]

  run run_action "INPUT_CHECKSTYLE_VERSION=10.0."
  [ "$status" -ne 0 ]
  [[ "$output" == *"Invalid checkstyle_version"* ]]

  run run_action "INPUT_CHECKSTYLE_VERSION=10..0"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Invalid checkstyle_version"* ]]
}

@test "version validation: a well-formed version passes validation and downloads" {
  # Guards against the pattern being so strict it rejects real versions.
  run run_action "INPUT_CHECKSTYLE_VERSION=10.21.0"
  [ "$status" -eq 0 ]
  [[ "$output" != *"Invalid checkstyle_version"* ]]
  [[ "$output" == *"Application.java"* ]]
}

@test "version validation: a well-formed but nonexistent version fails at download" {
  # 999.0.0 is valid syntax, so it must pass validation and fail later -
  # proving the check rejects shape, not existence.
  run run_action "INPUT_CHECKSTYLE_VERSION=999.0.0"
  [ "$status" -ne 0 ]
  [[ "$output" != *"Invalid checkstyle_version"* ]]
  [[ "$output" == *"Failed to download Checkstyle version"* ]]
}

# --- fail_level ---------------------------------------------------------

@test "fail_level=none succeeds even though violations exist" {
  run run_action "INPUT_FAIL_LEVEL=none"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Application.java"* ]]
}

@test "fail_level=warning fails when warning-level violations are reported" {
  # google_checks.xml reports at severity "warning" (its Checker sets
  # severity=warning globally), so this - not fail_level=error - is what
  # actually trips on this fixture. See the note above test-exclude in
  # .github/workflows/test-other.yml: a fail_level of "error" cannot fire
  # with this ruleset no matter what the analysis finds.
  run run_action "INPUT_FAIL_LEVEL=warning"
  [ "$status" -ne 0 ]
}

@test "fail_level=error does not fire on a warning-severity ruleset" {
  # Documents the trap rather than asserting a desirable behaviour: with
  # google_checks.xml every violation is a warning, so fail_level=error
  # passes even though the code is full of findings.
  run run_action "INPUT_FAIL_LEVEL=error"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Application.java"* ]]
}

# --- reviewdog_flags ----------------------------------------------------

@test "reviewdog_flags: extra flags reach reviewdog and take effect" {
  # The flags are expanded unquoted on purpose (word splitting is required to
  # pass several flags); this pins that the expansion actually works.
  run run_action "INPUT_REVIEWDOG_FLAGS=-fail-level=warning"
  [ "$status" -ne 0 ]
}

@test "reviewdog_flags: empty by default and harmless" {
  run run_action "INPUT_REVIEWDOG_FLAGS="
  [ "$status" -eq 0 ]
  [[ "$output" == *"Application.java"* ]]
}

# --- privilege drop -----------------------------------------------------

@test "drops root: analysis runs as the workspace owner (non-root workspace)" {
  # The container starts as root and su-exec's to the UID owning the
  # bind-mounted workspace. If that switch broke, HOME would still point at
  # the root-owned /github/home and reviewdog could not write; assert the
  # run completes and reports normally.
  run run_action
  [ "$status" -eq 0 ]
  [[ "$output" == *"Application.java"* ]]
}

@test "drops root: a root-owned workspace falls back to the checkstyle user" {
  # Named volumes are root-owned, which exercises the branch where the
  # workspace owner is UID 0 and the entrypoint must fall back to its own
  # non-root user rather than staying root.
  local vol="bats-root-owned-$$"
  docker volume create "$vol" >/dev/null
  run docker run --rm \
    -v "$vol:/github/workspace" \
    -v "$BATS_TEST_DIRNAME/..:/repo:ro" \
    -e GITHUB_WORKSPACE=/github/workspace \
    -e INPUT_REPORTER=local \
    -e INPUT_FILTER_MODE=nofilter \
    -e INPUT_FAIL_LEVEL=none \
    -e INPUT_LEVEL=info \
    -e INPUT_WORKDIR=/repo/testdata/java \
    -e INPUT_CHECKSTYLE_CONFIG=google_checks.xml \
    "$IMAGE" 2>&1
  docker volume rm "$vol" >/dev/null
  [ "$status" -eq 0 ]
  [[ "$output" == *"Application.java"* ]]
}
