from confluent_kafka import Consumer

conf = {
    'bootstrap.servers': 'localhost:29092',
    'group.id': 'test-group',
    'auto.offset.reset': 'earliest'
}

consumer = Consumer(conf)
consumer.subscribe(['admissions-inbound'])

print("📥 Listening for messages...")

while True:
    msg = consumer.poll(1.0)

    if msg is None:
        continue

    if msg.error():
        print("Error:", msg.error())
        continue

    print(f"Received: {msg.value().decode('utf-8')}")