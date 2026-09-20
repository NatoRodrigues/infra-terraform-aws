resource "aws_lb_target_group" "webapp_tg" {
  count = var.enable_aws_only ? 1 : 0
  name     = "webapp-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.webapp_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}


// escuta HTTP na 80; qualquer requisição que nenhuma regra reconheça recebe 404
resource "aws_lb_listener" "webapp_listener" {
  count             = var.enable_aws_only ? 1 : 0
  load_balancer_arn = aws_lb.webapp_lb[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }
}

// Listener rule: encaminha requisições /api/* para o target group
resource "aws_lb_listener_rule" "webapp_rule" {
  count        = var.enable_aws_only ? 1 : 0
  listener_arn = aws_lb_listener.webapp_listener[0].arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp_tg[0].arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}