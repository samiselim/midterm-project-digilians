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

echo "=== Bootstrapping Completed Successfully ==="


# 4. Create App Directory and Create Environment File
mkdir -p /home/ec2-user/app

# Drop the db and jwt variables into a .env file for easy access by any container stack
cat <<EOF > /home/ec2-user/app/.env
DB_HOST=${db_host}
DB_PORT=${db_port}
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
JWT_SECRET=${jwt_secret}
DB_SSL=true
EOF
sudo chown -R ec2-user:ec2-user /home/ec2-user/app
sudo chmod -R 755 /home/ec2-user/app