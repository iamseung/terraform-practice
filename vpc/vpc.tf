####################################################################
# VPC 구성 - AWS 내 나만의 격리된 네트워크 만들기
####################################################################

# VPC = 가상 네트워크 공간 (집 전체라고 생각)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"  # IP 범위: 10.0.0.0 ~ 10.0.255.255 (약 65,000개)

  tags = {
    Name = "terraform-101"
  }
}

####################################################################
# Subnet = VPC를 나눈 방들 (Public: 거실, Private: 안방)
####################################################################

# Public Subnet: 인터넷과 직접 통신 가능 (웹서버 등 배치)
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id  # 어떤 VPC에 속하는지 참조
  cidr_block        = "10.0.0.0/24"    # IP 범위: 10.0.0.0 ~ 10.0.0.255 (256개)
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "terraform-101-public-subnet"
  }
}

# Private Subnet: 인터넷에서 직접 접근 불가 (DB 등 배치)
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"   # 10.0.10.0 ~ 10.0.10.255
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "terraform-101-private-subnet"
  }
}

####################################################################
# 인터넷 연결 게이트웨이들
####################################################################

# Internet Gateway = VPC의 현관문 (인터넷 ↔ VPC 연결)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "terraform-101-igw"
  }
}

# Elastic IP = 고정 공인 IP (NAT Gateway에 붙일 용도)
resource "aws_eip" "nat" {
  domain = "vpc"

  lifecycle {
    create_before_destroy = true  # 교체 시 새것 먼저 만들고 기존것 삭제
  }
}

# NAT Gateway = Private Subnet이 인터넷 "나가기만" 가능하게 해줌
# - Private → 인터넷: 가능 (업데이트 다운로드 등)
# - 인터넷 → Private: 불가능 (보안!)
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id  # NAT GW는 Public에 배치

  tags = {
    Name = "terraform-NATGW"
  }
}

####################################################################
# Route Table = 트래픽 길 안내판
####################################################################

# Public용 라우팅: 모든 외부 트래픽(0.0.0.0/0)은 IGW로
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"              # 목적지: 모든 외부
    gateway_id = aws_internet_gateway.igw.id  # 경로: IGW 통해서
  }

  tags = {
    Name = "terraform-101-rt-public"
  }
}

# Public Subnet ↔ Public Route Table 연결
resource "aws_route_table_association" "route_table_association_public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}

# Private용 라우팅 테이블 (기본 틀)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "terraform-101-rt-private"
  }
}

# Private Subnet ↔ Private Route Table 연결
resource "aws_route_table_association" "route_table_association_private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private.id
}

# Private의 외부 트래픽은 NAT Gateway로 (나가기만 가능)
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

####################################################################
# VPC Endpoint = AWS 서비스에 프라이빗하게 접근 (인터넷 안 거침)
####################################################################
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.ap-northeast-2.s3"  # S3에 내부망으로 접근
}
