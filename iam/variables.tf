####################################################################
# Variables - 변수 선언 파일
####################################################################

# variable = 재사용 가능한 값을 정의
# - 여기서 선언하고, 다른 파일에서 var.aws_region 으로 사용
# - 값은 terraform.tfvars 파일이나 CLI에서 전달
variable "aws_region" {
  description = "region for aws"  # 변수 설명
  default     = "ap-northeast-2"  # 기본값: 서울 리전
}