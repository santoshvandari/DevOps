# Git & GitHub Guide

## What is Git?
Git is a distributed version control system that tracks changes in source code during software development. It allows multiple developers to work on the same project simultaneously without conflicts.

## What is GitHub?
GitHub is a cloud-based hosting service for Git repositories. It provides a web-based graphical interface and additional collaboration features like issue tracking, project management, and continuous integration.

## Essential Git Commands

### Repository Setup
```bash
# Initialize a new Git repository
git init

# Clone an existing repository
git clone <repository-url>

# Add remote repository
git remote add origin <repository-url>

# View remote repositories
git remote -v
```

### Basic Workflow
```bash
# Check repository status
git status

# Add files to staging area
git add <filename>          # Add specific file
git add .                   # Add all files
git add *.js               # Add all JavaScript files

# Commit changes
git commit -m "Commit message"
git commit -am "Add and commit in one step"

# Push changes to remote repository
git push origin main
git push -u origin main    # Set upstream and push
```

### Viewing History
```bash
# View commit history
git log
git log --oneline          # Compact view
git log --graph            # Show branch graph

# View changes
git diff                   # Show unstaged changes
git diff --staged          # Show staged changes
git diff HEAD~1            # Compare with previous commit
```

### Branch Management
```bash
# List branches
git branch                 # Local branches
git branch -r              # Remote branches
git branch -a              # All branches

# Create and switch branches
git branch <branch-name>   # Create branch
git checkout <branch-name> # Switch branch
git checkout -b <branch-name> # Create and switch

# Using git switch (newer command)
git switch <branch-name>
git switch -c <branch-name>

# Merge branches
git merge <branch-name>

# Delete branches
git branch -d <branch-name>     # Delete merged branch
git branch -D <branch-name>     # Force delete branch
```

### Remote Operations
```bash
# Fetch changes from remote
git fetch origin

# Pull changes (fetch + merge)
git pull origin main

# Push branch to remote
git push origin <branch-name>

# Set upstream branch
git push -u origin <branch-name>
```

### Undoing Changes
```bash
# Unstage files
git reset HEAD <filename>
git restore --staged <filename>

# Discard local changes
git checkout -- <filename>
git restore <filename>

# Reset commits
git reset --soft HEAD~1    # Keep changes staged
git reset --mixed HEAD~1   # Keep changes unstaged
git reset --hard HEAD~1    # Discard changes completely

# Revert a commit
git revert <commit-hash>
```

### Stashing
```bash
# Stash current changes
git stash
git stash push -m "Work in progress"

# List stashes
git stash list

# Apply stash
git stash apply            # Apply latest stash
git stash apply stash@{0}  # Apply specific stash

# Pop stash (apply and remove)
git stash pop

# Drop stash
git stash drop stash@{0}
```

## GitHub-Specific Workflow

### Setting up SSH Key
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Add SSH key to SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Test SSH connection
ssh -T git@github.com
```

### Working with Pull Requests
```bash
# Create feature branch
git checkout -b feature-branch

# Make changes and commit
git add .
git commit -m "Add new feature"

# Push to GitHub
git push origin feature-branch

# After PR is merged, update main branch
git checkout main
git pull origin main
git branch -d feature-branch
```

### Forking Workflow
```bash
# Clone your fork
git clone <your-fork-url>

# Add upstream remote
git remote add upstream <original-repo-url>

# Keep fork updated
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

## Advanced Git Commands

### Rebasing
```bash
# Interactive rebase
git rebase -i HEAD~3       # Rebase last 3 commits

# Rebase onto another branch
git rebase main

# Continue rebase after resolving conflicts
git rebase --continue

# Abort rebase
git rebase --abort
```

### Cherry-picking
```bash
# Apply specific commit to current branch
git cherry-pick <commit-hash>

# Cherry-pick without committing
git cherry-pick -n <commit-hash>
```

### Tagging
```bash
# Create lightweight tag
git tag v1.0.0

# Create annotated tag
git tag -a v1.0.0 -m "Version 1.0.0"

# Push tags to remote
git push origin --tags

# List tags
git tag -l
```

## Configuration
```bash
# Set global user information
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set default branch name
git config --global init.defaultBranch main

# Set default editor
git config --global core.editor "code --wait"

# View configuration
git config --list
git config --global --list
```

## Useful Aliases
Add these to your `~/.gitconfig` file:
```bash
[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    ca = commit -am
    ps = push
    pl = pull
    lg = log --oneline --graph --decorate --all
    unstage = reset HEAD --
    last = log -1 HEAD
```

## Best Practices

1. **Write meaningful commit messages** - Use imperative mood, keep first line under 50 characters
2. **Commit often** - Make small, logical commits
3. **Use branches** - Create feature branches for new work
4. **Pull before push** - Always pull latest changes before pushing
5. **Review changes** - Use `git diff` before committing
6. **Keep history clean** - Use rebase for feature branches when appropriate
7. **Use .gitignore** - Ignore files that shouldn't be tracked

## Common .gitignore Patterns
```gitignore
# Dependencies
node_modules/
*.log

# Build outputs
dist/
build/

# Environment files
.env
.env.local

# IDE files
.vscode/
.idea/

# OS generated files
.DS_Store
Thumbs.db
```

## Troubleshooting

### Common Issues
```bash
# Merge conflicts - edit files, then:
git add <resolved-files>
git commit

# Accidentally committed to wrong branch
git reset --soft HEAD~1
git stash
git checkout correct-branch
git stash pop

# Undo last commit but keep changes
git reset --soft HEAD~1

# Change last commit message
git commit --amend -m "New commit message"
```

This guide covers the most commonly used Git and GitHub commands. Practice these commands regularly to become proficient with version control!