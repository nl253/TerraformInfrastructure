output "lambda" {
  value = aws_lambda_function.lambda
}

output "role" {
  value = module.role
}

output "code" {
  value = aws_s3_bucket_object.lambda_code
}
