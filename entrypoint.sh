#!/bin/sh
command -v reviewdog >/dev/null 2>&1 || { echo >&2 "reviewdog: not found"; exit 1; }

# shellcheck disable=SC3040 # pipefail is supported by Alpine ash used in this Docker image
set -eo pipefail

# output some information
{ echo "Pre-installed"; java -jar /opt/lib/checkstyle.jar --version; } | sed ':a;N;s/\n/ /;ba'

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
  git config --global --add safe.directory "${GITHUB_WORKSPACE}" || exit 1
fi

# resolve workdir to canonical absolute path so that Java's File.getAbsolutePath()
# produces clean paths (without "./") that match the exclude patterns exactly
if [ -n "${INPUT_WORKDIR}" ]; then
  if ! INPUT_WORKDIR="$(realpath "${INPUT_WORKDIR}" 2>/dev/null)"; then
    echo "workdir does not exist: ${INPUT_WORKDIR}" >&2
    exit 1
  fi
fi

# build optional checkstyle arguments safely using positional parameters
set --

# user supplied custom properties file parameter
if [ -n "${INPUT_PROPERTIES_FILE}" ]; then
  set -- "$@" -p "${INPUT_PROPERTIES_FILE}"
fi

# user supplied exclude paths, build -e flags for checkstyle
if [ -n "${INPUT_EXCLUDE}" ]; then
  while IFS= read -r dir; do
    dir="$(printf '%s' "$dir" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    if [ -n "$dir" ]; then
      # resolve to absolute path for reliable matching
      resolved="$(realpath "$dir" 2>/dev/null)" || {
        # realpath failed (dir doesn't exist yet); build absolute path manually
        case "$dir" in
          /*) resolved="$dir" ;;
          *)  resolved="${GITHUB_WORKSPACE:+${GITHUB_WORKSPACE%/}/}$dir" ;;
        esac
      }
      set -- "$@" -e "$resolved"
    fi
  done <<EOF
${INPUT_EXCLUDE}
EOF
fi

# user wants to use custom Checkstyle version, try to install it
if [ -n "${INPUT_CHECKSTYLE_VERSION}" ]; then
  echo '::group::📥 Installing user-defined Checkstyle version ... https://github.com/checkstyle/checkstyle'
  url="https://github.com/checkstyle/checkstyle/releases/download/checkstyle-${INPUT_CHECKSTYLE_VERSION}/checkstyle-${INPUT_CHECKSTYLE_VERSION}-all.jar"

  echo "Custom Checkstyle version has been configured: 'v${INPUT_CHECKSTYLE_VERSION}', try to download from ${url}"
  if ! wget -q -O /opt/lib/checkstyle.jar "$url"; then
    echo "Failed to download Checkstyle version ${INPUT_CHECKSTYLE_VERSION}" >&2
    exit 1
  fi

  echo '::endgroup::'
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

# run check
echo '::group:: Running Checkstyle with reviewdog 🐶 ...'
{ echo "Run check with"; java -jar /opt/lib/checkstyle.jar --version; } | sed ':a;N;s/\n/ /;ba'

# Run checkstyle and reviewdog in two stages so that:
#  1. A hard checkstyle failure (invalid args, exception) is detected and surfaced.
#  2. Normal violations (exit code = ERROR-level count) are forwarded to reviewdog
#     which controls the final exit code via its fail-level setting.
cs_output="$(mktemp)"
trap 'rm -f "$cs_output"' EXIT

java -jar /opt/lib/checkstyle.jar "${INPUT_WORKDIR}" -c "${INPUT_CHECKSTYLE_CONFIG}" "$@" -f xml \
  > "$cs_output" || cs_exit=$?
cs_exit=${cs_exit:-0}

# Checkstyle exits with the number of ERROR-level violations on success.
# Non-zero special exit codes are:
#   255 (-1) invalid arguments
#   254 (-2) internal CheckstyleException
# Treat only these as hard failures; all other non-zero codes (including large
# error counts) are passed through to reviewdog.
if [ "$cs_exit" -eq 255 ] || [ "$cs_exit" -eq 254 ]; then
  echo "Checkstyle failed with exit code ${cs_exit}" >&2
  exit "$cs_exit"
fi

# Feed checkstyle XML output into reviewdog; its exit code respects fail-level
# shellcheck disable=SC2086
reviewdog -f=checkstyle \
    -name="checkstyle" \
    -reporter="${INPUT_REPORTER:-github-pr-check}" \
    -filter-mode="${INPUT_FILTER_MODE:-added}" \
    -fail-level="${INPUT_FAIL_LEVEL:-none}" \
    -level="${INPUT_LEVEL}" \
    ${INPUT_REVIEWDOG_FLAGS} < "$cs_output" || rd_exit=$?
rd_exit=${rd_exit:-0}

echo '::endgroup::'
exit "$rd_exit"
