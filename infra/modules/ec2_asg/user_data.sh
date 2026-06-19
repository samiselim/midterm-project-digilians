#!/bin/bash
# Enable logging for troubleshooting user data execution
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "=== Starting Bootstrapping ==="

# 1. Update system packages
dnf update -y

# 2. Install Docker
dnf install -y docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# 3. Install Docker Compose (V2 plugin)
mkdir -p /usr/local/lib/docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
ln -s /usr/local/lib/docker/cli-plugins/docker-compose /usr/bin/docker-compose

# 4. Authenticate to AWS ECR
echo "Authenticating to ECR..."
aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${ecr_registry_url}

# 5. Create Docker Compose directory
mkdir -p /home/ec2-user/app
cd /home/ec2-user/app

# 6. Generate docker-compose.yml with injected variables
cat <<EOF > docker-compose.yml
version: '3.8'

services:
  backend:
    image: ${backend_image}
    container_name: backend-service
    ports:
      - "8000:8000"
    environment:
      - PORT=8000
      - DB_HOST=${db_host}
      - DB_PORT=${db_port}
      - DB_NAME=${db_name}
      - DB_USER=${db_user}
      - DB_PASSWORD=${db_password}
      - JWT_SECRET=${jwt_secret}
      - DB_SSL=true
    restart: always

  frontend:
    image: ${frontend_image}
    container_name: frontend-service
    ports:
      - "80:80"
    restart: always
EOF

# 7. Set ownership of the app directory
chown -R ec2-user:ec2-user /home/ec2-user/app

# 8. Start containers
echo "Starting application containers..."
docker compose up -d

echo "=== Bootstrapping Completed Successfully ==="
