FROM openjdk:8-alpine

ENV REVIEWDOG_VERSION=v0.10.1

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# hadolint ignore=DL3006
RUN apk --no-cache add git

RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh| sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION}

# install checkstyle
RUN wget -O - -q https://github.com/checkstyle/checkstyle/releases/download/checkstyle-8.34/checkstyle-8.34-all.jar > /checkstyle.jar

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
