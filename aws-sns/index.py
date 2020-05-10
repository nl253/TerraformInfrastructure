def handler(event, context):
    print(event)
    print(context)
    msg = f'received message: {event["Records"][0]["Sns"]["Message"]}'
    print(msg)
    return msg
