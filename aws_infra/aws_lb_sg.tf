resource "aws_security_group" "lb_sg" {
  name        = "lb-sg"
  description = "Load balancer Security group"
  vpc_id      = aws_vpc.webapp_vpc.id

  ingress {
    description = "HTTP so do meu IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["201.140.237.144/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}