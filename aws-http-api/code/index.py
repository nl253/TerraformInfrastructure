import json


def handler(x, y):
    return json.dumps({
        "isBase64Encoded": False,
        "statusCode": 200,
        'body': 'OK'
    })
