# Setup SSL in Nginx using Let's Encrypt

A simple guide to secure your website with free SSL certificates from Let's Encrypt.

## Prerequisites

- A domain name pointing to your server's IP address
- Nginx installed and running
- Root or sudo access to your server
- Ports 80 and 443 open in your firewall

## Step 1: Install Certbot

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install certbot python3-certbot-nginx
```

### CentOS/RHEL
```bash
sudo yum install certbot python3-certbot-nginx
```

## Step 2: Configure Nginx (Basic Setup)

Create a basic Nginx configuration for your domain:

```bash
sudo nano /etc/nginx/sites-available/example.com
```

Add this configuration:

```nginx
server {
    listen 80;
    server_name example.com www.example.com;

    root /var/www/example.com/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

Enable the site:

```bash
# Create document root
sudo mkdir -p /var/www/example.com/html

# Create symbolic link (Ubuntu/Debian)
sudo ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

## Step 3: Obtain SSL Certificate

Run Certbot to automatically configure SSL:

```bash
sudo certbot --nginx -d example.com -d www.example.com

# Or Can use following that will generate only ssl certificate without modifying nginx config. You need to manually update nginx config later.
sudo certbot certonly --nginx -d example.com -d www.example.com

```


Follow the prompts:
1. Enter your email address (for renewal notifications)
2. Agree to terms of service (Y)
3. Choose whether to share your email (Y/N)
4. Select option 2 to redirect HTTP to HTTPS (recommended)

## Step 4: Verify SSL Configuration

Certbot automatically updates your Nginx configuration. Check the result:

```bash
sudo nano /etc/nginx/sites-available/example.com
```

Your configuration should now look like this:

```nginx
server {
    listen 80;
    server_name example.com www.example.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name example.com www.example.com;

    root /var/www/example.com/html;
    index index.html;

    # SSL certificate managed by Certbot
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

## Step 5: Test Your SSL Certificate

Visit your website:
```
https://example.com
```

Or use SSL Labs to check your SSL configuration:
```
https://www.ssllabs.com/ssltest/analyze.html?d=example.com
```

## Step 6: Verify Auto-Renewal

Let's Encrypt certificates expire after 90 days. Certbot automatically sets up renewal.

Test the renewal process:
```bash
sudo certbot renew --dry-run
```

If successful, you'll see:
```
Congratulations, all simulated renewals succeeded
```

Check renewal timer status:
```bash
sudo systemctl status certbot.timer
```

## Manual Certificate Renewal

If needed, manually renew certificates:

```bash
# Renew all certificates
sudo certbot renew

# Renew specific certificate
sudo certbot renew --cert-name example.com

# Renew and reload Nginx
sudo certbot renew --deploy-hook "systemctl reload nginx"
```

## SSL Configuration for Reverse Proxy

If you're using Nginx as a reverse proxy:

```nginx
server {
    listen 80;
    server_name app.example.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name app.example.com;

    ssl_certificate /etc/letsencrypt/live/app.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/app.example.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## Common Certbot Commands

```bash
# List all certificates
sudo certbot certificates

# Delete a certificate
sudo certbot delete --cert-name example.com

# Expand certificate (add more domains)
sudo certbot --nginx -d example.com -d www.example.com -d api.example.com

# Revoke a certificate
sudo certbot revoke --cert-path /etc/letsencrypt/live/example.com/cert.pem
```

## Troubleshooting

### Port 80 not accessible
```bash
# Check if port 80 is open
sudo ufw allow 80
sudo ufw allow 443

# For firewalld
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

### Domain not pointing to server
```bash
# Check DNS resolution
nslookup example.com
dig example.com
```

### Certificate renewal fails
```bash
# Check Certbot logs
sudo tail -f /var/log/letsencrypt/letsencrypt.log

# Test Nginx configuration
sudo nginx -t

# Ensure Certbot timer is active
sudo systemctl status certbot.timer
```

### Manual certificate generation (without Nginx plugin)
```bash
# Use standalone mode (stops Nginx temporarily)
sudo systemctl stop nginx
sudo certbot certonly --standalone -d example.com -d www.example.com
sudo systemctl start nginx
```

## Certificate Locations

Let's Encrypt stores certificates in:
```
/etc/letsencrypt/live/example.com/
├── fullchain.pem    # Certificate + Chain (use this in nginx)
├── privkey.pem      # Private key (use this in nginx)
├── cert.pem         # Certificate only
└── chain.pem        # Chain only
```

## Rate Limits

Let's Encrypt has rate limits:
- 50 certificates per registered domain per week
- 5 duplicate certificates per week
- 100 subdomains per certificate

For testing, use the staging environment:
```bash
sudo certbot --nginx --staging -d example.com
```

## Complete Example: From Scratch

```bash
# 1. Update system
sudo apt update

# 2. Install Nginx
sudo apt install nginx

# 3. Install Certbot
sudo apt install certbot python3-certbot-nginx

# 4. Create basic configuration
sudo nano /etc/nginx/sites-available/mysite.com

# Add basic server block (see Step 2)

# 5. Enable site
sudo ln -s /etc/nginx/sites-available/mysite.com /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# 6. Get SSL certificate
sudo certbot --nginx -d mysite.com -d www.mysite.com

# 7. Test auto-renewal
sudo certbot renew --dry-run

# Done! Your site is now secured with SSL.
```
