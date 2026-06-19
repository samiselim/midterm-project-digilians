resource "aws_db_subnet_group" "rds" {
  name       = "${var.env}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.env}-rds-subnet-group"
    Environment = var.env
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.env}-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow PostgreSQL from application instances"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.env}-rds-sg"
    Environment = var.env
  }
}

resource "aws_db_instance" "postgres" {
  identifier             = "${var.env}-postgres-db"
  allocated_storage      = var.allocated_storage
  engine                 = "postgres"
  engine_version         = "15.7" # Stable long-term support Postgres 15 version
  instance_class         = var.instance_class
  db_name                = var.db_name
  username               = var.db_user
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  multi_az               = var.multi_az
  
  # Prod requires a final snapshot, Dev skips it to save teardown time and storage costs
  skip_final_snapshot       = var.env == "prod" ? false : true
  final_snapshot_identifier = var.env == "prod" ? "${var.env}-rds-final-snapshot" : null

  tags = {
    Name        = "${var.env}-rds-postgres"
    Environment = var.env
  }
}
