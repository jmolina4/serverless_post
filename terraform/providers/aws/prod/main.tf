provider "aws" {
  region     = "eu-west-1"
}
resource "aws_lambda_function" "external_dogs_importer" {
  function_name = "ExternalDogsImporter"


  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "main.handler"
  runtime = "nodejs6.10"

  role = "${aws_iam_role.lambda_exec.arn}"
}

# IAM role which dictates what other AWS services the Lambda function
# may access.
resource "aws_iam_role" "lambda_exec" {
  name = "serverless_dogs_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "adogtame-lambdas-bucket"
  acl    = "private"

  tags = {
    Name        = "Lambdas"
    Environment = "Prod"
  }
}