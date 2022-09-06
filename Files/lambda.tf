resource "aws_lambda_function" "lambda" {
  filename         = var.lambda_file
  function_name    = var.lambda_function_name
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "image_resize.lambda_handler"
  publish          = true
  source_code_hash = filebase64sha256(var.lambda_file)
  runtime          = "python3.8"
  timeout          = 900
  layers           = [var.pip_package]

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs
  ]
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "Images/"
    #filter_suffix       = ".log"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}