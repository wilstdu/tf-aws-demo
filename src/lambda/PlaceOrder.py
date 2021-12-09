import json, os, boto3, random
from datetime import datetime

# Create SQS client
sqs = boto3.client('sqs')
db = boto3.resource('dynamodb')

queue_url = os.getenv('SQS_URL')
table_name = os.getenv('DB_TABLE_NAME')

def lambda_handler(event, context):
    if not('queryStringParameters' in event) or event['queryStringParameters'] == None:
        raise Exception('queryStringParameters was not found')

    orderId = random.randrange(1000, 100000, 1)

    # Place order reference in dynamodb for persistance
    table = db.Table(table_name)
    table.put_item(Item={
        'id': orderId,
        'type': event['queryStringParameters']['orderType'],
        'contents': event['queryStringParameters']['contents'],
        'status' : "new",
        'creation_time': datetime.today().strftime('%Y-%m-%d-%H:%M:%S')
    })

    # parsing JSON string:
    payload = json.loads('{ }')

    # appending the data
    payload.update({"orderId": str(orderId)})
    payload.update({"orderType": event['queryStringParameters']['orderType']})
    payload.update({"contents": event['queryStringParameters']['contents']})

    #Send message to SQS queue for further processing
    sqs.send_message(
        QueueUrl=queue_url,
        DelaySeconds=0,
        MessageBody=(
          json.dumps(payload)
        )
    )

    return {
        'statusCode': 200,
        'body': json.dumps('Order #' + str(orderId) + ' received!')
    }
