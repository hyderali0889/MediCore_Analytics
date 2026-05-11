# clear_kafka_topic.py

import sys
import time
from confluent_kafka.admin import AdminClient, NewTopic

def create_topic(
    topic_name: str,
    bootstrap_servers: str = "localhost:29092",   # Changed default to your external listener
    num_partitions: int = 3,
    replication_factor: int = 1,
    wait_seconds: int = 8
):
    print(f"Connecting to Kafka using bootstrap server: {bootstrap_servers}")

    admin_client = AdminClient({
        'bootstrap.servers': bootstrap_servers,
        'client.id': 'topic-clearer'
    })



    # Recreate topic
    print(f"Creating topic: {topic_name}")
    new_topic = NewTopic(topic_name, num_partitions=num_partitions, replication_factor=replication_factor)
    fs = admin_client.create_topics([new_topic])

    for topic, future in fs.items():
        try:
            future.result()
            print(f"✅ Topic '{topic}' created successfully with {num_partitions} partitions!")
        except Exception as e:
            print(f"❌ Failed to create: {e}")

    print("Operation finished.\n")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python create_kafka_topic.py <topic_name> [bootstrap_server]")
        print("Example: python create_kafka_topic.py admissions-inbound")
        print("Example: python create_kafka_topic.py admissions-inbound localhost:29092")
        sys.exit(1)

    topic = sys.argv[1]
    bootstrap = sys.argv[2] if len(sys.argv) > 2 else "localhost:29092"

    create_topic(topic_name=topic, bootstrap_servers=bootstrap)