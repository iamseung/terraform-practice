# Terraform 101 실습

## 프로젝트 구조

```
terraform-practice/
├── init/      # Backend 설정 (팀 협업용 상태 파일 관리)
├── vpc/       # 네트워크 구성
├── s3/        # 스토리지
└── iam/       # 권한 관리
```

---

## 1. Backend (init/)

팀 협업 시 tfstate 파일을 원격에서 공유하기 위한 설정

| 리소스 | 역할 |
|--------|------|
| S3 Bucket | tfstate 파일 저장 (버전 관리로 복구 가능) |
| DynamoDB | 동시 수정 방지 Lock |

---

## 2. VPC (vpc/)

AWS 내 격리된 네트워크 구성

```
┌─────────────────────────────────────────────────────┐
│  VPC (10.0.0.0/16)                                  │
│  ┌──────────────────┐    ┌──────────────────┐       │
│  │ Public Subnet    │    │ Private Subnet   │       │
│  │ 10.0.0.0/24      │    │ 10.0.10.0/24     │       │
│  │ (웹서버)          │    │ (DB)             │       │
│  └────────┬─────────┘    └────────┬─────────┘       │
│           │                       │                 │
│           ▼                       ▼                 │
│      ┌─────────┐            ┌───────────┐           │
│      │   IGW   │◄───────────│  NAT GW   │           │
│      └────┬────┘            └───────────┘           │
└───────────┼─────────────────────────────────────────┘
            │
        인터넷
```

| 리소스 | 비유 | 역할 |
|--------|------|------|
| VPC | 집 전체 | 격리된 네트워크 공간 |
| Public Subnet | 거실 | 인터넷과 직접 통신 |
| Private Subnet | 안방 | 외부에서 접근 불가 |
| Internet Gateway | 현관문 | VPC ↔ 인터넷 연결 |
| NAT Gateway | 택배함 | Private → 인터넷 (나가기만) |
| Route Table | 길 안내판 | 트래픽 경로 지정 |
| VPC Endpoint | 내부 통로 | AWS 서비스에 인터넷 없이 접근 |

---

## 3. IAM (iam/)

AWS 권한 관리

| 개념 | 대상 | 용도 |
|------|------|------|
| User | 사람 | AWS 콘솔/CLI 로그인 |
| Role | AWS 서비스 | EC2, Lambda 등이 임시 권한 획득 |
| Group | User 묶음 | 부서별 권한 일괄 관리 |
| Policy | - | 실제 권한 내용 (JSON) |
| Instance Profile | EC2 전용 | EC2에 Role 연결하는 껍데기 |

### Role vs User
- **User**: 사람이 직접 로그인
- **Role**: AWS 서비스가 "임시로" 권한을 빌려서 사용

---

## 4. S3 (s3/)

파일 저장소 (버킷 이름은 전세계 유일해야 함)

---

## Terraform 기본 문법

```hcl
# 리소스 생성
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# 다른 리소스 참조 (의존성 자동 처리)
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id  # 위에서 만든 VPC의 ID 참조
}

# 변수 선언
variable "region" {
  default = "ap-northeast-2"
}

# 변수 사용
provider "aws" {
  region = var.region
}
```

---

## 주요 명령어

```bash
terraform init      # 초기화 (provider 다운로드)
terraform plan      # 변경 사항 미리보기
terraform apply     # 실제 적용
terraform destroy   # 리소스 삭제
```
