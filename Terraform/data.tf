# Amazon Linux 2 AMI 찾기
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

#TemplateFiles
//정원빈 수정
data "template_file" "api_server" {
  template = file("userdatas/api_server.sh")

  vars = {
    db_endpoint    = split(":", aws_db_instance.mysql_multi_az.endpoint)[0]
    db_username    = var.db_username
    db_password    = var.db_password
    file_userscontroller = file("dotnet_scripts/UsersController.cs")
    file_gamescontroller = file("dotnet_scripts/GamesController.cs")
    file_programcs = file("dotnet_scripts/Program.cs")
    file_userdbcontext = file("dotnet_scripts/UserDbContext.cs")
    file_gamedbcontext = file("dotnet_scripts/GameDbContext.cs")
    cognito_user_pool = aws_cognito_user_pool.user_pool.id
    cognito_app_client = aws_cognito_user_pool_client.app_client.id
  }
}

data "template_file" "rds_user_data" {
  template = file("userdatas/rds_userdata.sh")

  vars = {
    db_endpoint    = split(":", aws_db_instance.mysql_multi_az.endpoint)[0]
    db_username    = var.db_username
    db_password    = var.db_password
  }
}