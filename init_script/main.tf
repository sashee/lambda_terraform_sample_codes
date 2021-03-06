provider "aws" {
}

resource "random_id" "id" {
  byte_length = 8
}

data "external" "npm_ci" {
  program = ["bash", "-c", <<EOT
(npm ci) >&2 && echo "{\"dest\": \"\"}"
EOT
  ]
  working_dir = "${path.module}/src"
}

data "archive_file" "lambda_zip_dir" {
  type        = "zip"
  output_path = "/tmp/lambda_dir-${random_id.id.hex}.zip"
  source_dir  = "${data.external.npm_ci.working_dir}/${data.external.npm_ci.result.dest}"
}

resource "aws_lambda_function" "lambda" {
  function_name = "${random_id.id.hex}-function"

  filename         = data.archive_file.lambda_zip_dir.output_path
  source_code_hash = data.archive_file.lambda_zip_dir.output_base64sha256

  handler = "main.handler"
  runtime = "nodejs12.x"
  role    = aws_iam_role.lambda_exec.arn
}

data "aws_iam_policy_document" "lambda_exec_role_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

resource "aws_cloudwatch_log_group" "loggroup" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 14
}

resource "aws_iam_role_policy" "lambda_exec_role" {
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.lambda_exec_role_policy.json
}

resource "aws_iam_role" "lambda_exec" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

# api gw

resource "aws_apigatewayv2_api" "api" {
  name          = "api-${random_id.id.hex}"
  protocol_type = "HTTP"
  target        = aws_lambda_function.lambda.arn
}

resource "aws_lambda_permission" "apigw" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

output "url" {
  value = aws_apigatewayv2_api.api.api_endpoint
}

