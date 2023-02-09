#!/usr/bin/env bash

read -r -p "Are you sure to install mysql? [Y/N] " input

case $input in
    [yY][eE][sS]|[yY])
		echo "Installing mysql..."
    # deploy mysql
    docker run -d --name cudgx_db -e MYSQL_ROOT_PASSWORD=mtQ8chN2 -e MYSQL_DATABASE=cudgx -e MYSQL_USER=gf -e MYSQL_PASSWORD=db@galaxy-future.com -p 3336:3306 -v $(pwd)/init/mysql:/docker-entrypoint-initdb.d yobasystems/alpine-mariadb:10.5.11
		;;

    [nN][oO]|[nN])
		echo "Skip mysql install, please check conf/config.yml mysql config, and import init/mysql/* to existing mysql for first install."
    ;;
    *)
		echo "Invalid input..."
		exit 1
		;;
esac

read -r -p "Are you sure to install kafka? [Y/N] " input

case $input in
    [yY][eE][sS]|[yY])
		echo "Installing kafka..."
    # deploy kafka
    docker run -d --name zookeeper --publish 2181:2181 --volume /etc/localtime:/etc/localtime wurstmeister/zookeeper

    docker run -d --name kafka --publish 9092:9092 --link zookeeper --env KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 --env KAFKA_ADVERTISED_HOST_NAME=127.0.0.1 --env KAFKA_ADVERTISED_PORT=9092 --volume /etc/localtime:/etc/localtime wurstmeister/kafka

		;;

    [nN][oO]|[nN])
		echo "Skip kafka install, please check conf/api.json kafka config."
    ;;
    *)
		echo "Invalid input..."
		exit 1
		;;
esac

read -r -p "Are you sure to install clickhouse? [Y/N] " input

case $input in
    [yY][eE][sS]|[yY])
		echo "Installing clickhouse..."
    # deploy clickhouse
    docker run -d --name clickhouse -p 8123:8123 -p 9000:9000 -p 9009:9009 --ulimit nofile=262144:262144 -v $(pwd)/init/clickhouse/quickstart:/docker-entrypoint-initdb.d clickhouse/clickhouse-server
    ;;
    [nN][oO]|[nN])
		echo "Skip clickhouse install, please check conf/api.json clickhouse config."
    ;;
    *)
		echo "Invalid input..."
		exit 1
		;;
esac
# init
#docker exec kafka \
#kafka-topics --bootstrap-server broker:9092 \
#             --create \
#             --topic monitoring_metrics_test
# deploy api
sed "s/127.0.0.1/host.docker.internal/g" $(pwd)/conf/api.json > $(pwd)/conf/api.json.mac
docker run -d --name cudgx_api --add-host host.docker.internal:host-gateway -v $(pwd)/conf/api.json:/home/cudgx/api/conf/api.json galaxyfuture/cudgx-api:latest
# deploy gateway
sed "s/127.0.0.1/host.docker.internal/g" $(pwd)/conf/gateway.json > $(pwd)/conf/gateway.json.mac
docker run -d --name cudgx_gateway --add-host host.docker.internal:host-gateway -v $(pwd)/conf/gateway.json:/home/cudgx/gateway/conf/gateway.json  galaxyfuture/cudgx-gateway:latest
# deploy consumer
sed "s/127.0.0.1/host.docker.internal/g" $(pwd)/conf/consumer.json > $(pwd)/conf/consumer.json.mac
docker run -d --name cudgx_consumer --add-host host.docker.internal:host-gateway -v $(pwd)/conf/consumer.json:/home/cudgx/api/conf/consumer.json galaxyfuture/cudgx-consumer:latest
# deploy pi
# docker run -d --name cudgx_sample_pi --add-host host.docker.internal:host-gateway galaxyfuture/cudgx-sample-pi:latest
# deploy benchmark
# docker run -d --name cudgx_sample_benchmark --add-host host.docker.internal:host-gateway galaxyfuture/cudgx-sample-benchmark:latest
