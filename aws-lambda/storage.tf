data "archive_file" "zip" {
  output_path = "index.zip"
  type        = "zip"
  source_dir  = var.source_dir
}

resource "aws_s3_bucket_object" "lambda_code" {
  bucket              = var.storage_bucket
  key                 = "lambda/${var.app_name}/${var.name}/code/index.zip"
  content_base64      = filebase64(data.archive_file.zip.output_path)
  content_disposition = "attachment"
  tags                = local.tags
}
