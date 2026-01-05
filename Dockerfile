FROM eclipse-temurin:25.0.1_8-jre-alpine@sha256:b51543f89580c1ba70e441cfbc0cfc1635c3c16d2e2d77fec9d890342a3a8687

ENV REVIEWDOG_VERSION=v0.21.0
ENV CHECKSTYLE_VERSION=12.3.0

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# hadolint ignore=DL3018
RUN apk --no-cache add curl git wget

# pre-install reviewdog and checkstyle
RUN wget -4 -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION} && \
    mkdir -p /opt/lib && \
    wget -4 -q -O /opt/lib/checkstyle.jar https://github.com/checkstyle/checkstyle/releases/download/checkstyle-${CHECKSTYLE_VERSION}/checkstyle-${CHECKSTYLE_VERSION}-all.jar

# create non-root user
RUN addgroup -S actionuser && adduser -S actionuser -G actionuser

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown actionuser:actionuser /entrypoint.sh

USER actionuser

ENTRYPOINT ["/entrypoint.sh"]
