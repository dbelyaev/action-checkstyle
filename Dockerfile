FROM eclipse-temurin:25.0.2_10-jre-alpine@sha256:f10d6259d0798c1e12179b6bf3b63cea0d6843f7b09c9f9c9c422c50e44379ec

ENV REVIEWDOG_VERSION=v0.21.0
ENV CHECKSTYLE_VERSION=13.3.0

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# hadolint ignore=DL3018
RUN apk --no-cache add git wget

# Pin install script to the v0.21.0 tag commit to prevent supply chain attacks
# via a compromised master-branch install.sh (binary version is still controlled
# by REVIEWDOG_VERSION).
# pre-install reviewdog and checkstyle
RUN wget -4 -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/df70ed74df59de7ebfd9276afabd62ea2de4d7dd/install.sh | sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION} && \
    mkdir -p /opt/lib && \
    wget -4 -q -O /opt/lib/checkstyle.jar https://github.com/checkstyle/checkstyle/releases/download/checkstyle-${CHECKSTYLE_VERSION}/checkstyle-${CHECKSTYLE_VERSION}-all.jar

# Create a non-root user to run the container (Trivy DS-0002)
RUN addgroup -S checkstyle && adduser -S checkstyle -G checkstyle && \
    mkdir -p /home/checkstyle && \
    chown -R checkstyle:checkstyle /home/checkstyle /opt/lib

ENV HOME=/home/checkstyle

COPY entrypoint.sh /entrypoint.sh

USER checkstyle

ENTRYPOINT ["/entrypoint.sh"]
