FROM eclipse-temurin:21.0.5_11-jre-alpine@sha256:2a0bbb1db6d8db42c66ed00c43d954cf458066cc37be12b55144781da7864fdf

ENV REVIEWDOG_VERSION=v0.20.3
ENV CHECKSTYLE_VERSION=10.21.0

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# hadolint ignore=DL3018
RUN apk --no-cache add curl git wget

# pre-install reviewdog and checkstyle
RUN wget -4 -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION} && \
    mkdir -p /opt/lib && \
    wget -4 -q -O /opt/lib/checkstyle.jar https://github.com/checkstyle/checkstyle/releases/download/checkstyle-${CHECKSTYLE_VERSION}/checkstyle-${CHECKSTYLE_VERSION}-all.jar

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
