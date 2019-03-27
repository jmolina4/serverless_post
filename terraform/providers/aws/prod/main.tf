provider "aws" {
  region     = "eu-west-1"
}
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "adogtame-zip-lambdas-bucket"
  acl    = "private"

  tags = {
    Name        = "Lambdas"
    Environment = "Prod"
  }
}

resource "aws_s3_bucket_object" "example_lambda" {
  depends_on = ["aws_s3_bucket.lambda_bucket"]
  bucket = "adogtame-zip-lambdas-bucket"
  key    = "v1.0.0/example.zip"
  source = "../../../../example.zip"
  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = "${filemd5("../../../../example.zip")}"
}
resource "aws_lambda_function" "external_dogs_importer" {
  depends_on = ["aws_s3_bucket_object.example_lambda"]
  function_name = "ExternalDogsImporter"

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = "adogtame-zip-lambdas-bucket"
  s3_key    = "v1.0.0/example.zip"

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