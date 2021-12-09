resource "aws_lambda_function" "get_orders" {
  filename         = "POS_lambda.zip"
  function_name    = "${var.order_getter_lambda_name}"
  role             = aws_iam_role.lambda_orders_get.arn
  handler          = "${var.order_getter_lambda_name}.lambda_handler"
  runtime          = "python3.6"
  source_code_hash = "${data.archive_file.POS_lambda_zip.output_base64sha256}"

  environment {
    variables = {
      DB_TABLE_NAME = "${aws_dynamodb_table.orders_table.name}"
    }
  }
}

resource "aws_lambda_function" "place_order" {
  filename         = "POS_lambda.zip"
  function_name    = "${var.order_creator_lambda_name}"
  role             = aws_iam_role.lambda_orders_create.arn
  handler          = "${var.order_creator_lambda_name}.lambda_handler"
  runtime          = "python3.6"
  source_code_hash = "${data.archive_file.POS_lambda_zip.output_base64sha256}"

  environment {
    variables = {
      SQS_URL       = "${aws_sqs_queue.orders.id}"
      DB_TABLE_NAME = "${aws_dynamodb_table.orders_table.name}"
    }
  }
}

resource "aws_lambda_function" "orders_processor" {
  filename         = "POS_lambda.zip"
  function_name    = "${var.order_processor_lambda_name}"
  role             = aws_iam_role.lambda_orders_process.arn
  handler          = "${var.order_processor_lambda_name}.lambda_handler"
  runtime          = "python3.6"
  timeout          = 20
  source_code_hash = "${data.archive_file.POS_lambda_zip.output_base64sha256}"

  vpc_config {
    subnet_ids         = [aws_subnet.priv_subnet_1a.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      DB_TABLE_NAME = "${aws_dynamodb_table.orders_table.name}"
    }
  }
}

resource "aws_lambda_alias" "get_orders" {
  name             = "dev"
  description      = "point to latest"
  function_name    = aws_lambda_function.get_orders.arn
  function_version = "$LATEST"
}

resource "aws_lambda_alias" "place_order" {
  name             = "dev"
  description      = "point to latest"
  function_name    = aws_lambda_function.place_order.arn
  function_version = "$LATEST"
}

resource "aws_lambda_alias" "orders_processor" {
  name             = "dev"
  description      = "point to latest"
  function_name    = aws_lambda_function.orders_processor.arn
  function_version = "$LATEST"
}

resource "aws_lambda_permission" "apigw_get_orders" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_orders.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.get_orders.http_method}${aws_api_gateway_resource.orders.path}"
}

resource "aws_lambda_permission" "apigw_place_order" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.place_order.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.new_order.http_method}${aws_api_gateway_resource.new_order.path}"
}

resource "aws_lambda_event_source_mapping" "sqs_lambda" {
  event_source_arn = aws_sqs_queue.orders.arn
  function_name    = aws_lambda_function.orders_processor.arn
}
