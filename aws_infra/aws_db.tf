resource "aws_db_instance" "webapp_db" {
  count = var.enable_aws_only ? 1 : 0
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "webapp-db" //agora é db_name
  username             = "admin"
  password             = "root"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.webapp_sg.id]
  db_subnet_group_name = aws_db_subnet_group.webapp_db_subnet_group[0].name
}