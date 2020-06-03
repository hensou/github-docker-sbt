# https://hub.docker.com/r/adoptopenjdk/openjdk11
#FROM adoptopenjdk/openjdk8:jdk8u242-b08-alpine-slim
FROM maven:3.6-jdk-8-alpine

LABEL maintainer="matankdr@gmail.com"

RUN set -x \
  && apk --update add --no-cache --virtual .build-deps curl \
  && SBT_VER="1.3.8" \
  && ESUM="27b2ed49758011fefc1bd05e1f4156544d60673e082277186fdd33b6f55d995d" \
  && SBT_URL="https://piccolo.link/sbt-${SBT_VER}.tgz" \
  && apk add shadow \
  && apk add bash \
  && apk add openssh \
  && apk add rsync \
  && apk add git \
  && apk add docker \
  && curl -Ls ${SBT_URL} > /tmp/sbt-${SBT_VER}.tgz \
  && sha256sum /tmp/sbt-${SBT_VER}.tgz \
  && (echo "${ESUM}  /tmp/sbt-${SBT_VER}.tgz" | sha256sum -c -) \
  && mkdir /opt/sbt \
  && tar -zxf /tmp/sbt-${SBT_VER}.tgz -C /opt/sbt \
  && sed -i -r 's#run \"\$\@\"#unset JAVA_TOOL_OPTIONS\nrun \"\$\@\"#g' /opt/sbt/sbt/bin/sbt \
  && apk del --purge .build-deps \
  && rm -rf /tmp/sbt-${SBT_VER}.tgz /var/cache/apk/*

COPY github-credentials.sbt /root/.sbt/1.0/


ADD entrypoint.sh /entrypoint.sh


ENV PATH="/opt/sbt/sbt/bin:$PATH" \
    JAVA_OPTS="-XX:+UseContainerSupport -Dfile.encoding=UTF-8" \
    SBT_OPTS="-Xmx2048M -Xss2M"


#RUN sbt about
ENTRYPOINT ["/entrypoint.sh"]
