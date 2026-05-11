@echo off
echo Listing all Kafka topics...
REM Replace kafka if CONTAINER_NAME is diffrent use docker ps
docker exec -it kafka kafka-topics --list --bootstrap-server localhost:9092