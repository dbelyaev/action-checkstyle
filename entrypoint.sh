#!/bin/sh
command -v reviewdog >/dev/null 2>&1 || { echo >&2 "reviewdog: not found"; exit 1; }

set -e

# output some information
{ echo "Pre-installed"; java -jar /opt/lib/checkstyle.jar --version; } | sed ':a;N;s/\n/ /;ba'

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
  git config --global --add safe.directory "${GITHUB_WORKSPACE}" || exit 1
fi

# user supplied custom properties file parameter, define it
OPTIONAL_PROPERTIES_FILE=""
if [ -n "${INPUT_PROPERTIES_FILE}" ]; then
  OPTIONAL_PROPERTIES_FILE="-p ${INPUT_PROPERTIES_FILE}"
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

# shellcheck disable=SC2086
exec java -jar /opt/lib/checkstyle.jar "${INPUT_WORKDIR}" -c "${INPUT_CHECKSTYLE_CONFIG}" ${OPTIONAL_PROPERTIES_FILE} -f xml \
  | reviewdog -f=checkstyle \
      -name="checkstyle" \
      -reporter="${INPUT_REPORTER:-github-pr-check}" \
      -filter-mode="${INPUT_FILTER_MODE:-added}" \
      -fail-level="${INPUT_FAIL_LEVEL:-none}" \
      -level="${INPUT_LEVEL}" \
      ${INPUT_REVIEWDOG_FLAGS}

echo '::endgroup::'
