@echo off
echo ========================================
echo    Kafka Topic Creator (Docker)
echo ========================================
REM Replace CONTAINER_NAME if it's diffrent 
set CONTAINER_NAME=kafka
set BOOTSTRAP_SERVER=localhost:9092

if "%1"=="" (
    echo Usage: create-topic.bat ^<topic-name^> [partitions] [replication]
    echo Example: create-topic.bat patient-admissions 3 1
    goto :end
)

set TOPIC=%1
set PARTITIONS=%2
set REPLICATION=%3

if "%PARTITIONS%"=="" set PARTITIONS=3
if "%REPLICATION%"=="" set REPLICATION=1

echo Creating topic: %TOPIC%
echo Partitions: %PARTITIONS%   Replication: %REPLICATION%

docker exec -it %CONTAINER_NAME% kafka-topics ^
  --create ^
  --topic %TOPIC% ^
  --bootstrap-server %BOOTSTRAP_SERVER% ^
  --partitions %PARTITIONS% ^
  --replication-factor %REPLICATION% ^
  --if-not-exists

echo.
echo Done!
:end