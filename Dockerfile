FROM python:3.8-slim-buster

ENV HADOOP_VERSION=3.3.0

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git && \
    apt-get install -y build-essential && \
    apt-get install wget && \
    apt-get install -y procps

# INSTALL PACKAGES
RUN apt install -y gnupg software-properties-common
RUN wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add -
RUN add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/
RUN apt update -y
RUN apt install adoptopenjdk-8-hotspot -y

# INSTALL MAVEN
# maven
ENV MAVEN_VERSION=3.6.3
ENV PATH=/opt/apache-maven-$MAVEN_VERSION/bin:$PATH
ENV MAVEN_HOME /opt/apache-maven-${MAVEN_VERSION}

RUN cd /opt \
  &&  wget https://downloads.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  &&  tar zxvf /opt/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  &&  rm apache-maven-${MAVEN_VERSION}-bin.tar.gz

# INSTALL HADOOP
WORKDIR /opt/hadoop
ENV HADOOP_HOME=/opt/hadoop
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz
RUN tar -xzvf hadoop-${HADOOP_VERSION}.tar.gz
ARG HADOOP_WITH_VERSION=hadoop-${HADOOP_VERSION}
ENV SPARK_DIST_CLASSPATH=$HADOOP_HOME/$HADOOP_WITH_VERSION/etc/hadoop/*:$HADOOP_HOME/$HADOOP_WITH_VERSION/share/hadoop/common/lib/*:$HADOOP_HOME/$HADOOP_WITH_VERSION/share/hadoop/common/*:$HADOOP_HOME/$HADOOP_WITH_VERSION/share/hadoop/hdfs/*:$HADOOP_HOME/$HADOOP_WITH_VERSION/share/hadoop/hdfs/lib/*:$HADOOP_HOME/$HADOOP_WITH_VERSION/share/hadoop/hdfs/*:$HADOOP_HOME/$HADOOP_WITH_VERSION/share/hadoop/yarn/lib/*:$HADOOP_HOME/$HADOOP_WITH_VERSION/share/hadoop/yarn/*:$HADOOP_HOME/$HADOOP_WITH_VERSION/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/$HADOOP_WITH_VERSION/share/hadoop/mapreduce/*:$HADOOP_HOME/$HADOOP_WITH_VERSION/share/hadoop/tools/lib/*
RUN rm -rf hadoop-${HADOOP_VERSION}.tar.gz

WORKDIR /