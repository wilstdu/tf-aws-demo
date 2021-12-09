## Terraform demo for AWS infrastructure creation for simple serverless POS (point of sale) system

**Compoments:**
  - API gateway
  - SQS
  - Lambda
  - DynamoDB

**VPC:**
  - 2 subnets (public and private)
  - DynamoDB endpoint (gateway)

**Implementation:**
  - API gateway exposes 2 resources:
    - /orders - to get all orders with status "new" (lambda proxy)
    - /orders/new - to place a new order (query parameters: _orderType_ and _contents_) (lambda proxy)
  - When /orders/new API request is received it's proxied to _PlaceOrder_ function, function stores order information in DynamoDB and sends metadata to Order SQS queue for decoupled processing
  - _Orders_ SQS queue has event source mapping with Lambda function (Lambda triggers), each new message triggers _OrderProcessor_ lamdba function
  - _OrderProcessor_ function simulates business logic processing with sleep function, later updates order status in DynamoDB orders table
  - If, for some reason _OrdersProcessor_ fails, after 2 retries message is sent to _orders_dlq_ SQS DLQ queue
  - Order processing function deployed into VPC, since it's in VPC, it's needed to expose DynamoDB endpoint
  - _OrderProcessor_ lambda function is deployed in a private subnet within VPC, so just for demo purposes implemented internet access from private subnet even though for such application public internet access would be irrelevant

**TODO:**
  - Store parameters like DB, SQS paths in Parameter Store
  - Limit SG traffic (now it's way to open)
  - Add lambda destination (SNS topic with multiple subscribers, e.g SES) for order placement function to send receipt
  - Add lambda destination (SNS topic with multiple subscribers, e.g SES) for processing function to notify client when order is completed
  - Action with DLQ queue
  - API auth