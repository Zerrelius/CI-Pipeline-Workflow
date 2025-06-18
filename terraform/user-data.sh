#!/bin/bash

# Update system
apt-get update -y
apt-get upgrade -y

# Install Nginx
apt-get install -y nginx

# Create web directory
mkdir -p /var/www/${project_name}
chown -R www-data:www-data /var/www/${project_name}
chmod -R 755 /var/www/${project_name}

# Configure Nginx
cat > /etc/nginx/sites-available/${project_name} << EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    root /var/www/${project_name};
    index index.html index.htm;
    
    server_name _;
    
    location / {
        try_files \$uri \$uri/ /index.html;
    }
    
    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/${project_name} /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test and start Nginx
nginx -t
systemctl enable nginx
systemctl restart nginx

# Create a simple health check
echo "Server is running - $(date)" > /var/www/${project_name}/health.html

# Install Node.js (optional, for future use)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get install -y nodejs