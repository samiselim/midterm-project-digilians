aws_region = "eu-west-1"
# Identify the environment as "dev". Used as a prefix for naming resources to isolate dev resources from production.
env = "dev"
# CIDR block for the Dev VPC. Allocates 65,536 private IP addresses.
vpc_cidr = "10.0.0.0/16"
# CIDR blocks for public subnets where the ALB will live. Public subnets are connected to the internet gateway.
public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

# Availability Zones list. Multi-AZ distribution guarantees system resilience against single data center outages.
azs = ["eu-west-1a", "eu-west-1b"]
# Sets the name of the PostgreSQL application database.
db_name = "LeaveTrackDB"
# Name of the AWS Secrets Manager secret housing our dev database credentials.
db_credentials_secret_name = "dev/midtermproject/db_creds"

key_name = "samisEC2Key"
# Uses AWS's lowest-cost general purpose instance class, ideal for development testing under the AWS free tier.
instance_type = "t3.micro"
# Allows the Auto Scaling Group (ASG) to scale down to a single instance in Dev to minimize computing expenses.
min_size = 1
# Limits the scale-out ceiling to 2 instances in Dev to prevent runaway cloud usage costs.
max_size = 2
# Targets a baseline running instance count of 1.
desired_capacity = 1

# Empty in Dev, indicating we are routing web traffic on port 80 over HTTP instead of port 443 HTTPS. Saves ACM SSL provisioning step.
certificate_arn = ""

# Development-specific database settings
# Smallest storage size of 20GB for RDS to save database cost.
db_allocated_storage = 20
# Uses the low-cost RDS micro instance class.
db_instance_class = "db.t3.micro"
# Disables RDS Multi-AZ replication in Dev because high-availability failover is not required for dev environments, saving up to 50% in database fees.
db_multi_az = false

