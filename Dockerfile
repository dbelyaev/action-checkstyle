FROM eclipse-temurin:25.0.3_9-jre-alpine@sha256:c707c0d18cb9e8556380719f80d96a7529d0746fbb42143893949b98ed2f8943

ENV REVIEWDOG_VERSION=v0.21.0
ENV CHECKSTYLE_VERSION=13.4.0

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# hadolint ignore=DL3018
RUN apk --no-cache add git su-exec wget

# Pre-install reviewdog and checkstyle.
# Install script is pinned by commit SHA for supply-chain safety;
# the binary version is controlled separately via REVIEWDOG_VERSION.
# -4 forces IPv4 to avoid IPv6 routing issues on GitHub Actions runners.
RUN wget -4 -q -O /tmp/reviewdog_install.sh https://raw.githubusercontent.com/reviewdog/reviewdog/df70ed74df59de7ebfd9276afabd62ea2de4d7dd/install.sh && \
    sh /tmp/reviewdog_install.sh -b /usr/local/bin/ ${REVIEWDOG_VERSION} && \
    rm /tmp/reviewdog_install.sh && \
    mkdir -p /opt/lib && \
    wget -4 -q -O /opt/lib/checkstyle.jar https://github.com/checkstyle/checkstyle/releases/download/checkstyle-${CHECKSTYLE_VERSION}/checkstyle-${CHECKSTYLE_VERSION}-all.jar

# Create a non-root user to run the container (Trivy DS-0002)
RUN addgroup -S checkstyle && adduser -S checkstyle -G checkstyle && \
    mkdir -p /home/checkstyle && \
    chown -R checkstyle:checkstyle /home/checkstyle /opt/lib

ENV HOME=/home/checkstyle

COPY entrypoint.sh /entrypoint.sh

# root required at start; entrypoint drops to non-root via su-exec after detecting workspace owner UID.
# hadolint ignore=DL3002
ENTRYPOINT ["/entrypoint.sh"]
