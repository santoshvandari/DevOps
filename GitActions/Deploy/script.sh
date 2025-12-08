#!/bin/bash

# Deployment Script for Production
# This script is triggered by GitHub Actions when PR is merged to main

set -e  # Exit on error

echo "🚀 Starting deployment to production..."

# Configuration (use environment variables from GitHub Secrets)
DEPLOY_KEY="${DEPLOY_KEY}"
SERVER_HOST="${SERVER_HOST:-your-server.com}"
SERVER_USER="${SERVER_USER:-deploy}"
APP_DIR="/var/www/myapp"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored messages
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Example 1: Deploy using SSH
deploy_ssh() {
    log_info "Deploying via SSH to ${SERVER_HOST}..."
    
    # Setup SSH key
    mkdir -p ~/.ssh
    echo "$DEPLOY_KEY" > ~/.ssh/deploy_key
    chmod 600 ~/.ssh/deploy_key
    
    # Add server to known hosts
    ssh-keyscan -H $SERVER_HOST >> ~/.ssh/known_hosts
    
    # Deploy commands
    ssh -i ~/.ssh/deploy_key ${SERVER_USER}@${SERVER_HOST} << 'EOF'
        cd /var/www/myapp
        git pull origin main
        npm install --production
        npm run build
        pm2 restart myapp
        echo "Deployment completed successfully!"
EOF
    
    log_info "SSH deployment completed!"
}

# Example 2: Deploy using SCP
deploy_scp() {
    log_info "Deploying using SCP..."
    
    # Setup SSH key
    mkdir -p ~/.ssh
    echo "$DEPLOY_KEY" > ~/.ssh/deploy_key
    chmod 600 ~/.ssh/deploy_key
    
    # Copy files to server
    scp -i ~/.ssh/deploy_key -r ./dist/* ${SERVER_USER}@${SERVER_HOST}:${APP_DIR}/
    
    # Restart service
    ssh -i ~/.ssh/deploy_key ${SERVER_USER}@${SERVER_HOST} "sudo systemctl restart myapp"
    
    log_info "SCP deployment completed!"
}

# Example 3: Deploy to Docker
deploy_docker() {
    log_info "Deploying Docker container..."
    
    # Login to Docker Hub (if needed)
    if [ ! -z "$DOCKER_USERNAME" ] && [ ! -z "$DOCKER_PASSWORD" ]; then
        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
    fi
    
    # Build Docker image
    docker build -t myapp:latest .
    docker tag myapp:latest username/myapp:latest
    
    # Push to registry
    docker push username/myapp:latest
    
    # Deploy to server
    ssh -i ~/.ssh/deploy_key ${SERVER_USER}@${SERVER_HOST} << 'EOF'
        docker pull username/myapp:latest
        docker stop myapp || true
        docker rm myapp || true
        docker run -d --name myapp -p 80:3000 username/myapp:latest
EOF
    
    log_info "Docker deployment completed!"
}

# Example 4: Deploy to Vercel
deploy_vercel() {
    log_info "Deploying to Vercel..."
    
    # Install Vercel CLI
    npm install -g vercel
    
    # Deploy to production
    vercel --prod --token=$VERCEL_TOKEN --yes
    
    log_info "Vercel deployment completed!"
}

# Example 5: Deploy to Netlify
deploy_netlify() {
    log_info "Deploying to Netlify..."
    
    # Install Netlify CLI
    npm install -g netlify-cli
    
    # Deploy to production
    netlify deploy --prod --dir=./dist --auth=$NETLIFY_AUTH_TOKEN --site=$NETLIFY_SITE_ID
    
    log_info "Netlify deployment completed!"
}

# Example 6: Deploy to AWS S3 + CloudFront
deploy_aws() {
    log_info "Deploying to AWS S3..."
    
    # Install AWS CLI (if not installed)
    which aws || pip install awscli
    
    # Sync files to S3
    aws s3 sync ./dist s3://your-bucket-name --delete
    
    # Invalidate CloudFront cache
    aws cloudfront create-invalidation --distribution-id YOUR_DISTRIBUTION_ID --paths "/*"
    
    log_info "AWS deployment completed!"
}

# Example 7: Deploy to GitHub Pages
deploy_github_pages() {
    log_info "Deploying to GitHub Pages..."
    
    # Build the project
    npm run build
    
    # Deploy to gh-pages branch
    npx gh-pages -d dist
    
    log_info "GitHub Pages deployment completed!"
}

# Example 8: Deploy using rsync
deploy_rsync() {
    log_info "Deploying using rsync..."
    
    # Setup SSH key
    mkdir -p ~/.ssh
    echo "$DEPLOY_KEY" > ~/.ssh/deploy_key
    chmod 600 ~/.ssh/deploy_key
    
    # Rsync files to server
    rsync -avz -e "ssh -i ~/.ssh/deploy_key" \
        --exclude 'node_modules' \
        --exclude '.git' \
        --exclude '.env' \
        ./dist/ ${SERVER_USER}@${SERVER_HOST}:${APP_DIR}/
    
    # Restart application
    ssh -i ~/.ssh/deploy_key ${SERVER_USER}@${SERVER_HOST} "cd ${APP_DIR} && pm2 restart all"
    
    log_info "Rsync deployment completed!"
}

# Main deployment logic
main() {
    log_info "Deployment started at $(date)"
    
    # Choose your deployment method
    # Uncomment the method you want to use
    
    deploy_ssh          # SSH deployment
    # deploy_scp        # SCP deployment
    # deploy_docker     # Docker deployment
    # deploy_vercel     # Vercel deployment
    # deploy_netlify    # Netlify deployment
    # deploy_aws        # AWS S3 deployment
    # deploy_github_pages  # GitHub Pages deployment
    # deploy_rsync      # Rsync deployment
    
    log_info "✅ Deployment completed successfully at $(date)"
}

# Run main function
main

# Exit successfully
exit 0
