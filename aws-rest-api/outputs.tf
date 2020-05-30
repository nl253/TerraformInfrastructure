output "lambda" {
  value = module.lambda.lambda
}

output "api" {
  value = aws_api_gateway_rest_api.api
}
