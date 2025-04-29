# resource "aws_kms_key" "multi_region_key" {
#   description             = "Multi-Region KMS Key"
#   enable_key_rotation     = true
#   deletion_window_in_days = 7

#   # 다중 리전 설정
#   multi_region            = true

#   tags = {
#     Name = "Multi-Region KMS Key"
#   }
# }