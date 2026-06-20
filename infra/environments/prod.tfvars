# Set target AWS region to eu-west-1.
aws_region = "eu-west-1"
# Identify the environment as "prod". Used as a prefix for naming resources to isolate prod resources from development.
env = "prod"
# CIDR block for the Prod VPC. Allocates 65,536 private IP addresses separated from the Dev network.
vpc_cidr = "10.1.0.0/16"
# CIDR blocks for public subnets where the ALB will live. Public subnets are connected to the internet gateway.
public_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
# Availability Zones list. Multi-AZ distribution guarantees system resilience against single data center outages.
azs = ["eu-west-1a", "eu-west-1b"]
# Sets the name of the PostgreSQL application database.
db_name = "LeaveTrackDB"
# Name of the AWS Secrets Manager secret housing our production database credentials.
db_credentials_secret_name = "prod-db-credentials"

# Uses a medium/small compute instance class to handle production-grade traffic, providing double the RAM (2GB) of t3.micro.
instance_type = "t3.small"
# Enforces a minimum count of 2 instances in the Auto Scaling Group (ASG) for High Availability (HA) so if one AZ crashes, the app remains responsive.
min_size = 2
# Limits scale-out ceiling to 4 instances during peak traffic demand.
max_size = 4
# Starts with 2 instances active across different AZs.
desired_capacity = 2

# ACM Certificate ARN for HTTPS. When supplied, it activates HTTPS redirection.
certificate_arn = "" # Add your ACM ARN here to enable HTTPS

# Production-specific database settings
# Higher baseline storage allocation of 50GB to accommodate production data growth.
db_allocated_storage = 50
# Uses a production-capable database tier with higher CPU capacity and memory.
db_instance_class = "db.t3.medium"
# Enables synchronous database replication to a standby instance in a different Availability Zone (AZ) to ensure high availability and failover capability in production.
db_multi_az = true

