module "vpc" {
  source = "../../modules/vpc"

  env             = var.env
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.azs
}

module "ecr" {
  source = "../../modules/ecr"

  env = var.env
}

module "iam" {
  source = "../../modules/iam"

  env                  = var.env
  github_repo          = var.github_repo
  create_oidc_provider = var.create_oidc_provider
}

module "alb" {
  source = "../../modules/alb"

  env               = var.env
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  # Served over HTTP on port 80 for dev. Can be configured with a cert ARN in prod.
  certificate_arn   = ""
}

module "rds" {
  source = "../../modules/rds"

  env                   = var.env
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  db_name               = var.db_name
  db_user               = var.db_user
  db_password           = var.db_password
  app_security_group_id = module.ec2_asg.ec2_security_group_id

  # Small sizing for cost conservation in dev
  allocated_storage = 20
  instance_class    = "db.t3.micro"
  multi_az          = false
}

module "ec2_asg" {
  source = "../../modules/ec2_asg"

  env                       = var.env
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  iam_instance_profile      = module.iam.ec2_instance_profile_name
  alb_security_group_id     = module.alb.alb_security_group_id
  target_group_frontend_arn = module.alb.target_group_frontend_arn
  target_group_backend_arn  = module.alb.target_group_backend_arn
  aws_region                = var.aws_region
  ecr_registry_url          = split("/", module.ecr.backend_repository_url)[0]
  
  # Image definitions pointing to our ECR repositories
  backend_image             = "${module.ecr.backend_repository_url}:latest"
  frontend_image            = "${module.ecr.frontend_repository_url}:latest"

  # Database configuration
  db_host                   = module.rds.db_host
  db_port                   = module.rds.db_port
  db_name                   = var.db_name
  db_user                   = var.db_user
  db_password               = var.db_password
  jwt_secret                = var.jwt_secret

  # Scale bounds for dev
  instance_type             = var.instance_type
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
}
