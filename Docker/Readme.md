# Docker Guide

## What is Docker?
Docker is a platform that uses containerization technology to package applications and their dependencies into lightweight, portable containers. It ensures that applications run consistently across different environments, from development to production.

## Key Concepts

### Container
A lightweight, standalone executable package that includes everything needed to run an application: code, runtime, system tools, libraries, and settings.

### Image
A read-only template used to create containers. Images are built from a Dockerfile and can be shared via registries like Docker Hub.

### Dockerfile
A text file containing instructions to build a Docker image automatically.

### Registry
A service for storing and distributing Docker images (e.g., Docker Hub, AWS ECR, Google Container Registry).

## Installation and Setup

### Install Docker (Ubuntu/Debian)
```bash
# Update package index
sudo apt update

# Install prerequisites
sudo apt install apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io

# Add user to docker group (to run without sudo)
sudo usermod -aG docker $USER
```

### Post-Installation Setup
```bash
# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Verify installation
docker --version
docker run hello-world
```

## Essential Docker Commands

### Image Management
```bash
# List local images
docker images
docker image ls

# Pull image from registry
docker pull ubuntu:20.04
docker pull nginx:latest

# Build image from Dockerfile
docker build -t myapp:1.0 .
docker build -t myapp:latest --file Dockerfile.prod .

# Remove images
docker rmi <image-id>
docker rmi myapp:1.0
docker image prune          # Remove unused images
docker image prune -a       # Remove all unused images
```

### Container Operations
```bash
# Run containers
docker run ubuntu:20.04
docker run -it ubuntu:20.04 /bin/bash    # Interactive mode
docker run -d nginx:latest               # Detached mode
docker run -p 8080:80 nginx:latest       # Port mapping
docker run --name mycontainer nginx      # Custom name

# List containers
docker ps                    # Running containers
docker ps -a                 # All containers
docker container ls          # Alternative syntax

# Start/Stop containers
docker start <container-id>
docker stop <container-id>
docker restart <container-id>

# Execute commands in running container
docker exec -it <container-id> /bin/bash
docker exec <container-id> ls -la

# View container logs
docker logs <container-id>
docker logs -f <container-id>    # Follow logs
docker logs --tail 50 <container-id>
```

### Container Cleanup
```bash
# Remove containers
docker rm <container-id>
docker rm $(docker ps -aq)      # Remove all stopped containers
docker container prune          # Remove all stopped containers

# Kill running containers
docker kill <container-id>

# Remove everything (containers, images, networks, volumes)
docker system prune
docker system prune -a          # Include unused images
docker system prune --volumes   # Include volumes
```

## Working with Dockerfiles

### Basic Dockerfile
```dockerfile
# Use official base image
FROM node:16-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Expose port
EXPOSE 3000

# Define startup command
CMD ["npm", "start"]
```

### Multi-stage Dockerfile
```dockerfile
# Build stage
FROM node:16-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Dockerfile Best Practices
```dockerfile
# Use specific tags, not 'latest'
FROM node:16.14.2-alpine

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

# Use .dockerignore
# Copy package files first for better caching
COPY package*.json ./
RUN npm ci --only=production

# Set user
USER nextjs

# Use COPY instead of ADD
COPY --chown=nextjs:nodejs . .
```

## Docker Compose

### Basic docker-compose.yml
```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      - db
    volumes:
      - .:/app
      - /app/node_modules

  db:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:6-alpine
    ports:
      - "6379:6379"

volumes:
  postgres_data:
```

### Docker Compose Commands
```bash
# Start services
docker-compose up
docker-compose up -d            # Detached mode
docker-compose up --build       # Force rebuild

# Stop services
docker-compose down
docker-compose down -v          # Remove volumes
docker-compose down --rmi all   # Remove images

# View running services
docker-compose ps

# View logs
docker-compose logs
docker-compose logs web         # Specific service
docker-compose logs -f          # Follow logs

# Execute commands
docker-compose exec web bash
docker-compose run web npm test

# Scale services
docker-compose up --scale web=3
```

## Volume Management

### Volume Commands
```bash
# Create volume
docker volume create myvolume

# List volumes
docker volume ls

# Inspect volume
docker volume inspect myvolume

# Remove volumes
docker volume rm myvolume
docker volume prune             # Remove unused volumes

# Use volumes with containers
docker run -v myvolume:/data ubuntu
docker run -v /host/path:/container/path ubuntu    # Bind mount
docker run -v $(pwd):/app ubuntu                   # Current directory
```

### Volume Types
```bash
# Named volume
docker run -v mydata:/data mysql

# Bind mount (absolute path)
docker run -v /home/user/data:/data mysql

# Bind mount (relative path)
docker run -v $(pwd)/data:/data mysql

# Anonymous volume
docker run -v /data mysql
```

## Network Management

### Network Commands
```bash
# List networks
docker network ls

# Create network
docker network create mynetwork
docker network create --driver bridge mybridge

# Inspect network
docker network inspect mynetwork

# Connect container to network
docker network connect mynetwork mycontainer

# Disconnect container from network
docker network disconnect mynetwork mycontainer

# Remove network
docker network rm mynetwork
docker network prune           # Remove unused networks
```

### Running containers with custom networks
```bash
# Create and use custom network
docker network create app-network
docker run -d --name db --network app-network postgres
docker run -d --name web --network app-network -p 8080:80 nginx
```

## Registry Operations

### Docker Hub
```bash
# Login to Docker Hub
docker login

# Tag image for registry
docker tag myapp:latest username/myapp:latest
docker tag myapp:latest username/myapp:1.0

# Push to registry
docker push username/myapp:latest
docker push username/myapp:1.0

# Pull from registry
docker pull username/myapp:latest

# Logout
docker logout
```

### Private Registry
```bash
# Tag for private registry
docker tag myapp:latest registry.company.com/myapp:latest

# Push to private registry
docker push registry.company.com/myapp:latest

# Pull from private registry
docker pull registry.company.com/myapp:latest
```

## Monitoring and Debugging

### Container Information
```bash
# View container details
docker inspect <container-id>

# View container processes
docker top <container-id>

# View container resource usage
docker stats
docker stats <container-id>

# View container filesystem changes
docker diff <container-id>
```

### Debugging
```bash
# Access container shell
docker exec -it <container-id> /bin/bash
docker exec -it <container-id> /bin/sh

# Copy files to/from container
docker cp file.txt <container-id>:/path/to/destination
docker cp <container-id>:/path/to/file.txt ./local/path

# View container logs
docker logs <container-id>
docker logs -f --tail 100 <container-id>

# Attach to running container
docker attach <container-id>
```

## Environment Variables and Secrets

### Environment Variables
```bash
# Set environment variables
docker run -e NODE_ENV=production myapp
docker run -e DB_HOST=localhost -e DB_PORT=5432 myapp

# Use environment file
docker run --env-file .env myapp

# In docker-compose.yml
services:
  web:
    environment:
      - NODE_ENV=production
      - DB_HOST=db
    env_file:
      - .env
```

### Example .env file
```bash
NODE_ENV=production
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp
DB_USER=admin
DB_PASSWORD=secret123
```

## Health Checks

### Dockerfile Health Check
```dockerfile
FROM nginx:alpine

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# Alternative health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1
```

### Docker Compose Health Check
```yaml
services:
  web:
    image: nginx:alpine
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

## Performance Optimization

### Image Optimization
```dockerfile
# Use multi-stage builds
FROM node:16-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:16-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
CMD ["node", "server.js"]

# Use .dockerignore
# Add to .dockerignore file:
node_modules
.git
.gitignore
README.md
.env
.nyc_output
coverage
.npm
```

### Resource Limits
```bash
# Set memory limit
docker run -m 512m nginx

# Set CPU limit
docker run --cpus="1.5" nginx

# Set both memory and CPU
docker run -m 1g --cpus="2" nginx

# In docker-compose.yml
services:
  web:
    image: nginx
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
        reservations:
          memory: 256M
          cpus: '0.25'
```

## Security Best Practices

### Dockerfile Security
```dockerfile
# Use non-root user
FROM node:16-alpine
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs

# Use specific versions
FROM node:16.14.2-alpine

# Scan for vulnerabilities
# docker scan myimage:latest

# Use minimal base images
FROM alpine:3.15
FROM scratch
FROM distroless/nodejs
```

### Runtime Security
```bash
# Run container as read-only
docker run --read-only nginx

# Drop capabilities
docker run --cap-drop ALL nginx

# Run with no new privileges
docker run --security-opt no-new-privileges nginx

# Use user namespace
docker run --user 1000:1000 nginx
```

## Useful Aliases

Add these to your `~/.bashrc` or `~/.zshrc`:
```bash
# Docker aliases
alias d='docker'
alias dc='docker-compose'
alias di='docker images'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias drm='docker rm'
alias drmi='docker rmi'
alias dexec='docker exec -it'
alias dlogs='docker logs -f'

# Docker cleanup aliases
alias dclean='docker system prune -af'
alias dcleanv='docker system prune -af --volumes'
alias dcleani='docker image prune -af'
alias dcleanc='docker container prune -f'
```

## Common Docker Patterns

### Development Environment
```yaml
# docker-compose.dev.yml
version: '3.8'
services:
  app:
    build: .
    volumes:
      - .:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
    command: npm run dev
```

### Production Deployment
```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  app:
    image: myapp:latest
    restart: unless-stopped
    environment:
      - NODE_ENV=production
    ports:
      - "80:3000"
    depends_on:
      - db
    
  db:
    image: postgres:13
    restart: unless-stopped
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER_FILE: /run/secrets/db_user
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    volumes:
      - db_data:/var/lib/postgresql/data
    secrets:
      - db_user
      - db_password

secrets:
  db_user:
    file: ./db_user.txt
  db_password:
    file: ./db_password.txt

volumes:
  db_data:
```

## Troubleshooting Common Issues

### Permission Issues
```bash
# Fix permission issues
sudo chown -R $USER:$USER /path/to/directory

# Run container with current user
docker run -u $(id -u):$(id -g) myimage

# In docker-compose.yml
services:
  app:
    user: "${UID}:${GID}"
```

### Port Conflicts
```bash
# Check what's using a port
sudo lsof -i :8080
sudo netstat -tulpn | grep 8080

# Use different port mapping
docker run -p 8081:80 nginx
```

### Container Won't Start
```bash
# Check container logs
docker logs <container-id>

# Check container configuration
docker inspect <container-id>
or docker inspect <container-name>


# Try running interactively
docker run -it myimage /bin/bash
```

### Out of Disk Space
```bash
# Clean up Docker system
docker system prune -a
docker volume prune
docker network prune

# Check disk usage
docker system df

# Remove specific items
docker container prune
docker image prune -a
```

This comprehensive Docker guide covers the essential commands and concepts you'll need for containerizing applications and managing Docker environments effectively!