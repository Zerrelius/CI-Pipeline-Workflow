#!/bin/bash
# filepath: d:\Development\CICD\CI-Pipeline-Workflow\terraform\user-data.sh

# Umfassendes Logging
exec > >(tee /var/log/user-data.log) 2>&1
echo "=== User Data Script Started at $(date) ==="

# Fehler-Behandlung
set -e

# System Update
apt-get update -y
apt-get upgrade -y

# Nginx installieren
apt-get install -y nginx

# Web Directory erstellen
mkdir -p /var/www/${project_name}
chown -R www-data:www-data /var/www/${project_name}
chmod -R 755 /var/www/${project_name}

# Nginx konfigurieren
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
    
    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
}
EOF

# Nginx testen und starten
nginx -t
systemctl enable nginx
systemctl restart nginx

# Placeholder HTML erstellen
cat > /var/www/${project_name}/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Deployment Ready</title></head>
<body><h1>Server Ready - Waiting for Deployment</h1></body>
</html>
EOF

# Cloud-init Status setzen
echo "=== User Data completed successfully at $(date) ==="