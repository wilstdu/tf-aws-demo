import json, os, boto3
from boto3.dynamodb.conditions import Key

table_name = os.getenv('DB_TABLE_NAME')

db = boto3.resource('dynamodb').Table(table_name)

def lambda_handler(event, context):
    response = db.query(
        IndexName="status-index",
        KeyConditionExpression=Key('status').eq('new')
    )

    return {
        'statusCode': 200,
        'body': json.dumps('Orders: ' + str(response['Items']))
    }