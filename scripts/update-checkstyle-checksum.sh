#!/usr/bin/env bash
#
# Recomputes CHECKSTYLE_SHA256 in the Dockerfile to match CHECKSTYLE_VERSION.
#
# The depup workflow bumps CHECKSTYLE_VERSION automatically; this keeps the
# pinned checksum in step, so the version bump does not have to choose between
# a broken build and an unverified download. Run it manually after editing the
# version by hand:
#
#   bash scripts/update-checkstyle-checksum.sh
#
set -euo pipefail

dockerfile="$(dirname "$0")/../Dockerfile"

# sed rather than `grep -oP`: -P is a GNU extension and BSD grep (macOS) exits
# 2 on it, so the by-hand run the usage note above invites did not work there.
# It also makes the emptiness check below reachable: under `set -e` a
# non-matching grep aborts the assignment outright, whereas sed exits 0.
version="$(sed -n 's/^ENV CHECKSTYLE_VERSION=//p' "$dockerfile")"
if [[ -z "$version" ]]; then
  echo "could not read CHECKSTYLE_VERSION from $dockerfile" >&2
  exit 1
fi

url="https://github.com/checkstyle/checkstyle/releases/download/checkstyle-${version}/checkstyle-${version}-all.jar"
tmp="$(mktemp)"
tmp_dockerfile="$(mktemp)"
trap 'rm -f "$tmp" "$tmp_dockerfile"' EXIT

echo "Fetching ${url}"
# --proto/--proto-redir pin the scheme to HTTPS for the initial request AND for
# every redirect. -L is required (GitHub redirects release downloads to
# release-assets.githubusercontent.com), and without these flags curl follows a
# redirect to plain http - letting whoever can influence that hop supply the
# JAR whose checksum we are about to bless as the pinned value.
curl -fsSL --proto '=https' --proto-redir '=https' --retry 3 --max-time 300 -o "$tmp" "$url"

# Guard against a 404 page or a truncated download being hashed happily.
if ! unzip -qql "$tmp" >/dev/null 2>&1; then
  echo "downloaded file is not a valid JAR/zip archive" >&2
  exit 1
fi

sha="$(sha256sum "$tmp" | cut -d' ' -f1)"
echo "checkstyle ${version} sha256=${sha}"

sed "s|^ENV CHECKSTYLE_SHA256=.*|ENV CHECKSTYLE_SHA256=${sha}|" "$dockerfile" > "$tmp_dockerfile"
# Copy the contents back rather than `mv` the temp file over the Dockerfile:
# mktemp creates 0600, and mv would carry that mode across, silently tightening
# the working copy. Git does not track the bit, so CI never noticed.
cat "$tmp_dockerfile" > "$dockerfile"

grep -n '^ENV CHECKSTYLE_\(VERSION\|SHA256\)=' "$dockerfile"
