# Auto Deploy on PR Merge to Main

This GitHub Actions workflow automatically deploys your application to production when a Pull Request is merged into the `main` branch.

## Setup Instructions

### 1. Add Workflow File

The workflow file should be placed at:
```
.github/workflows/main.yml
```

### 2. Configure GitHub Secrets

Go to your repository → Settings → Secrets and variables → Actions → New repository secret

Add the following secrets:

```
DEPLOY_KEY         - SSH private key for server access
SERVER_HOST        - Your server hostname (e.g., server.example.com)
SERVER_USER        - SSH username (e.g., deploy or ubuntu)
```

**Optional secrets (depending on deployment method):**
```
DOCKER_USERNAME    - Docker Hub username
DOCKER_PASSWORD    - Docker Hub password/token
VERCEL_TOKEN       - Vercel deployment token
NETLIFY_AUTH_TOKEN - Netlify authentication token
NETLIFY_SITE_ID    - Netlify site ID
AWS_ACCESS_KEY_ID  - AWS access key
AWS_SECRET_ACCESS_KEY - AWS secret key
```

### 3. Prepare Deployment Script

Create `script.sh` in your repository root with your deployment logic.

Make it executable:
```bash
chmod +x script.sh
```

### 4. How It Works

1. Developer creates a Pull Request to `main` branch
2. Code review and approval process
3. PR is merged into `main` branch
4. GitHub Actions workflow is triggered
5. Workflow checks out the code
6. Runs the deployment script
7. Application is deployed to production

## Workflow Triggers

The workflow runs when:
- ✅ Pull Request is **merged** into `main` branch
- ✅ Direct push to `main` branch

The workflow does NOT run when:
- ❌ Pull Request is created (but not merged)
- ❌ Pull Request is closed without merging

## Example Usage

### Create a Pull Request
```bash
# Create feature branch
git checkout -b feature/new-feature

# Make changes and commit
git add .
git commit -m "Add new feature"

# Push to GitHub
git push origin feature/new-feature
```

### Merge Pull Request
1. Go to GitHub and create Pull Request
2. Request review from team members
3. Once approved, click "Merge pull request"
4. Deployment will automatically start

## Deployment Methods

The `script.sh` includes examples for multiple deployment methods:

### 1. SSH Deployment
```bash
deploy_ssh()  # Deploy via SSH and run commands on server
```

### 2. Docker Deployment
```bash
deploy_docker()  # Build and deploy Docker container
```

### 3. Cloud Platforms
```bash
deploy_vercel()  # Deploy to Vercel
deploy_netlify() # Deploy to Netlify
deploy_aws()     # Deploy to AWS S3
```

### 4. File Transfer
```bash
deploy_scp()    # Copy files using SCP
deploy_rsync()  # Sync files using rsync
```

## Customize Your Deployment

Edit `script.sh` and uncomment your preferred deployment method in the `main()` function:

```bash
main() {
    # Choose your deployment method
    deploy_ssh          # SSH deployment
    # deploy_docker     # Docker deployment
    # deploy_vercel     # Vercel deployment
    # deploy_netlify    # Netlify deployment
}
```

## Monitoring Deployment

### View Workflow Status
1. Go to your repository on GitHub
2. Click on "Actions" tab
3. Click on the workflow run
4. View logs and status

### Deployment Status Badge
Add to your README.md:
```markdown
![Deploy](https://github.com/username/repo/workflows/Deploy%20to%20Production/badge.svg)
```

## Security Best Practices

✅ Never commit secrets or credentials to the repository  
✅ Always use GitHub Secrets for sensitive data  
✅ Use SSH keys instead of passwords  
✅ Limit SSH key permissions to deployment only  
✅ Use environment protection rules for production  
✅ Enable required reviewers for PRs to main branch  
✅ Use deployment branches protection  

## Rollback Strategy

If deployment fails or issues are found:

```bash
# Revert the merge commit
git revert -m 1 <merge-commit-hash>

# Push to main
git push origin main

# This will trigger a new deployment with the previous working code
```

## Testing Before Production

Consider adding a staging environment:

```yaml
on:
  push:
    branches:
      - develop    # Deploy to staging
      - main       # Deploy to production
```

## Common Issues

### Issue: Script not executable
**Solution:** Make sure to run `chmod +x script.sh` before committing

### Issue: SSH connection fails
**Solution:** 
- Verify SERVER_HOST is correct
- Check SSH key is valid
- Add server to known_hosts

### Issue: Deployment script fails
**Solution:** 
- Check script.sh logs in Actions tab
- Verify all required environment variables are set
- Test script locally first

## Example: Complete Setup

```bash
# 1. Create workflow directory
mkdir -p .github/workflows

# 2. Copy workflow file
cp main.yml .github/workflows/

# 3. Create deployment script
touch script.sh
chmod +x script.sh

# 4. Edit script.sh with your deployment logic

# 5. Commit and push
git add .
git commit -m "Add deployment workflow"
git push origin main

# 6. Add secrets in GitHub repository settings

# 7. Create a PR and merge to test deployment
```

Your automatic deployment is now ready! 🚀
