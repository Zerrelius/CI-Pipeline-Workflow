#!/bin/bash
# filepath: d:\Development\CICD\CI-Pipeline-Workflow\terraform\user-data.sh

# Umfassendes Logging
exec > >(tee /var/log/user-data.log) 2>&1
echo "=== User Data Script Started at $(date) ==="

# Fehler-Behandlung
set -e

# System Update
echo "=== System Update ==="
apt-get update -y

# SSM Agent installieren und konfigurieren
echo "=== Installing and configuring SSM Agent ==="
snap install amazon-ssm-agent --classic || {
    echo "Snap install failed, trying alternative method..."
    wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
    dpkg -i amazon-ssm-agent.deb
}

systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
systemctl status amazon-ssm-agent --no-pager

# AWS CLI installieren
echo "=== Installing AWS CLI ==="
apt-get install -y awscli

# Nginx installieren
echo "=== Installing Nginx ==="
apt-get install -y nginx

# Web Directory erstellen
echo "=== Creating Web Directory ==="
mkdir -p /var/www/${project_name}
chown -R www-data:www-data /var/www/${project_name}
chmod -R 755 /var/www/${project_name}

# Nginx konfigurieren
echo "=== Configuring Nginx ==="
cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    root /var/www/${project_name};
    index index.html;
    
    server_name _;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
}
EOF

# Nginx testen und starten
nginx -t
systemctl enable nginx
systemctl restart nginx

# Placeholder HTML erstellen
cat > /var/www/${project_name}/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Deployment Ready</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
        .status { color: green; font-size: 24px; }
    </style>
</head>
<body>
    <h1 class="status">✅ Server Ready</h1>
    <p>Nginx is running and waiting for deployment</p>
    <p><small>Last updated: $(date)</small></p>
</body>
</html>
EOF

# Status überprüfen
echo "=== Final Status Check ==="
systemctl status nginx --no-pager
systemctl status amazon-ssm-agent --no-pager
ls -la /var/www/${project_name}/

# SSM Agent Registration wird automatisch gemacht - keine manuelle Registrierung nötig
echo "=== SSM Agent will register automatically with IAM instance profile ==="

echo "=== User Data completed successfully at $(date) ==="