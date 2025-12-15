# GitHub Rulesets - Automation & Configuration

This directory contains the automation scripts and configuration templates for managing GitHub Rulesets across your repositories.

## 📁 Contents

- **Set-Rulesets.ps1** - PowerShell automation script for applying rulesets to repositories
- **Main Branch Ruleset.json** - Reference configuration file showing the complete ruleset structure
- **github-branch-protection-and-status-checks.md** - Comprehensive setup guide and documentation

---

## 🚀 Quick Start

### Apply rulesets to all your repositories:

```powershell
.\Set-Rulesets.ps1 -ApplyToAll
```

### Apply to specific repositories:

```powershell
.\Set-Rulesets.ps1 -Repos "owner/repo1", "owner/repo2"
```

### Interactive mode:

```powershell
.\Set-Rulesets.ps1
```

---

## 📋 What the Script Does

The `Set-Rulesets.ps1` script automates GitHub Ruleset configuration:

1. **Fetches your repositories** - Lists all repos you have access to (or uses specified repos)
2. **Detects default branch** - Automatically identifies `main`, `master`, or other default branch
3. **Checks for existing rulesets** - Skips repos that already have rulesets to preserve custom configurations
4. **Creates new rulesets** - Applies the standard ruleset only to repos that don't have one
5. **Shows results** - Displays success/failure count and summary

### Key Features

- ✅ **Safe by default** - Skips repos with existing rulesets instead of overwriting
- ✅ **Batch processing** - Apply to all or multiple repos in one command
- ✅ **Interactive confirmation** - Shows what will be applied before executing
- ✅ **Automatic branch detection** - Works with any default branch name
- ✅ **Clear feedback** - Color-coded output shows exactly what's happening

---

## 🔧 Ruleset Configuration

### Rules Applied

The script applies these branch protection rules:

| Rule | Purpose |
|------|---------|
| **Block force pushes** | Protects git history from being rewritten |
| **Require pull requests** | Prevents direct commits to main/master |
| **Dismiss stale reviews** | Auto-dismisses outdated reviews when new commits are pushed |
| **Conversation resolution** | Requires discussions to be resolved before merging |
| **Flexible merging** | Allows merge, squash, and rebase strategies |

### Rules NOT Applied

The script deliberately does NOT apply:

- ❌ Restrict branch creation (allows free branching)
- ❌ Restrict branch updates (allows PR merges)
- ❌ Restrict branch deletion (allows cleanup)
- ❌ Require pull request approvals (designed for solo developers)

### Configuration Structure

See `Main Branch Ruleset.json` for the complete JSON structure. Key elements:

```json
{
  "name": "Main Branch Ruleset",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["refs/heads/main"]
    }
  },
  "rules": [
    { "type": "non_fast_forward" },
    { 
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 0,
        "dismiss_stale_reviews_on_push": true,
        "required_review_thread_resolution": true,
        "allowed_merge_methods": ["merge", "squash", "rebase"]
      }
    }
  ]
}
```

---

## 📖 Usage Examples

### Example 1: Apply to Single Repository

```powershell
.\Set-Rulesets.ps1 -Repos "J-MaFf/my-project"
```

Output:
```
Processing J-MaFf/my-project...
  Default branch: main
  ✓ Ruleset applied

========================================
Summary
========================================
Success: 1
Failed: 0

Done!
```

### Example 2: Apply to Multiple Repositories

```powershell
.\Set-Rulesets.ps1 -Repos "J-MaFf/project1", "J-MaFf/project2", "J-MaFf/project3"
```

### Example 3: Apply to All Repositories (with confirmation)

```powershell
.\Set-Rulesets.ps1 -ApplyToAll
```

The script will:
1. Fetch all your repositories
2. Show what will be applied
3. Ask for confirmation before proceeding
4. Display progress for each repo

### Example 4: Skip Existing Rulesets

When you run the script on a repo that already has a ruleset:

```
Processing J-MaFf/existing-ruleset...
  Default branch: main
  ⊘ Ruleset already exists (ID: 11141895), skipping to preserve custom configuration
```

This preserves any custom configurations (like status checks) you've added manually.

---

## ✅ Prerequisites

### System Requirements

- **PowerShell** 5.0 or later
- **GitHub CLI (`gh`)** installed and authenticated
- Admin access to repositories you want to protect

### Setup

1. **Install GitHub CLI:**
   ```powershell
   # Using winget
   winget install GitHub.cli
   
   # Or download from https://cli.github.com
   ```

2. **Authenticate with GitHub:**
   ```powershell
   gh auth login
   ```

3. **Verify authentication:**
   ```powershell
   gh auth status
   ```

---

## 🛠️ Advanced Usage

### Custom Repository List

Create a PowerShell array and pass it to the script:

```powershell
$repos = @(
    "J-MaFf/repo1",
    "J-MaFf/repo2",
    "J-MaFf/repo3"
)

.\Set-Rulesets.ps1 -Repos $repos
```

### Pipeline Input

Use PowerShell pipeline:

```powershell
@("J-MaFf/repo1", "J-MaFf/repo2") | .\Set-Rulesets.ps1
```

### Check What Would Happen

Run in interactive mode to review each step:

```powershell
.\Set-Rulesets.ps1
```

This lets you add repos one at a time and review before applying.

---

## ⚠️ Troubleshooting

### Script reports "Failed" for a repository

**Causes:**
- Not authenticated with GitHub
- Insufficient permissions on the repository
- Repository doesn't exist or name is incorrect

**Solution:**
```powershell
# Check authentication
gh auth status

# Verify repo exists
gh repo view owner/repo
```

### "gh api" command fails

**Solution:**
```powershell
# Verify gh CLI is installed
gh --version

# Re-authenticate
gh auth logout
gh auth login

# Verify API access
gh repo list
```

### Ruleset already exists - can I update it?

The script intentionally skips repos with existing rulesets to preserve custom configurations (like status checks).

**To update manually:**
1. Go to **Settings** → **Rules** → **Rulesets** in GitHub
2. Edit the existing ruleset
3. Or delete it and re-run the script

### Existing ruleset has conflicting settings

The script skips repos with rulesets. If you need to change an existing ruleset:

1. Option A: Manually edit in GitHub UI
2. Option B: Delete the ruleset and re-run the script
3. Option C: The PATCH approach could update rulesets (not currently implemented)

---

## 📚 Understanding the Ruleset

### Why These Rules?

**Block force pushes** - Prevents history rewriting, which can cause data loss and confusion

**Require pull requests** - Forces code review workflow even for solo developers, keeps main clean

**Dismiss stale reviews** - Auto-dismisses old reviews when you push new commits, keeps feedback current

**Conversation resolution** - Requires addressing comments before merge, prevents oversights

**Flexible merging** - Supports your preferred merge strategy (merge commits, squash, or rebase)

### What About Status Checks?

This ruleset does NOT require status checks (GitHub Actions). You can add those separately:

1. Create GitHub Actions workflows in `.github/workflows/`
2. Configure them to run on push and pull_request
3. Add them to the ruleset in GitHub UI under **Required status checks**

The script leaves status checks empty by default so you can customize them per-repo.

---

## 🔄 Workflow

For solo developers using these rulesets:

1. **Create a feature branch** - `git checkout -b feature/my-feature`
2. **Make changes** - Edit files, commit locally
3. **Push to GitHub** - `git push origin feature/my-feature`
4. **Create a PR** - GitHub CLI: `gh pr create`
5. **Address conversations** - Reply to any feedback (if present)
6. **Merge the PR** - Use GitHub UI or `gh pr merge`

**Direct commits to main are blocked** - You can't use `git push origin main`

---

## 📖 See Also

- [Full Setup Guide](github-branch-protection-and-status-checks.md) - Comprehensive documentation
- [GitHub Rulesets Docs](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)
- [GitHub CLI Docs](https://cli.github.com/manual)
- [Main Branch Ruleset.json](Main%20Branch%20Ruleset.json) - Configuration reference

---

## 📝 Notes

- **Script location:** `github/rules/Set-Rulesets.ps1`
- **Last updated:** December 15, 2025
- **Designed for:** Solo developers and small teams
- **Approach:** Non-destructive (skips existing rulesets)
