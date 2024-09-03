FROM eclipse-temurin:21.0.4_7-jre-alpine@sha256:b16f1192681ea43bd6f5c435a1bf30e59fcbee560ee2c497f42118003f42d804

ENV REVIEWDOG_VERSION v0.20.1
ENV CHECKSTYLE_VERSION 10.18.1

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# hadolint ignore=DL3018
RUN apk --no-cache add curl git wget

# pre-install reviewdog and checkstyle
RUN wget -4 -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION} && \
    mkdir -p /opt/lib && \
    wget -4 -q -O /opt/lib/checkstyle.jar https://github.com/checkstyle/checkstyle/releases/download/checkstyle-${CHECKSTYLE_VERSION}/checkstyle-${CHECKSTYLE_VERSION}-all.jar

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
