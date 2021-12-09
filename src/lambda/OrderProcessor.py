import json, os, boto3, time, random
from datetime import datetime
from botocore.vendored import requests

table_name = os.getenv('DB_TABLE_NAME')

# Create DynamoDB client
db = boto3.resource('dynamodb').Table(table_name)

def lambda_handler(event, context):
    for record in event['Records']:
        orderInfo=(record["body"])
        orderInfo = json.loads(orderInfo)
        orderId = str(orderInfo['orderId'])

        print('Order info: id=' +  orderId + " orderType=" + orderInfo['orderType'] + " contents=" + orderInfo['contents'])

        req = requests.get('https://github.com/timeline.json') # request to the public internet just to test intennet connectivity from VPC
        print(req.json())

        # Simulate business logic
        time.sleep(random.randrange(1, 5, 1))

        db.update_item(
            Key={'id': int(orderId)},
            UpdateExpression="SET #status = :new_status, #completion_time = :completion_time",
            ExpressionAttributeNames={
                "#status": "status",
                "#completion_time": "completion_time"
            },
            ExpressionAttributeValues={
                ":new_status": "fulfilled",
                ":completion_time": datetime.today().strftime('%Y-%m-%d-%H:%M:%S')
            }
        )

    return {
        'statusCode': 200,
        'body': json.dumps('Order #' + orderId + ' has been fulfilled!')
    }
