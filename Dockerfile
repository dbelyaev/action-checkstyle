FROM eclipse-temurin:21-jre-alpine

ENV REVIEWDOG_VERSION v0.17.0
ENV CHECKSTYLE_VERSION 10.12.7

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# hadolint ignore=DL4006
RUN apk --no-cache add git

# pre-install reviewdog and checkstyle
# hadolint ignore=DL4006
RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION} && \
    mkdir -p /opt/lib && \
    wget -q -O /opt/lib/checkstyle.jar https://github.com/checkstyle/checkstyle/releases/download/checkstyle-${CHECKSTYLE_VERSION}/checkstyle-${CHECKSTYLE_VERSION}-all.jar

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
