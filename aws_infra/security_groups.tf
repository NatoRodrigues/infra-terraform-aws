resource "aws_security_group" "webapp_sg" {
    name        = "webapp_sg"
    description = "Security group for webapp instances"
    vpc_id      = aws_vpc.webapp_vpc.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.lb_sg.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}