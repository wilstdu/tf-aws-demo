data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "archive_file" "POS_lambda_zip" {
    type        = "zip"
    source_dir  = "${path.module}/src/lambda/"
    output_path = "POS_lambda.zip"
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
