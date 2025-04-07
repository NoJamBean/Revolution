resource "aws_vpc_endpoint" "agw_endpoint" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.ap-northeast-2.execute-api"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.subnet["api1"].id, aws_subnet.subnet["api2"].id]
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id] 

  private_dns_enabled = true  

  tags = {
    Name = "vpce-apigateway"
  }
}