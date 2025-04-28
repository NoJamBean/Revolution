resource "aws_ec2_transit_gateway" "seoul_tgw" {
  description = "Seoul region Transit Gateway"
  amazon_side_asn = 65000  # AS 번호, 원하는 대로 변경 가능
}

resource "aws_ec2_transit_gateway_vpc_attachment" "seoul_vpc_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.seoul_tgw.id
  vpc_id             = aws_vpc.vpc.id
  subnet_ids         = [aws_subnet.subnet.ids]
}

resource "aws_ec2_transit_gateway" "singapore_tgw" {
  provider = aws.singapore
  description = "싱가포르 리전 트랜짓 게이트웨이"
  amazon_side_asn = 65000  # AS 번호, 원하는 대로 변경 가능
}

resource "aws_ec2_transit_gateway_vpc_attachment" "singapore_vpc_attachment" {
  provider = aws.singapore
  transit_gateway_id = aws_ec2_transit_gateway.singapore_tgw.id
  vpc_id             = aws_vpc.sin_vpc.id
  subnet_ids         = [aws_subnet.subnet.ids]
}

# 피어링
resource "aws_ec2_transit_gateway_peering" "seoul_to_singapore" {
  transit_gateway_id = aws_ec2_transit_gateway.seoul_tgw.id
  peer_transit_gateway_id = aws_ec2_transit_gateway.singapore_tgw.id
  peer_region = "ap-southeast-1"
  peer_account_id = data.aws_caller_identity.current.id
}

resource "aws_ec2_transit_gateway_peering" "singapore_to_seoul" {
  provider = aws.singapore
  transit_gateway_id = aws_ec2_transit_gateway.singapore_tgw.id
  peer_transit_gateway_id = aws_ec2_transit_gateway.seoul_tgw.id
  peer_region = "ap-northeast-2"
  peer_account_id = data.aws_caller_identity.current.id
}