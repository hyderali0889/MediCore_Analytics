@echo off
if "%1"=="" (
    echo Usage: describe-topic.bat ^<topic-name^>
    goto :end
)
REM Replace kafka if CONTAINER_NAME is diffrent use docker ps
docker exec -it kafka kafka-topics --describe --topic %1 --bootstrap-server localhost:9092
:end