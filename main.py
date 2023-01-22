from pyspark.sql import SparkSession
import subprocess

# If you need to run the Spark history server
rc = subprocess.call("/opt/spark/sbin/start-history-server.sh")

spark = SparkSession.\
    builder.enableHiveSupport() \
    .config("spark.sql.shuffle.partitions", 150)\
    .getOrCreate()

spark.sql("show databases").show()
