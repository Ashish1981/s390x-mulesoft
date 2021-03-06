FROM docker.io/ibmjava:11-jdk

# Define environment variables.
ENV BUILD_DATE="$(date +%Y%m%d)"
ENV MULE_HOME=/opt/mule
ENV MULE_VERSION=4.3.0-20210119
ENV MULE_MD5=0859dad4a6dd992361d34837658e517d
ENV TINI_SUBREAPER=
ENV TZ="Asia/Kolkata"
# SSL Cert for downloading mule zip

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get -y update && apt-get full-upgrade -y \
    && apt-get install -y --no-install-recommends tzdata ca-certificates openssl \
    && ln -fs /usr/share/zoneinfo/Asia/Kolkata /etc/localtime \ 
    && dpkg-reconfigure -f noninteractive tzdata \
    && rm -rf /var/cache/apk/*

RUN useradd -u 1000 -U mule -d /opt/mule

RUN mkdir /opt/mule-standalone-${MULE_VERSION} && \
    ln -s /opt/mule-standalone-${MULE_VERSION} ${MULE_HOME} && \
    chown mule:mule -R /opt/mule*

RUN echo ${TZ} > /etc/timezone

USER mule

# For checksum, alpine linux needs two spaces between checksum and file name
RUN cd ~ && wget https://repository-master.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/${MULE_VERSION}/mule-standalone-${MULE_VERSION}.tar.gz && \
    echo "${MULE_MD5}  mule-standalone-${MULE_VERSION}.tar.gz" | md5sum -c && \
    cd /opt && \ 
    tar xvzf ~/mule-standalone-${MULE_VERSION}.tar.gz && \
    rm ~/mule-standalone-${MULE_VERSION}.tar.gz

# Define mount points.
VOLUME ["${MULE_HOME}/logs", "${MULE_HOME}/conf", "${MULE_HOME}/apps", "${MULE_HOME}/domains"]

# Define working directory.
WORKDIR ${MULE_HOME}

CMD [ "/opt/mule/bin/mule"]

# Default http port
EXPOSE 8081
