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

version="$(grep -oP '^ENV CHECKSTYLE_VERSION=\K.*' "$dockerfile")"
if [[ -z "$version" ]]; then
  echo "could not read CHECKSTYLE_VERSION from $dockerfile" >&2
  exit 1
fi

url="https://github.com/checkstyle/checkstyle/releases/download/checkstyle-${version}/checkstyle-${version}-all.jar"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

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

tmp_dockerfile="$(mktemp)"
sed "s|^ENV CHECKSTYLE_SHA256=.*|ENV CHECKSTYLE_SHA256=${sha}|" "$dockerfile" > "$tmp_dockerfile"
mv "$tmp_dockerfile" "$dockerfile"

grep -n '^ENV CHECKSTYLE_\(VERSION\|SHA256\)=' "$dockerfile"
