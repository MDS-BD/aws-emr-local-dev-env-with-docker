.PHONY: build-spark
build-spark:
	docker build --no-cache -t mediaset-spark-aws-glue-demo-builder .
	docker run -v $$(pwd)/dist:/dist -v $$(pwd)/scripts/build-spark.sh:/build-spark.sh  mediaset-spark-aws-glue-demo-builder bash build-spark.sh
build-dev-env:
	docker build -t mediaset-spark-aws-glue-demo -f Dockerfile.dev .