resource "aws_db_instance" "webapp_db" {
  count                = var.enable_aws_only ? 1 : 0
  allocated_storage    = var.db_allocated_storage
  storage_type         = var.db_storage_type
  engine               = var.db_engine
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.webapp_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.webapp_db_subnet_group[0].name
}
