# Nginx Guide

## What is Nginx?
Nginx (pronounced "engine-x") is a high-performance, open-source web server, reverse proxy, load balancer, and HTTP cache. It is known for its stability, rich feature set, simple configuration, and low resource consumption. Nginx is widely used in DevOps for serving static content, load balancing, SSL/TLS termination, and as a reverse proxy for backend applications.

## Key Concepts

### Web Server
Nginx can serve static files (HTML, CSS, JavaScript, images) directly to clients with high performance and low memory usage.

### Reverse Proxy
Nginx can forward client requests to backend servers (application servers, APIs) and return the response to the client, acting as an intermediary.

### Load Balancer
Nginx can distribute incoming requests across multiple backend servers to balance the load and improve application availability and reliability.

### SSL/TLS Termination
Nginx can handle HTTPS connections, decrypt SSL/TLS traffic, and forward unencrypted traffic to backend servers, offloading encryption overhead.

### HTTP Cache
Nginx can cache responses from backend servers to reduce load and improve response times for subsequent requests.

## Installation and Setup

### Install Nginx (Ubuntu/Debian)
```bash
# Update package index
sudo apt update

# Install Nginx
sudo apt install nginx

# Start Nginx service
sudo systemctl start nginx

# Enable Nginx to start on boot
sudo systemctl enable nginx

# Check Nginx status
sudo systemctl status nginx

# Verify installation
nginx -v
```

### Verify Installation
```bash
# Check if Nginx is running
curl http://localhost

# You should see the default Nginx welcome page
```

## Essential Nginx Commands

### Service Management
```bash
# Start Nginx
sudo systemctl start nginx

# Stop Nginx
sudo systemctl stop nginx

# Restart Nginx
sudo systemctl restart nginx

# Reload configuration without dropping connections
sudo systemctl reload nginx

# Enable Nginx to start on boot
sudo systemctl enable nginx

# Disable Nginx from starting on boot
sudo systemctl disable nginx

# Check Nginx status
sudo systemctl status nginx
```

### Configuration Testing and Management
```bash
# Test configuration for syntax errors
sudo nginx -t

# Test configuration and dump it
sudo nginx -T

# Reload configuration
sudo nginx -s reload

# Stop Nginx gracefully
sudo nginx -s quit

# Stop Nginx immediately
sudo nginx -s stop

# Reopen log files
sudo nginx -s reopen
```

### Version and Information
```bash
# Check Nginx version
nginx -v

# Check version and configuration options
nginx -V

# Show help
nginx -h
```

## Nginx Configuration Structure

### Main Configuration File
The main configuration file is typically located at `/etc/nginx/nginx.conf`.

### Configuration Hierarchy
```
nginx.conf (main context)
├── events (connection processing)
├── http (HTTP server)
│   ├── upstream (load balancing)
│   ├── server (virtual host)
│   │   ├── location (URL routing)
│   │   └── location
│   └── server
└── stream (TCP/UDP load balancing)
```

### Important Directories
```bash
# Main configuration file
/etc/nginx/nginx.conf

# Site-specific configurations (Debian/Ubuntu)
/etc/nginx/sites-available/    # Available sites
/etc/nginx/sites-enabled/      # Enabled sites (symlinks)

# Configuration snippets and includes
/etc/nginx/conf.d/             # Additional configurations
/etc/nginx/snippets/           # Reusable configuration snippets

# Document root (default)
/usr/share/nginx/html          # Default web root
/var/www/html                  # Alternative web root

# Log files
/var/log/nginx/access.log      # Access logs
/var/log/nginx/error.log       # Error logs
```

## Basic Nginx Configurations

### Example 1: Basic Static Web Server
Simple configuration to serve static files.

```nginx
events {
}

http {
    server {
        listen 80;
        root /usr/share/nginx/html;  # Document root
    }
}
```

### Example 2: Multiple Server Blocks with MIME Types
Serving multiple sites on different ports with proper MIME type handling.

```nginx
events {
}

http {
    include mime.types;  # Include MIME types for file extensions

    server {
        listen 80;
        root /usr/share/nginx/html;
    }

    server {
        listen 8080;
        root /var/www/example2.com/html;
        index index.html;
    }
}
```

### Example 3: SSL/TLS Configuration
Secure site with HTTPS configuration.

```nginx
events {
}

http {
    include mime.types;

    server {
        listen 443 ssl;
        server_name example3.com www.example3.com;

        # SSL certificate configuration
        ssl_certificate /etc/ssl/certs/example3.com.crt;
        ssl_certificate_key /etc/ssl/private/example3.com.key;
        ssl_protocols TLSv1.2 TLSv1.3;

        root /var/www/example3.com/html;
        index index.html;

        # Custom error page
        error_page 404 /404.html;

        location / {
            try_files $uri $uri/ =404;
        }

        # Logging
        access_log /var/log/nginx/example3.com.access.log;
        error_log /var/log/nginx/example3.com.error.log;
    }
}
```

### Example 4: Reverse Proxy Configuration
Forward requests to backend application servers.

```nginx
events {
}

http {
    include mime.types;

    # HTTP to HTTPS redirect
    server {
        listen 80;
        server_name example4.com www.example4.com;

        location / {
            proxy_pass http://example2.com:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

    # HTTPS server
    server {
        listen 443 ssl;
        server_name example4.com www.example4.com;

        ssl_certificate /etc/ssl/certs/example4.com.crt;
        ssl_certificate_key /etc/ssl/private/example4.com.key;
        ssl_protocols TLSv1.2 TLSv1.3;

        root /var/www/example4.com/html;
        index index.html;

        error_page 404 /404.html;

        location / {
            try_files $uri $uri/ =404;
        }

        access_log /var/log/nginx/example4.com.access.log;
        error_log /var/log/nginx/example4.com.error.log;
    }
}
```

### Example 5: Load Balancer Configuration
Distribute traffic across multiple backend servers.

```nginx
events {
}

http {
    include mime.types;

    # Define upstream backend servers
    upstream backend_servers {
        server 192.168.1.10:8080;
        server 192.168.1.11:8080;
        server 192.168.1.12:8080;
    }

    server {
        listen 80;
        server_name example5.com www.example5.com;

        location / {
            # Forward requests to backend servers
            proxy_pass http://backend_servers;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        access_log /var/log/nginx/example5.com.access.log;
        error_log /var/log/nginx/example5.com.error.log;
    }
}
```

## Advanced Nginx Configurations

### Complete Server Block with Best Practices
```nginx
server {
    listen 80;
    listen [::]:80;
    server_name example.com www.example.com;

    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name example.com www.example.com;

    # Document root
    root /var/www/example.com/html;
    index index.html index.htm;

    # SSL configuration
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Logging
    access_log /var/log/nginx/example.com.access.log;
    error_log /var/log/nginx/example.com.error.log;

    # Main location
    location / {
        try_files $uri $uri/ =404;
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    # Custom error pages
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
}
```

### Load Balancing with Health Checks
```nginx
upstream backend {
    least_conn;  # Load balancing method

    server 192.168.1.10:8080 weight=3 max_fails=3 fail_timeout=30s;
    server 192.168.1.11:8080 weight=2 max_fails=3 fail_timeout=30s;
    server 192.168.1.12:8080 weight=1 max_fails=3 fail_timeout=30s;
    server 192.168.1.13:8080 backup;  # Backup server
}

server {
    listen 80;
    server_name api.example.com;

    location / {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

### Caching Configuration
```nginx
# Define cache path and settings
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=1g 
                 inactive=60m use_temp_path=off;

server {
    listen 80;
    server_name cache.example.com;

    location / {
        proxy_cache my_cache;
        proxy_pass http://backend;
        
        # Cache settings
        proxy_cache_use_stale error timeout http_500 http_502 http_503 http_504;
        proxy_cache_valid 200 60m;
        proxy_cache_valid 404 10m;
        proxy_cache_bypass $http_cache_control;
        
        # Add cache status header
        add_header X-Cache-Status $upstream_cache_status;
        
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Rate Limiting
```nginx
# Define rate limiting zones
limit_req_zone $binary_remote_addr zone=general:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=api:10m rate=5r/s;

server {
    listen 80;
    server_name example.com;

    location / {
        limit_req zone=general burst=20 nodelay;
        root /var/www/html;
    }

    location /api/ {
        limit_req zone=api burst=10 nodelay;
        proxy_pass http://backend;
    }
}
```

## Load Balancing Methods

### Round Robin (Default)
Distributes requests evenly across servers in order.
```nginx
upstream backend {
    server 192.168.1.10:8080;
    server 192.168.1.11:8080;
    server 192.168.1.12:8080;
}
```

### Least Connections
Sends requests to the server with the fewest active connections.
```nginx
upstream backend {
    least_conn;
    server 192.168.1.10:8080;
    server 192.168.1.11:8080;
    server 192.168.1.12:8080;
}
```

### IP Hash
Routes requests from the same client IP to the same server (session persistence).
```nginx
upstream backend {
    ip_hash;
    server 192.168.1.10:8080;
    server 192.168.1.11:8080;
    server 192.168.1.12:8080;
}
```

### Weighted Load Balancing
Distribute more traffic to servers with higher weights.
```nginx
upstream backend {
    server 192.168.1.10:8080 weight=3;
    server 192.168.1.11:8080 weight=2;
    server 192.168.1.12:8080 weight=1;
}
```

## SSL/TLS Configuration

### Generate Self-Signed Certificate (Testing Only)
```bash
# Generate self-signed certificate
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/nginx-selfsigned.key \
  -out /etc/ssl/certs/nginx-selfsigned.crt

# You'll be prompted for certificate details
```

### Let's Encrypt SSL Certificate (Production)
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Obtain and install certificate
sudo certbot --nginx -d example.com -d www.example.com

# Verify automatic renewal
sudo certbot renew --dry-run

# Certificates will be automatically renewed by a cron job
```

### Strong SSL Configuration
```nginx
server {
    listen 443 ssl http2;
    server_name example.com;

    # SSL certificates
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

    # SSL protocols and ciphers
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers on;

    # SSL session cache
    ssl_session_cache shared:SSL:50m;
    ssl_session_timeout 1d;
    ssl_session_tickets off;

    # OCSP stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 8.8.8.8 8.8.4.4 valid=300s;
    resolver_timeout 5s;

    # Security headers
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
}
```

## Reverse Proxy Configuration

### Basic Reverse Proxy
```nginx
server {
    listen 80;
    server_name app.example.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Reverse Proxy for WebSocket
```nginx
server {
    listen 80;
    server_name ws.example.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

### Reverse Proxy with Multiple Backends
```nginx
server {
    listen 80;
    server_name example.com;

    # Frontend application
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
    }

    # API backend
    location /api/ {
        proxy_pass http://localhost:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # Static files
    location /static/ {
        alias /var/www/static/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

## Security Best Practices

### Hiding Nginx Version
```nginx
http {
    server_tokens off;
}
```

### Blocking Access to Hidden Files
```nginx
location ~ /\. {
    deny all;
    access_log off;
    log_not_found off;
}
```

### Rate Limiting and DDoS Protection
```nginx
# Limit connections per IP
limit_conn_zone $binary_remote_addr zone=conn_limit_per_ip:10m;

# Limit requests per IP
limit_req_zone $binary_remote_addr zone=req_limit_per_ip:10m rate=5r/s;

server {
    # Apply connection limit
    limit_conn conn_limit_per_ip 10;
    
    # Apply request rate limit
    limit_req zone=req_limit_per_ip burst=10 nodelay;
}
```

### Security Headers
```nginx
# Add security headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```

## Performance Optimization

### Enable Gzip Compression
```nginx
http {
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript 
               application/json application/javascript application/xml+rss 
               application/rss+xml font/truetype font/opentype 
               application/vnd.ms-fontobject image/svg+xml;
    gzip_disable "msie6";
}
```

### Static File Caching
```nginx
location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
    expires 30d;
    add_header Cache-Control "public, no-transform";
    access_log off;
}
```

### Buffer Size Optimization
```nginx
http {
    client_body_buffer_size 10K;
    client_header_buffer_size 1k;
    client_max_body_size 8m;
    large_client_header_buffers 2 1k;
}
```

### Worker Processes and Connections
```nginx
# Set to number of CPU cores
worker_processes auto;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}
```

### Timeouts
```nginx
http {
    keepalive_timeout 65;
    keepalive_requests 100;
    client_body_timeout 12;
    client_header_timeout 12;
    send_timeout 10;
}
```


## Managing Multiple Sites

### Enable a Site (Debian/Ubuntu)
```bash
# Create configuration in sites-available
sudo nano /etc/nginx/sites-available/example.com

# Create symbolic link to sites-enabled
sudo ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

### Disable a Site
```bash
# Remove symbolic link
sudo rm /etc/nginx/sites-enabled/example.com

# Reload Nginx
sudo systemctl reload nginx
```

### List Enabled Sites
```bash
ls -la /etc/nginx/sites-enabled/
```

## Monitoring and Troubleshooting

### Check Nginx Status
```bash
# Service status
sudo systemctl status nginx

# Check if Nginx is listening
sudo ss -tulpn | grep nginx
sudo netstat -tulpn | grep nginx
```

### View Logs
```bash
# View access logs
sudo tail -f /var/log/nginx/access.log

# View error logs
sudo tail -f /var/log/nginx/error.log

# View specific site logs
sudo tail -f /var/log/nginx/example.com.access.log
sudo tail -f /var/log/nginx/example.com.error.log

# Search for errors
sudo grep "error" /var/log/nginx/error.log
```

### Test Configuration
```bash
# Test configuration syntax
sudo nginx -t

# Test and display configuration
sudo nginx -T

# Check for configuration issues
sudo nginx -t -c /etc/nginx/nginx.conf
```

## Docker with Nginx

### Dockerfile for Custom Nginx Image
```dockerfile
FROM nginx:alpine

# Copy custom configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy static files
COPY html /usr/share/nginx/html

# Copy SSL certificates (if needed)
COPY certs /etc/ssl/certs

# Expose ports
EXPOSE 80 443

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
```

### Docker Compose with Nginx
```yaml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./html:/usr/share/nginx/html:ro
      - ./certs:/etc/ssl/certs:ro
      - ./logs:/var/log/nginx
    restart: unless-stopped

  app:
    image: node:20-alpine
    working_dir: /app
    volumes:
      - ./app:/app
    command: npm start
    expose:
      - "3000"
```


## Additional Resources

- [Official Nginx Documentation](https://nginx.org/en/docs/)
- [Nginx Admin Guide](https://docs.nginx.com/nginx/admin-guide/)
- [Nginx Configuration Generator](https://www.digitalocean.com/community/tools/nginx)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)

This comprehensive Nginx guide covers essential commands, configurations, and best practices for using Nginx as a web server, reverse proxy, and load balancer in DevOps environments!