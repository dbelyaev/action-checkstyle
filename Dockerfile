FROM eclipse-temurin:25.0.3_9-jre-alpine@sha256:c707c0d18cb9e8556380719f80d96a7529d0746fbb42143893949b98ed2f8943

ENV REVIEWDOG_VERSION=v0.21.0
ENV CHECKSTYLE_VERSION=13.9.0
# sha256 of checkstyle-${CHECKSTYLE_VERSION}-all.jar.
# Kept in step with CHECKSTYLE_VERSION by scripts/update-checkstyle-checksum.sh,
# which the depup workflow runs when it bumps the version.
ENV CHECKSTYLE_SHA256=4aa042449984e3f2ea670b039e39b29e116a037e823c32f59b84d04739a8a94c

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# Single RUN: packages, downloads and the runtime user in one layer.
# Splitting them buys no build-cache benefit here anyway - the ENV lines above
# are what change, and they invalidate everything below regardless.
#
# curl rather than wget: it is the only one of the two that can pin the scheme
# across redirects (--proto/--proto-redir). Both downloads below are redirected
# by GitHub, so following them without that guarantee would allow a downgrade
# to plain http. curl is also what the reviewdog install script prefers.
#
# Install script is pinned by commit SHA for supply-chain safety;
# the binary version is controlled separately via REVIEWDOG_VERSION.
# -4 forces IPv4 to avoid IPv6 routing issues on GitHub Actions runners.
# hadolint ignore=DL3018
RUN apk --no-cache add git su-exec curl && \
    curl -4 -fsSL --proto '=https' --proto-redir '=https' --retry 3 --connect-timeout 30 \
      -o /tmp/reviewdog_install.sh \
      https://raw.githubusercontent.com/reviewdog/reviewdog/df70ed74df59de7ebfd9276afabd62ea2de4d7dd/install.sh && \
    sh /tmp/reviewdog_install.sh -b /usr/local/bin/ ${REVIEWDOG_VERSION} && \
    rm /tmp/reviewdog_install.sh && \
    mkdir -p /opt/lib && \
    curl -4 -fsSL --proto '=https' --proto-redir '=https' --retry 3 --connect-timeout 30 \
      -o /opt/lib/checkstyle.jar \
      https://github.com/checkstyle/checkstyle/releases/download/checkstyle-${CHECKSTYLE_VERSION}/checkstyle-${CHECKSTYLE_VERSION}-all.jar && \
    echo "${CHECKSTYLE_SHA256}  /opt/lib/checkstyle.jar" | sha256sum -c - && \
    addgroup -S checkstyle && adduser -S checkstyle -G checkstyle && \
    mkdir -p /home/checkstyle && \
    chown -R checkstyle:checkstyle /home/checkstyle /opt/lib

ENV HOME=/home/checkstyle

COPY entrypoint.sh /entrypoint.sh

# root required at start; entrypoint drops to non-root via su-exec after detecting workspace owner UID.
# hadolint ignore=DL3002
ENTRYPOINT ["/entrypoint.sh"]
