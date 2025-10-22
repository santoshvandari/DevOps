# GitHub Actions Guide

## What is GitHub Actions?

GitHub Actions is a CI/CD platform that automates your software workflows. It allows you to build, test, and deploy your code directly from GitHub.

## Key Concepts

**Workflow** - An automated process defined in a YAML file  
**Event** - Activity that triggers a workflow (push, pull request, etc.)  
**Job** - A set of steps that execute on the same runner  
**Step** - Individual task that runs commands or actions  
**Action** - Reusable unit of code that performs a specific task  
**Runner** - Server that runs your workflows (GitHub-hosted or self-hosted)

## Getting Started

### 1. Create Workflow File

Create a directory in your repository:
```
.github/workflows/
```

Add a workflow file (e.g., `main.yml`):
```
.github/workflows/main.yml
```

### 2. Basic Workflow Structure

```yaml
name: Workflow Name
on: [push]
jobs:
  job-name:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run a command
        run: echo "Hello, World!"
```

## Common Triggers (Events)

```yaml
# Trigger on push to main branch
on:
  push:
    branches: [ main ]

# Trigger on pull request
on:
  pull_request:
    branches: [ main ]

# Trigger on multiple events
on: [push, pull_request]

# Trigger manually
on: workflow_dispatch

# Trigger on schedule (cron)
on:
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight

# Trigger on specific paths
on:
  push:
    paths:
      - 'src/**'
      - '!src/tests/**'
```

## Basic Examples

### Hello World Workflow

```yaml
name: Hello World
on: [push]
jobs:
  hello:
    runs-on: ubuntu-latest
    steps:
      - name: Print greeting
        run: echo "Hello, World!"
```

### Node.js CI Workflow

```yaml
name: Node.js CI
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: npm install
      
      - name: Run tests
        run: npm test
      
      - name: Build project
        run: npm run build
```

### Python CI Workflow

```yaml
name: Python CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
      
      - name: Run tests
        run: pytest
```

### Docker Build and Push

```yaml
name: Docker Build
on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: username/app:latest
```

### Deploy to Server (SSH)

```yaml
name: Deploy to Server
on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy via SSH
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            cd /var/www/myapp
            git pull origin main
            npm install
            npm run build
            pm2 restart myapp
```

## Multiple Jobs

```yaml
name: Multi-Job Workflow
on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: npm test
  
  build:
    needs: test  # Wait for test job to complete
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build
        run: npm run build
  
  deploy:
    needs: build  # Wait for build job to complete
    runs-on: ubuntu-latest
    steps:
      - name: Deploy
        run: echo "Deploying..."
```

## Matrix Strategy (Multiple Versions)

```yaml
name: Matrix Build
on: [push]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        node-version: [16, 18, 20]
    
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
      - run: npm install
      - run: npm test
```

## Using Secrets

### Add Secrets in GitHub:
1. Go to repository → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add name and value
4. Click "Add secret"

### Use Secrets in Workflow:
```yaml
steps:
  - name: Use secret
    env:
      API_KEY: ${{ secrets.API_KEY }}
    run: echo "Using API key..."
```

## Environment Variables

```yaml
env:
  NODE_ENV: production
  API_URL: https://api.example.com

jobs:
  build:
    runs-on: ubuntu-latest
    env:
      DATABASE_URL: ${{ secrets.DATABASE_URL }}
    
    steps:
      - name: Use environment variable
        run: echo "API URL is $API_URL"
      
      - name: Step-level environment variable
        env:
          DEBUG: true
        run: echo "Debug mode is $DEBUG"
```

## Artifacts (Save Files)

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build
        run: npm run build
      
      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: build-files
          path: dist/
  
  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Download artifact
        uses: actions/download-artifact@v4
        with:
          name: build-files
          path: dist/
      
      - name: Deploy
        run: echo "Deploying files from dist/"
```

## Conditional Execution

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to production
        if: github.ref == 'refs/heads/main'
        run: echo "Deploying to production"
      
      - name: Deploy to staging
        if: github.ref == 'refs/heads/develop'
        run: echo "Deploying to staging"
      
      - name: Run only on PR
        if: github.event_name == 'pull_request'
        run: echo "Running on pull request"
```

## Caching Dependencies

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Cache node modules
        uses: actions/cache@v4
        with:
          path: ~/.npm
          key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
          restore-keys: |
            ${{ runner.os }}-node-
      
      - name: Install dependencies
        run: npm install
```

## Useful Actions

```yaml
# Checkout repository
- uses: actions/checkout@v4

# Setup Node.js
- uses: actions/setup-node@v4
  with:
    node-version: '18'

# Setup Python
- uses: actions/setup-python@v4
  with:
    python-version: '3.11'

# Setup Java
- uses: actions/setup-java@v4
  with:
    java-version: '17'
    distribution: 'temurin'

# Setup Go
- uses: actions/setup-go@v4
  with:
    go-version: '1.21'

# Cache dependencies
- uses: actions/cache@v4

# Upload artifacts
- uses: actions/upload-artifact@v4

# Download artifacts
- uses: actions/download-artifact@v4

# Create release
- uses: actions/create-release@v1

# Deploy to GitHub Pages
- uses: peaceiris/actions-gh-pages@v3
```

## Common Commands

```bash
# View workflow runs
# Go to: Repository → Actions

# Re-run a workflow
# Click on workflow run → Re-run jobs

# Cancel a workflow
# Click on workflow run → Cancel workflow

# View logs
# Click on workflow run → Click on job → View logs

# Download artifacts
# Click on workflow run → Artifacts section
```

## Example: Complete CI/CD Pipeline

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  NODE_VERSION: '18'

jobs:
  test:
    name: Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
      
      - name: Cache dependencies
        uses: actions/cache@v4
        with:
          path: ~/.npm
          key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run linter
        run: npm run lint
      
      - name: Run tests
        run: npm test
  
  build:
    name: Build
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
      
      - name: Install dependencies
        run: npm ci
      
      - name: Build
        run: npm run build
      
      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist/
  
  deploy:
    name: Deploy
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Download build artifacts
        uses: actions/download-artifact@v4
        with:
          name: dist
          path: dist/
      
      - name: Deploy to production
        run: echo "Deploying to production server..."
```
