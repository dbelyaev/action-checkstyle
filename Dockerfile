# Pinned by BOTH tag and digest, deliberately. The digest is what Docker
# enforces; the tag is what tells Renovate which release line to follow and
# what makes an update PR readable ("update ... tag to v25.0.3_9-jre-alpine"
# rather than an opaque hex change). Dropping the tag would leave Renovate
# tracking `latest` by default - silently drifting off the pinned JRE 25
# Alpine line, which is the opposite of what pinning is for.
#
# SonarQube docker:S8431 flags this combination; it is accepted here for the
# reasons above. Please do not "simplify" this line.
FROM eclipse-temurin:25.0.3_9-jre-alpine@sha256:28db6fdf60e38945e43d840c0333aeaec66c15943070104f7586fd3c9d1665b0

ENV REVIEWDOG_VERSION=v0.21.0
ENV CHECKSTYLE_VERSION=14.0.0
# sha256 of checkstyle-${CHECKSTYLE_VERSION}-all.jar.
# Kept in step with CHECKSTYLE_VERSION by scripts/update-checkstyle-checksum.sh,
# which the depup workflow runs when it bumps the version.
ENV CHECKSTYLE_SHA256=f3845df27df6a03e0b533fcc10bd5e4beab495b7a0d21c36b43ef243f6bf678f

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
