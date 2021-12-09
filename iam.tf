resource "aws_iam_role" "lambda_orders_get" {
  name               = "${var.project_name}-lambda-${var.order_getter_lambda_name}-Dev-ROLE"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json

  inline_policy {
    name = "${var.project_name}-lambda-${var.order_getter_lambda_name}-Dev-POLICY"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Action": [
            "dynamodb:Query"
          ],
          Effect   = "Allow"
          Resource = "${aws_dynamodb_table.orders_table.arn}*"
        }
      ]
    })
  }
}

resource "aws_iam_role" "lambda_orders_create" {
  name               = "${var.project_name}-lambda-${var.order_creator_lambda_name}-Dev-ROLE"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json

  inline_policy {
    name = "${var.project_name}-lambda-${var.order_creator_lambda_name}-Dev-POLICY"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Action": [
            "dynamodb:PutItem"
          ],
          Effect   = "Allow"
          Resource = "${aws_dynamodb_table.orders_table.arn}"
        },
        {
          "Effect": "Allow",
          "Action": "logs:CreateLogGroup",
          "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
        },
        {
          "Effect": "Allow",
          "Action": [
              "logs:CreateLogStream",
              "logs:PutLogEvents"
          ],
          "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.order_creator_lambda_name}:*"
        }
      ]
    })
  }
}

resource "aws_iam_role" "lambda_orders_process" {
  name               = "${var.project_name}-lambda-${var.order_processor_lambda_name}-Dev-ROLE"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json

  inline_policy {
    name = "${var.project_name}-lambda-${var.order_processor_lambda_name}-Dev-POLICY"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Action": [
            "sqs:ReceiveMessage",
            "sqs:DeleteMessage"
          ],
          Effect   = "Allow"
          Resource = "${aws_sqs_queue.orders.arn}"
        },
        {
          "Effect": "Allow",
          "Action": "logs:CreateLogGroup",
          "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
        },
        {
          "Effect": "Allow",
          "Action": [
              "logs:CreateLogStream",
              "logs:PutLogEvents"
          ],
          "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.order_processor_lambda_name}:*"
        },
        {
          "Action": [
            "dynamodb:UpdateItem"
          ],
          Effect   = "Allow"
          Resource = "${aws_dynamodb_table.orders_table.arn}"
        },
      ]
    })
  }
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_lambda_vpc_access_execution" {
  role       = aws_iam_role.lambda_orders_process.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
