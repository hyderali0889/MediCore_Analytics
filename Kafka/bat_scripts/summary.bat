@echo off
echo === Kafka Docker Status ===
echo.

echo --- Container Status ---
docker ps --filter "name=kafka" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo.
echo --- Topic: admissions-inbound ---
docker exec kafka kafka-run-class kafka.tools.GetOffsetShell --bootstrap-server localhost:29092 --topic admissions-inbound --time -1 2>nul || echo Topic not found

echo.
echo --- Consumer Groups ---
docker exec kafka kafka-consumer-groups --bootstrap-server localhost:29092 --list 2>nul || echo No groups found

echo.
pause