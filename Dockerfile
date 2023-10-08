FROM eclipse-temurin:17.0.8_7-jre-alpine

ENV REVIEWDOG_VERSION=v0.15.0

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# hadolint ignore=DL4006
RUN apk --no-cache add git

# hadolint ignore=DL4006
RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh| sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION}

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
