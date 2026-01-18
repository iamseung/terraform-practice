####################################################################
# Terraform Backend 설정 - 팀 협업을 위한 상태 파일 원격 저장소 구성
####################################################################

# required_providers = 사용할 provider 버전 명시 (권장 방식)
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # 최신 안정 버전 사용
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

# tfstate 파일을 저장할 S3 버킷
# - tfstate: 테라폼이 관리하는 인프라의 현재 상태를 기록한 파일
# - 이걸 S3에 저장하면 팀원들이 같은 상태를 공유할 수 있음
resource "aws_s3_bucket" "tfstate" {
  bucket = "tf101-ss--apne2-tfstate"
}

# S3 버전 관리 설정 (AWS Provider 4.0+에서 별도 리소스로 분리됨)
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"  # 버전 관리 ON → 실수로 삭제해도 복구 가능
  }
}

# 동시 수정 방지용 Lock 테이블
# - 여러 사람이 동시에 terraform apply 하면 충돌 발생
# - DynamoDB로 "누가 작업 중" 표시해서 충돌 방지
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-lock"
  hash_key       = "LockID"        # Lock을 식별하는 키
  billing_mode   = "PAY_PER_REQUEST"  # 사용한 만큼만 과금

  attribute {
    name = "LockID"
    type = "S"  # S = String 타입
  }
}
