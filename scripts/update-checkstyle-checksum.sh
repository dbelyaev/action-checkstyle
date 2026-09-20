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

# One temp directory rather than two mktemp calls, so there is a single
# acquisition to guard and the trap can be armed immediately after it - with
# two, a failure of the second call leaked the file from the first. The
# template is spelled out because BSD mktemp documents one as required; `-t`
# is not the portable shorthand it looks like, since GNU reads it as a
# directory and BSD as a filename prefix.
tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/checkstyle-checksum.XXXXXXXXXX")"
trap 'rm -rf "$tmpdir"' EXIT
tmp="$tmpdir/checkstyle.jar"
tmp_dockerfile="$tmpdir/Dockerfile"

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

# sha256sum reached macOS only recently (/sbin/sha256sum), while shasum has
# shipped with every release; try sha256sum first so CI keeps using the binary
# it uses today. Both print "<hex>  <path>", so one trim serves either.
if command -v sha256sum >/dev/null 2>&1; then
  sha="$(sha256sum "$tmp")"
else
  sha="$(shasum -a 256 "$tmp")"
fi
sha="${sha%% *}"
echo "checkstyle ${version} sha256=${sha}"

sed "s|^ENV CHECKSTYLE_SHA256=.*|ENV CHECKSTYLE_SHA256=${sha}|" "$dockerfile" > "$tmp_dockerfile"
# Copy the contents back rather than `mv` the temp file over the Dockerfile:
# mv replaces the inode, taking the mode, the owner and any symlink with it,
# whereas cat writes through the existing file and preserves all three.
cat "$tmp_dockerfile" > "$dockerfile"

grep -n '^ENV CHECKSTYLE_\(VERSION\|SHA256\)=' "$dockerfile"
