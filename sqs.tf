resource "aws_sqs_queue" "orders" {
  name                      = "${var.project_name}-${var.sqs_name}-Dev-SQS"
  delay_seconds             = 0
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.orders_dlq.arn
    maxReceiveCount     = 2
  })
}

resource "aws_sqs_queue" "orders_dlq" {
  name                      = "${var.project_name}-${var.sqs_name}_dlq-Dev-SQS"
  delay_seconds             = 0
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}

resource "aws_sqs_queue_policy" "orders" {
  queue_url = aws_sqs_queue.orders.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "1st",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.orders.arn}"
    },
    {
      "Sid": "2nd",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:GetQueueAttributes",
      "Resource": "${aws_sqs_queue.orders.arn}"
    }
  ]
}
POLICY
}
