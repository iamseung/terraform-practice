####################################################################
# IAM User 생성 + 인라인 정책 연결
####################################################################

# IAM User = AWS에 로그인할 수 있는 계정
resource "aws_iam_user" "seungseok_test" {
  name = "seungseok_test"
}

# 인라인 정책 = 이 유저에게만 직접 붙이는 권한
# - Action: "*" = 모든 작업 허용
# - Resource: "*" = 모든 리소스에 대해
# ⚠️ 실무에서는 이렇게 모든 권한 주면 안 됨! (학습용)
resource "aws_iam_user_policy" "art_devops_black" {
  name   = "super-admin"
  user   = aws_iam_user.seungseok_test.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": ["*"],
            "Resource": ["*"]
        }
    ]
}
EOF
}
