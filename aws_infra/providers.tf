provider "aws" {
        region                      = "us-east-1"
        access_key                  = "mock_access_key"
        secret_key                  = "mock_secret_key"
        skip_credentials_validation = true
        skip_metadata_api_check     = true
        skip_requesting_account_id  = true

        s3_use_path_style = true

        endpoints {
                ec2      = "http://localhost:4566"   # aws_instance, aws_vpc, aws_subnet, aws_security_group
                elbv2    = "http://localhost:4566"   # aws_lb, listener, listener_rule, target_group, attachment
                rds      = "http://localhost:4566"   # aws_db_instance, aws_db_subnet_group
                route53  = "http://localhost:4566"   # aws_route53_zone, aws_route53_record
                dynamodb = "http://localhost:4566"   # aws_dynamodb_table
                s3       = "http://localhost:4566"   # aws_s3_bucket  
                sts      = "http://localhost:4566"   # identidade (rede de segurança)
                }
}
