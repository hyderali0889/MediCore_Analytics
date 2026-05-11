To create Kafka Topics Using create_topic.bat file

create_topic.bat orders 6 1

echo Usage: create-topic.bat ^<topic-name^> [partitions] [replication]
echo Example: create-topic.bat patient-admissions 3 1

where order is the name of the topic, 6 is the number of partitions and 1 is the replication factor

Usage 

create_topic.bat hospital-events 4 1
list_all_topics.bat
describe_topic.bat hospital-events



Send data to kafka event after installing kafka connect and JDBC sink to connect to postgres


docker exec -it kafka kafka-console-producer --topic admissions-inbound --bootstrap-server localhost:9092


and then send JSON
{"name":"Ali","age":30,"condition":"fever"}



Check kafka status 
docker exec -it kafka kafka-topics --bootstrap-server localhost:9092 --describe --topic admissions-inbound


Check if kafka got the stored data


docker exec -it kafka kafka-console-consumer --topic admissions-inbound --bootstrap-server kafka:9092 --from-beginning