resource "null_resource" "write_env" {
  provisioner "local-exec" {
    command = <<EOT
      ENV_PATH="../Web/webapp/.env"
      S3_NAME=$(terraform output -raw s3_bucket_name)

      if grep -q "^S3_BUCKET_NAME=" "$ENV_PATH"; then
        sed -i '' "s/^S3_BUCKET_NAME=.*/S3_BUCKET_NAME=$S3_NAME/" "$ENV_PATH"
      else
        echo "S3_BUCKET_NAME=$S3_NAME" >> "$ENV_PATH"
      fi
    EOT
  }

  depends_on = [aws_s3_bucket.log_bucket]
}
