from pyspark.sql import SparkSession

spark = SparkSession.\
    builder.enableHiveSupport() \
    .config("spark.sql.shuffle.partitions", 150)\
    .getOrCreate()

spark.sql("show databases").show()
