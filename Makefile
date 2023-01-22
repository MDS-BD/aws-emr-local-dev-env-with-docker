.PHONY: build-spark

build-spark:
	docker build -t mediaset-spark-aws-glue-demo-builder .
	docker run -v $$(pwd)/dist:/dist -v $$(pwd)/scripts/build-spark.sh:/build-spark.sh -v $$(pwd)/conf:/conf mediaset-spark-aws-glue-demo-builder bash build-spark.sh

build-dev-env:
	docker build -t mediaset-spark-aws-glue-demo:python3.8-spark3.1.2 -f Dockerfile.dev .