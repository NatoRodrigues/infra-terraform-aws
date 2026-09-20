# variables.tf
variable "enable_aws_only" {
  type        = bool
  default     = false    
  description = "Liga LB, Route 53 e RDS (exigem AWS real ou LocalStack Pro)"
}


// EC2

variable "ec2_config" {
  description = "Configuração da instância EC2"
  type = object({
    instance_type = string
    ami           = string
  })
}

 

// VPC

variable "vpc_config" {
  description = "Configuração da VPC"
  type = object({
    cidr_block = string
    tags       = map(string)
  })
}

variable "subnet1_config" {
  description = "Configuração da Subnet 1"
  type = object({
    cidr_block         = string
    availability_zone  = string
    tags               = map(string)
  })
}

variable "subnet2_config" {
  description = "Configuração da Subnet 2"
  type = object({
    cidr_block         = string
    availability_zone  = string
    tags               = map(string)
  })
}




// database

variable "db_allocated_storage" {
  description = "Tamanho do storage em GB"
  type        = number
  default     = 20
}

variable "db_storage_type" {
  description = "Tipo de storage"
  type        = string
  default     = "gp2"
}

variable "db_engine" {
  description = "Engine do banco"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Versão do engine"
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "Classe da instância"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Nome do banco"
  type        = string
  default     = "webapp-db"
}

variable "db_username" {
  description = "Usuário administrador"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Senha do administrador"
  type        = string
  sensitive   = true
  default     = "root"
}
