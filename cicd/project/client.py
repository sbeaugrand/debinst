#!/usr/bin/env python3
import pika
import uuid
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-H', '--host', default='localhost', help='default: localhost')
parser.add_argument('-q', '--queue')
parser.add_argument('-m', '--message')
args = parser.parse_args()


class RpcClient(object):

    def __init__(self):
        self.connection = pika.BlockingConnection(
            pika.ConnectionParameters(host=args.host))

        self.channel = self.connection.channel()

        result = self.channel.queue_declare(queue='', exclusive=True)
        self.callback_queue = result.method.queue

        self.channel.basic_consume(
            queue=self.callback_queue,
            on_message_callback=self.on_response,
            auto_ack=True)

        self.response = None
        self.corr_id = None

    def on_response(self, ch, method, props, body):
        if self.corr_id == props.correlation_id:
            self.response = body

    def call(self, msg):
        self.response = None
        self.corr_id = str(uuid.uuid4())
        self.channel.basic_publish(
            exchange='',
            routing_key=args.queue,
            properties=pika.BasicProperties(
                reply_to=self.callback_queue,
                correlation_id=self.corr_id,
            ),
            body=msg)
        self.connection.process_data_events(time_limit=None)
        return self.response


rpc = RpcClient()
response = rpc.call(args.message)
print(str(response))
