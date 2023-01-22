FROM python:3.7-slim-buster

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git && \
    apt-get install -y build-essential && \
    apt-get install wget

# INSTALL PACKAGES
RUN apt install -y wget gnupg software-properties-common
RUN wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add -
RUN add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/
RUN apt update -y
RUN apt install adoptopenjdk-8-hotspot -y

# INSTALL MAVEN
ENV MAVEN_VERSION=3.6.3
RUN cd /opt \
&&  wget https://downloads.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
&&  tar zxvf /opt/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
&&  rm apache-maven-${MAVEN_VERSION}-bin.tar.gz
ENV PATH=/opt/apache-maven-$MAVEN_VERSION/bin:$PATH
