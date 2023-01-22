# aws-emr-local-dev-env-with-docker

Following the steps listed in this repository you can build a Docker image which
simulates a cluster EMR used for ETL tasks by Mediaset Business Digital.
The main feature of the built image is the ability to use AWS Glue Data Catalog as a Hive Metastore.

The final Docker image contains:
- Python 3.7
- Spark 2.4.5
- Hadoop 2.8
- Hive 1.2.1
- AWS SDK 1.11.682


## Build docker image

**Before to start**: install [Docker](https://docs.docker.com/).

**Important note**: if you are a MacOS user go to the _Docker preferences_, then select _Resources_, and under 
_Advance_ section increase RAM to (at least) 4GB.

1) build the docker image `mediaset-spark-aws-glue-demo-builder`. When the build is completed you will find a Spark bundle artifact in `./dist` directory.
  
   ```shell
   make build-spark
   ```

2) build the final dev environment docker image called `mediaset-spark-aws-glue-demo:python3.7-spark2.4.5`

   ```shell
   make build-dev-env
   ```

3) Before to use the image, configure the Glue Data Catalog adding 
`YOUR_AWS_ACCOUNT_ID` in the [./conf/hive-site.xml](conf/hive-site.xml) file:

   ```xml
   <property>
     <name>hive.metastore.glue.catalogid</name>
     <value>YOUR_AWS_ACCOUNT_ID</value>
   </property>
   ```

Now you are ready to locally develop spark jobs querying Glue Data Catalogs 
using the docker image `mediaset-spark-aws-glue-demo:python3.7-spark2.4.5`.

## Testing

1) Launch a standalone docker container, after setting the correct AWS credentials.
   (Add also `-e AWS_SESSION_TOKEN=YOUR_AWS_SESSION_TOKEN` if you need to set a specific role).

   ```shell
   docker run -it --rm \
   -p 4040:4040 \
   -v /PROJECT_PATH/conf/hive-site.xml:/opt/spark/conf/hive-site.xml \
   -e AWS_ACCESS_KEY_ID=YOUR_AWS_ACCESS_KEY \
   -e AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET_KEY \
   --name spark-env \
   mediaset-spark-aws-glue-demo:python3.7-spark2.4.5 \
   bash
   ```

2) Open the spark shell to verify the ability to connect to the Glue Data Catalog

   ```python
   # pyspark
   >>> spark.sql("show databases").show()
   >>> spark.sql("show tables in DB_NAME").show()
   ```

3) Open a Web Browser on [http://localhost:4040](http://localhost:4040) while keeping pyspark running to check the Spark Web UI.

## Configuration

### PyCharm setup

1. Open PyCharm Professional and import the Project.
2. Under File, choose `Settings...` (for Mac, under PyCharm, choose Preferences)
3. Under Settings, choose Project Interpreter. Click the gear icon, choose `Show All..` from the drop-down menu.
4. Choose the `+` icon and create a new Docker interpreter selecting the image `mediaset-spark-aws-glue-demo:python3.7-spark2.4.5` and press `OK`.
5. Edit the `Run/Debug Configurations` of the project to properly launch the docker image
6. Insert the `Script path` selecting the path of the module `main.py` contained in the project.
7. In `Environment Variables` add `AWS_ACCESS_KEY_ID=YOUR_AWS_ACCESS_KEY;AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET_KEY`.
   1. Add also `AWS_SESSION_TOKEN=YOUR_AWS_SESSION_TOKEN` if you need to set a specific role.
8. In `Docker container settings` add the following keys in the `Volume bindings` section, replacing PROJECT_PATH with the project location on your computer:

   | Host path                           | Container path                   |
   |-------------------------------------|----------------------------------|
   | /PROJECT_PATH/spark-events          | /tmp/spark-events                |
   | /PROJECT_PATH/conf/log4j.properties | /opt/spark/conf/log4j.properties |
   | /PROJECT_PATH/conf/hive-site.xml    | /opt/spark/conf/hive-site.xml    |

   **Note**: To dynamically configure a different Glue Data Catalog without re-compiling
   the docker image, update the following section in the [./conf/hive-site.xml](conf/hive-site.xml) within the project folder:

   ```xml
   <property>
     <name>hive.metastore.glue.catalogid</name>
     <value>YOUR_AWS_ACCOUNT_ID</value>
   </property>
   ```

9. Press `Run` button.
10. The Run console will show you the output of the `main.py` module which should list the databases available on the provided Glue Data Catalog.


### Spark Log4j
The level of the loggers displayed in the PyCharm console can be controlled by modifying the `conf/log4j.properties` file in your project folder.

### Spark History Server
Each job launched in the docker image, will store the relative Spark Event logs in the `/tmp/spark-events` on the docker image.
You can bind this location on the host computer to persist the Spark logs to later review them with the Spark History Server.

To launch a persistent Spark History Server able to read all the Spark Event Logs generated,
you should launch an independent docker container with the following command (replace PROJECT_PATH with the path on your local computer):

```shell
docker run -it --rm \
-p 18080:18080 \
-v /PROJECT_PATH/spark-events:/tmp/spark-events \
--name spark-history \
mediaset-spark-aws-glue-demo:python3.7-spark2.4.5
```

Open a Web Browser at the following address [http://localhost:18080](http://localhost:18080) to see all the Spark logs generated.

## References

1) [aws-glue-data-catalog-client-for-apache-hive-metastore](https://github.com/awslabs/aws-glue-data-catalog-client-for-apache-hive-metastore)
2) [tinyclues/spark-glue-data-catalog](https://github.com/tinyclues/spark-glue-data-catalog)
