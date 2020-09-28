import os
import json
from flask import Flask
from flask_restful import Api, Resource, reqparse
from unicornhatmini import UnicornHATMini
import time

unicornhatmini = UnicornHATMini()
unicornhatmini.set_brightness(0.1)

data = {}
data['status'] = { 'status': 0 }

data_file = os.path.join(os.path.dirname(__file__), 'data.json')
with open(data_file) as json_file:
    data = json.load(json_file)

app = Flask(__name__)
api = Api(app)

class Color:
    def __init__(self, r, g, b):
        self.r = r
        self.g = g
        self.b = b

def set_status(status):
    color = Color(0, 0, 0)
    if status == 0:
        color = Color(0, 196, 0)
    else:
        color = Color(196, 0, 0)
    unicornhatmini.set_all(color.r, color.g, color.b)
    unicornhatmini.show()
    time.sleep(0.05)

class Status(Resource):
    def get(self):
        return data['status'], 200
    def put(self):
        parser = reqparse.RequestParser()
        parser.add_argument('status')
        args = parser.parse_args()

        record = { 'status': args['status'] }
        data['status'] = record
        status = int(args['status'])
        set_status(status)
        with open('data.json', 'w') as outfile:
            json.dump(data, outfile)
        return record, 200

status = int(data['status']['status'])
set_status(status)

api.add_resource(Status, "/status")
app.run(debug=False)
