####################################################################
# IAM Group - 여러 유저를 묶어서 권한 관리
####################################################################

# Group = 유저들의 묶음 (부서 개념)
# - 그룹에 정책 붙이면 소속 유저 전원에게 적용됨
resource "aws_iam_group" "devops_group" {
  name = "devops"
}

# 그룹 멤버십 = 어떤 유저들이 이 그룹에 속하는지 정의
resource "aws_iam_group_membership" "devops" {
  name  = aws_iam_group.devops_group.name
  group = aws_iam_group.devops_group.name

  users = [
    aws_iam_user.seungseok_test.name  # 다른 파일에서 정의한 유저 참조
  ]
}
