# clear_kafka_topic.py

import sys
import time
from confluent_kafka.admin import AdminClient, NewTopic

def delete_and_recreate_topic(
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

    # Delete topic
    print(f"Deleting topic: {topic_name}")
    fs = admin_client.delete_topics([topic_name])

    for topic, future in fs.items():
        try:
            future.result()
            print(f"✅ Topic '{topic}' deleted.")
        except Exception as e:
            err = str(e).lower()
            if "unknown_topic" in err or "does not exist" in err:
                print(f"⚠️ Topic '{topic}' does not exist.")
            else:
                print(f"❌ Failed to delete: {e}")

    print(f"Waiting {wait_seconds} seconds for deletion to propagate...")
    time.sleep(wait_seconds)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python delete_kafka_topic.py <topic_name> [bootstrap_server]")
        print("Example: python delete_kafka_topic.py admissions-inbound")
        print("Example: python clear_kafka_topic.py admissions-inbound localhost:29092")
        sys.exit(1)

    topic = sys.argv[1]
    bootstrap = sys.argv[2] if len(sys.argv) > 2 else "localhost:29092"

    delete_and_recreate_topic(topic_name=topic, bootstrap_servers=bootstrap)