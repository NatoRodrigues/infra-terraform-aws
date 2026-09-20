# variables.tf
variable "enable_aws_only" {
  type        = bool
  default     = false   # LocalStack: desligado
  description = "Liga LB, Route 53 e RDS (exigem AWS real ou LocalStack Pro)"
}