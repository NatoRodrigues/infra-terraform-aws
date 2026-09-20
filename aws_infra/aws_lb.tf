resource "aws_lb" "webapp_lb" {
  count = var.enable_aws_only ? 1 : 0
  name               = "webapp-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.webapp_subnet_1.id, aws_subnet.webapp_subnet_2.id] 

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

// Vincula as 4 VMs ao Target Group do Load Balancer de forma automatizada
resource "aws_lb_target_group_attachment" "webapp_vm_attachment" {
  for_each = var.enable_aws_only ? toset(["VM1", "VM2", "VM3", "VM4"]) : []

  target_group_arn = aws_lb_target_group.webapp_tg[0].arn
  target_id        = aws_instance.VM[each.key].id
  port             = 80
}
