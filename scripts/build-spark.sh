#!/bin/bash
set -ex

SPARK_VERSION=2.4.5
HADOOP_VERSION=2.8.5
HIVE_VERSION=1.2.1
AWS_SDK_VERSION=1.11.682

# BUILD HIVE FOR HIVE v1 - needed for spark client
git clone -b release-$HIVE_VERSION --single-branch https://github.com/apache/hive.git /opt/hive
cd /opt/hive
wget https://issues.apache.org/jira/secure/attachment/12958417/HIVE-12679.branch-1.2.patch
patch -p0 <HIVE-12679.branch-1.2.patch
mvn clean install -DskipTests=true -Phadoop-2

# Related to this issue https://github.com/awslabs/aws-glue-data-catalog-client-for-apache-hive-metastore/pull/14
mkdir -p ~/.m2/repository/org/spark-project
cp -r ~/.m2/repository/org/apache/hive ~/.m2/repository/org/spark-project

# BUILD AWS GLUE DATA CATALOG CLIENT
git clone -b branch-1.10.0 https://github.com/awslabs/aws-glue-data-catalog-client-for-apache-hive-metastore.git /opt/glue
cd /opt/glue
git checkout 83e728b47655a8592efe6441213da1c8a608f18a
sed -i '/<packaging>pom<\/packaging>/a <dependencies><dependency><groupId>org.apache.hadoop<\/groupId><artifactId>hadoop-common<\/artifactId><version>${hadoop.version}<\/version><scope>provided<\/scope><\/dependency><\/dependencies>' shims/pom.xml
mvn clean package -DskipTests=true -pl -aws-glue-datacatalog-hive2-client

# SPARK DISTRIBUTION
export MAVEN_OPTS="-Xmx2g -XX:ReservedCodeCacheSize=1g"
git clone -b v$SPARK_VERSION --single-branch https://github.com/apache/spark.git /opt/spark
cd /opt/spark
./dev/make-distribution.sh --name my-custom-spark --pip -Phadoop-${HADOOP_VERSION%.*} -Phive -Dhadoop.version=$HADOOP_VERSION -Dhive.version=$HIVE_VERSION 

# ADD MISSING & BUILT JARS TO SPARK CLASSPATHS + CONFIG
cd /opt/spark/dist

# Copy missing deps
mvn dependency:get -Dartifact=asm:asm:3.2
mvn dependency:get -Dartifact=net.minidev:json-smart:1.3.1
find /opt/glue -name "*.jar" -exec cp {} jars \;

# Copy AWS jars
echo :quit | ./bin/spark-shell --conf spark.jars.packages=com.amazonaws:aws-java-sdk:$AWS_SDK_VERSION,org.apache.hadoop:hadoop-aws:$HADOOP_VERSION
cp /root/.ivy2/jars/*.jar jars
rm -rf jars/io.netty*

# Create archive
DIRNAME=spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION%.*}-glue
mv /opt/spark/dist /opt/spark/$DIRNAME
cd /opt/spark && tar -cvzf $DIRNAME.tgz $DIRNAME
mv $DIRNAME.tgz /dist
