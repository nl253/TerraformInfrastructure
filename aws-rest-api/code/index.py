import json


def handler(x, y):
    return dict(
        statusCode=200,
        headers={
            'Content-Type': 'application/json',
        },
        body=json.dumps({'ok': True}),
        isBase64Encoded=False)
