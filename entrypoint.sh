#!/bin/sh

command -v reviewdog >/dev/null 2>&1 || { echo >&2 "reviewdog: not found"; exit 1; }

set -e

if [ -n "${GITHUB_WORKSPACE}" ] ; then
  cd "${GITHUB_WORKSPACE}" || exit
fi

if [ -n "${INPUT_PROPERTIES_FILE}" ]; then
  OPT_PROPERTIES_FILE="-p ${INPUT_PROPERTIES_FILE}"
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

printenv
ls

# fetch checkstyle of a requested version
echo "Download Checkstyle v${INPUT_CHECKSTYLE_VERSION}"
wget -O - -q "https://github.com/checkstyle/checkstyle/releases/download/checkstyle-${INPUT_CHECKSTYLE_VERSION}/checkstyle-${INPUT_CHECKSTYLE_VERSION}-all.jar" > /checkstyle.jar

echo "Run Checkstyle check"
exec java -jar /checkstyle.jar "${INPUT_WORKDIR}" -c "${INPUT_CHECKSTYLE_CONFIG}" ${OPT_PROPERTIES_FILE} -f xml \
  | reviewdog -f=checkstyle \
      -name="checkstyle" \
      -reporter="${INPUT_REPORTER:-github-pr-check}" \
      -filter-mode="${INPUT_FILTER_MODE:-added}" \
      -fail-on-error="${INPUT_FAIL_ON_ERROR:-false}" \
      -level="${INPUT_LEVEL}" \
      ${INPUT_REVIEWDOG_FLAGS}
