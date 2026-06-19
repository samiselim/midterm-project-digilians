#!/bin/bash
# Shebang line specifying that this script is executed inside the Bash shell.

# Redirect standard output (stdout) and standard error (stderr) to both a log file (/var/log/user-data.log) 
# and the syslog daemon. This is vital for debugging boot-time script failures as user data runs non-interactively.
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "=== Starting Bootstrapping ==="

# 1. Update system packages
# Upgrade all installed system dependencies using the DNF package manager to patch open security vulnerabilities.
dnf update -y

# 2. Install Docker container runtime
# Install Docker from the official Amazon Linux repositories.
dnf install -y docker
# Start the Docker background daemon immediately.
systemctl start docker
# Enable the Docker daemon to boot automatically if the EC2 instance restarts.
systemctl enable docker
# Add the default "ec2-user" to the "docker" Unix group to allow execution of docker commands without prefixing "sudo".
usermod -aG docker ec2-user

# 3. Install Docker Compose (V2 plugin)
# Create the standard directory structure where Docker searches for local CLI plugins.
mkdir -p /usr/local/lib/docker/cli-plugins/
# Download the stable v2.20.2 release binary of Docker Compose from GitHub.
curl -SL https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
# Apply executable permissions to the downloaded Docker Compose binary.
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
# Create a system-wide symlink in /usr/bin so "docker-compose" commands can be called globally.
ln -s /usr/local/lib/docker/cli-plugins/docker-compose /usr/bin/docker-compose

# 4. Authenticate to AWS Elastic Container Registry (ECR)
echo "Authenticating to ECR..."
# Export static AWS credentials directly so AWS CLI can authenticate without an IAM Instance Profile.
export AWS_ACCESS_KEY_ID="${aws_access_key_id}"
export AWS_SECRET_ACCESS_KEY="${aws_secret_access_key}"
export AWS_DEFAULT_REGION="${aws_region}"
# Request a temporary container registry login token via AWS CLI and pipe it to "docker login" to authorize pulling private ECR images.
aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${ecr_registry_url}

# 5. Create Docker Compose directory
# Create a folder in the ec2-user home folder to house compose configuration files.
mkdir -p /home/ec2-user/app
# Change directory context into the newly created folder.
cd /home/ec2-user/app

# 6. Generate docker-compose.yml with injected variables
# Write out the docker-compose template. Terraform's templatefile utility will resolve and inject the ${variables} on deployment.
cat <<EOF > docker-compose.yml
version: '3.8'

services:
  # Express.js API backend service
  backend:
    # Use the image pulled from our private AWS backend ECR repository.
    image: ${backend_image}
    container_name: backend-service
    ports:
      # Expose backend service to the host on port 8000.
      - "8000:8000"
    environment:
      # Node server listening port.
      - PORT=8000
      # Connect to the AWS RDS database endpoint resolved by Terraform.
      - DB_HOST=${db_host}
      # PostgreSQL standard database port.
      - DB_PORT=${db_port}
      # Name of the RDS database.
      - DB_NAME=${db_name}
      # Master database username.
      - DB_USER=${db_user}
      # Master database password.
      - DB_PASSWORD=${db_password}
      # Secret key used for JWT signing and token decryption.
      - JWT_SECRET=${jwt_secret}
      # Force SSL connection protocols when communicating with the RDS instance in AWS environments.
      - DB_SSL=true
    # Automatically restart backend service if it exits.
    restart: always

  # Vite React static web frontend service
  frontend:
    # Use the image pulled from our private AWS frontend ECR repository.
    image: ${frontend_image}
    container_name: frontend-service
    ports:
      # Expose Nginx server directly on the host's HTTP port 80.
      - "80:80"
    # Automatically restart frontend service if it exits.
    restart: always
EOF

# 7. Set ownership of the app directory
# Change directory owner and group recursively to ec2-user to prevent file permission lockouts during manual maintenance.
chown -R ec2-user:ec2-user /home/ec2-user/app

# 8. Start containers
echo "Starting application containers..."
# Run the application stack in detached daemon mode.
docker compose up -d

echo "=== Bootstrapping Completed Successfully ==="
