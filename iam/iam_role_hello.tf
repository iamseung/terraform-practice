####################################################################
# IAM Role - AWS 서비스(EC2 등)에 권한 부여하기
####################################################################

# Role vs User 차이:
# - User: 사람이 로그인해서 사용
# - Role: AWS 서비스(EC2, Lambda 등)가 "임시로" 권한을 얻어 사용

# Role 생성 + 누가 이 Role을 맡을 수 있는지 정의 (Trust Policy)
resource "aws_iam_role" "hello" {
  name = "hello-iam-role"
  path = "/"

  # assume_role_policy = "누가 이 역할을 맡을 수 있나?"
  # 여기선 EC2 서비스가 이 역할을 맡을 수 있음
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Role에 붙일 권한 정책 (이 역할이 "무엇"을 할 수 있는지)
resource "aws_iam_role_policy" "hello_s3" {
  name   = "hello-s3-download"
  role   = aws_iam_role.hello.id

  # S3에서 파일 다운로드(GetObject) 가능
  policy = <<EOF
{
  "Statement": [
    {
      "Sid": "AllowAppArtifactsReadAccess",
      "Action": ["s3:GetObject"],
      "Resource": ["*"],
      "Effect": "Allow"
    }
  ]
}
EOF
}

# Instance Profile = EC2에 Role을 연결하는 "껍데기"
# - EC2는 Role을 직접 연결 못하고, Instance Profile을 통해 연결
resource "aws_iam_instance_profile" "hello" {
  name = "hello-profile"
  role = aws_iam_role.hello.name
}

