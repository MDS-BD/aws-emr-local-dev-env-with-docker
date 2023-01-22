#!/bin/bash

set -ex

SPARK_VERSION=3.1.2
HIVE_VERSION=2.3.7
HADOOP_VERSION=3.3.0

cd /opt

# BUILD HIVE
git clone -b rel/release-$HIVE_VERSION --single-branch https://github.com/apache/hive.git /opt/hive
cd /opt/hive
wget https://issues.apache.org/jira/secure/attachment/12958418/HIVE-12679.branch-2.3.patch
# PATCH HIVE
patch -p0 <HIVE-12679.branch-2.3.patch
mvn clean install -DskipTests=true

# BUILD AWS GLUE DATA CATALOG CLIENT
cd /opt
git clone https://github.com/bbenzikry/aws-glue-data-catalog-client-for-apache-hive-metastore catalog

# BUILD GLUE HIVE CLIENT JARS
cd /opt/catalog
mvn clean package -DskipTests -pl -aws-glue-datacatalog-hive2-client

# BUILD SPARK
cd /opt
git clone https://github.com/apache/spark.git spark
cd /opt/spark
git checkout "tags/v${SPARK_VERSION}" -b "v${SPARK_VERSION}"
./dev/make-distribution.sh --name spark-patched --pip -Phive -Phive-thriftserver -Phadoop-provided -Dhadoop.version="${HADOOP_VERSION}"

cd /opt/spark/dist
cp /conf/* conf
find /opt/catalog -name "*.jar" | grep -Ev "test|original" | xargs -I{} cp {} /opt/spark/dist/jars
DIRNAME=spark-${SPARK_VERSION}-bin-hadoop-${HADOOP_VERSION}-glue

cd /opt/spark
mv /opt/spark/dist /opt/spark/$DIRNAME
cd /opt/spark && tar -cvzf $DIRNAME.tgz $DIRNAME
mv $DIRNAME.tgz /dist