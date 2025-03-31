# 

#DotNet Backend Server1
#정원빈 수정
resource "aws_instance" "dotnet_api_server" {
  ami             = data.aws_ami.amazon_linux.id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.subnet["sn3"].id
  security_groups = [aws_security_group.default_sg.id]
  key_name        = var.seoul_key_name

  user_data = data.template_file.api_server.rendered

  tags = {
    Name = "DotNet-API-SERVER"
  }
}

#DB접근용 인스턴스
#정원빈
resource "aws_instance" "rds_access_instance" {
  provider                    = aws
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = var.seoul_key_name
  subnet_id                   = aws_subnet.subnet["sn3"].id
  security_groups             = [aws_security_group.default_sg.id]
  associate_public_ip_address = true

  tags = { Name = "Instance1" }

  user_data = data.template_file.rds_user_data.rendered
}