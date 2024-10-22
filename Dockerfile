FROM eclipse-temurin:21.0.4_7-jre-alpine@sha256:848653d62f2fe03f2ef6d0527236fbdedd296ee44bfeb7a9836662dc2f0f58d3

ENV REVIEWDOG_VERSION=v0.20.2
ENV CHECKSTYLE_VERSION=10.18.2

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# hadolint ignore=DL3018
RUN apk --no-cache add curl git wget

# pre-install reviewdog and checkstyle
RUN wget -4 -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION} && \
    mkdir -p /opt/lib && \
    wget -4 -q -O /opt/lib/checkstyle.jar https://github.com/checkstyle/checkstyle/releases/download/checkstyle-${CHECKSTYLE_VERSION}/checkstyle-${CHECKSTYLE_VERSION}-all.jar

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
