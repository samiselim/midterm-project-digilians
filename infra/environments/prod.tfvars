aws_region           = "us-east-1"
env                  = "prod"
vpc_cidr             = "10.1.0.0/16"
public_subnets       = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnets      = ["10.1.3.0/24", "10.1.4.0/24"]
azs                  = ["us-east-1a", "us-east-1b"]
db_name              = "LeaveTrackDB"
db_user              = "dbadmin"
db_password          = "SuperStrongProdDbPassword123!" # Change me in real deployment
jwt_secret           = "SuperSecretProductionJWTKeyGenerateANewOne" # Change me
github_repo          = "your-github-username/your-repo-name" # Change me
instance_type        = "t3.small"
min_size             = 2
max_size             = 4
desired_capacity     = 2
create_oidc_provider = false
certificate_arn      = "" # Add your ACM ARN here to enable HTTPS

# Production-specific database settings
db_allocated_storage = 50
db_instance_class    = "db.t3.medium"
db_multi_az          = true
