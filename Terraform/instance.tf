# 

# 프라이빗 인스턴스 생성
resource "aws_instance" "api_server1" {
  for_each      = {
    sn3 = { subnet_id = aws_subnet.subnet["sn3"].id, az = "ap-northeast-2a" }
  }

  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = each.value.subnet_id
  availability_zone = each.value.az
  private_ip = "10.0.3.100"

  associate_public_ip_address = false
  key_name      = module.ssh_key.key_name
  security_groups = [aws_security_group.SG.id]

  user_data = file("uesrdatas/apiserver.sh")

  tags = {
    Name = "api-server1"
  }
}

# 프라이빗 인스턴스 생성
resource "aws_instance" "api_server2" {
  for_each      = {
    sn4 = { subnet_id = aws_subnet.subnet["sn4"].id, az = "ap-northeast-2c" }
  }

  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = each.value.subnet_id
  availability_zone = each.value.az
  private_ip = "10.0.4.100"

  associate_public_ip_address = false
  key_name      = module.ssh_key.key_name
  security_groups = [aws_security_group.SG.id]

  user_data = file("uesrdatas/apiserver.sh")

  tags = {
    Name = "api-server2"
  }
}