# GitHub Rulesets with Required Status Checks

## Overview

This comprehensive guide explains how to set up GitHub Rulesets that require automated status checks (tests, linting, builds) to pass before merging—without needing approval reviews. Perfect for solo developers.

GitHub **Rulesets** are the modern replacement for branch protection rules, offering more flexibility and organization-wide enforcement capabilities.

The rulesets protect your `main` or `master` branch from accidental or harmful changes by requiring:

- [x] All pull requests before merging (no direct commits to main)
- [x] All conversations on code to be resolved before merging
- [x] No approval reviews required (designed for solo development)
- [x] No force pushes allowed
- [x] Stale reviews dismissed when new commits are pushed

---

## Part 1: Set Up GitHub Actions Workflows

GitHub Actions will automatically run your checks on every pull request and commit. Create workflow files in the `.github/workflows/` directory of your repository.

### Example 1: PowerShell Project

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: windows-latest

    steps:
    - uses: actions/checkout@v4

    - name: Set up PowerShell
      shell: pwsh
      run: |
        $PSVersionTable

    - name: Run Pester tests
      shell: pwsh
      run: |
        Install-Module -Name Pester -Force -SkipPublisherCheck
        Invoke-Pester -Path ./tests -PassThru

    - name: Run PSScriptAnalyzer linter
      shell: pwsh
      run: |
        Install-Module -Name PSScriptAnalyzer -Force
        Invoke-ScriptAnalyzer -Path ./src -Recurse

    - name: Run build script
      shell: pwsh
      run: .\build.ps1
```

**Key points for PowerShell:**

- Use `runs-on: windows-latest` (PowerShell works best on Windows runners)
- Use `shell: pwsh` to run PowerShell Core (cross-platform)
- Install modules with `Install-Module` if not pre-installed
- Call your `.ps1` scripts directly: `.\script.ps1`
- Common tools: `Pester` (testing), `PSScriptAnalyzer` (linting)

### Example 2: Python Project

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

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
        pip install pytest flake8

    - name: Lint with flake8
      run: flake8 .

    - name: Run tests
      run: pytest
```

### Example 3: Generic Workflow (any language)

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    - name: Run your test command
      run: your-test-command-here

    - name: Run your build command
      run: your-build-command-here
```

### Step 2: Commit Workflow Files

```bash
git add .github/workflows/
git commit -m "Add CI/CD workflow with automated checks"
git push
```

The workflow will run automatically on the next push or PR.

---

## Part 2: Configure Rulesets

You have three options to configure rulesets:

### Option A: GitHub Web Interface (Manual)

1. Go to your GitHub repository
2. Navigate to **Settings** → **Rules** → **Rulesets**
3. Click **New ruleset** (or edit existing ruleset)
4. Set **Ruleset name** to something descriptive (e.g., "Main Branch Ruleset")
5. Set **Enforcement status** to **Active**
6. Under **Target branches**, add `main` (or your target branch)
7. Enable these rules:
   - ✅ **Require a pull request before merging** with conversation resolution enabled
   - ✅ **Dismiss stale pull request approvals** when new commits are pushed
   - ✅ **Block force pushes** (no force pushes allowed)
   - ✗ **Do NOT restrict branch creation** (allows free branching)
   - ✗ **Do NOT restrict branch updates** (allows PR merges)
   - ✗ **Do NOT restrict deletions** (allows cleanup)
   - ✗ **Do NOT require pull request reviews** (no approval needed for solo development)
8. Click **Create ruleset**

### Option B: GitHub CLI (Single Repository)

Use `gh` CLI to apply rulesets to one repository:

```powershell
$repo = "owner/repo"

gh api repos/$repo/rulesets `
  -X POST `
  -f name="Main Branch Ruleset" `
  -f description="Ruleset protecting main with status checks and conversation resolution" `
  -f target="branch" `
  -f enforcement="active" `
  -f conditions='{"ref_name":{"include":["refs/heads/main"],"exclude":[]}}' `
  -f rules="[
    {\"type\":\"required_status_checks\",\"parameters\":{\"required_status_checks\":[],\"strict_required_status_checks_policy\":true}},
    {\"type\":\"pull_request\",\"parameters\":{\"dismiss_stale_reviews_on_push\":true,\"require_code_owner_reviews\":false,\"require_last_push_approval\":false,\"required_approving_review_count\":0,\"required_review_thread_resolution\":true}},
    {\"type\":\"non_fast_forward\"},
    {\"type\":\"deletion\"}
  ]"
```

### Option C: Automated PowerShell Script (Multiple Repositories)

For applying rules to many repositories at once, use the included `apply-branch-protection.ps1` script. This script automates the setup process and can be applied to single or multiple repositories.

**Prerequisites:**

- `gh` CLI installed and authenticated with GitHub
- PowerShell 5.0 or later
- Access to the repositories you want to protect

**Usage Examples:**

```powershell
# Apply to a single repo
.\apply-branch-protection.ps1 -Repos "J-MaFf/gitconfig"

# Apply to multiple repos
.\apply-branch-protection.ps1 -Repos "J-MaFf/gitconfig", "J-MaFf/Guides"

# Apply to all your repos (with confirmation)
.\apply-branch-protection.ps1 -ApplyToAll

# Interactive mode (prompts for repo names one at a time)
.\apply-branch-protection.ps1
```

**What the Script Does:**

1. **Fetches the default branch** for each repository (typically `main`)
2. **Creates or replaces rulesets** using the GitHub REST API with the following rules:
   - ✅ Block force pushes (protects git history)
   - ✅ Require pull request before merging (prevents direct commits)
   - ✅ Dismiss stale pull request approvals when new commits are pushed (keeps reviews current)
   - ✅ Require conversation resolution before merging (ensures discussions are addressed)
   - ✅ Allow merge, squash, and rebase merge methods (flexible merging)
   - ✗ No approval reviews required (solo developer friendly)
   - ✗ No restrictions on branch creation (allows free branching)
   - ✗ No restrictions on updates outside of PR flow (allows merges)
3. **Shows a confirmation prompt** before making changes
4. **Skips repos with existing rulesets** to preserve custom configurations
5. **Displays results** with success/failure count for each repository

**Important Notes:**

- The script will prompt for confirmation before applying rules—review the settings carefully
- The script automatically detects your repository's default branch
- Rulesets replace any existing conflicting rulesets (the script cleans up old ones)
- All repositories must be accessible with your authenticated `gh` CLI account
- Rulesets are repository-level; they only apply to the target branch pattern

---

## Part 3: Testing Branch Protection

After setting up workflows and protection rules, test that everything works:

1. Create a new branch from `main`
2. Make a breaking change (e.g., introduce a test failure)
3. Push to GitHub and create a PR
4. The status check should **fail** and prevent merging
5. Revert the breaking change
6. Push again—the check should **pass** and allow merging

---

## Configuration Details

### What Gets Required

Once configured, before merging any PR to your protected branch:

- ✅ All GitHub Actions workflows must **pass**
- ✅ All required **status checks** must **pass**
- ✅ All conversations must be **resolved**
- ✅ Branch must be **up-to-date** with main
- ❌ No approval reviews needed (you're solo)
- ❌ No manual gates required

### Common Status Check Names

When setting up branch protection, you'll see these job names available:

- **For PowerShell**: `test`, `lint`, `build` (whatever you name in the workflow)
- **For Python**: `test`, `lint`, `build` (whatever you name in the workflow)
- **For any language**: Whatever you name your job in the workflow YAML

The job name in your workflow file is what appears in GitHub's branch protection settings.

### Tips

- **Multiple status checks**: You can require multiple jobs (tests + lint + build all pass)
- **Selective branches**: Only protect your main branches (main, production), not develop
- **Rulesets are modern**: GitHub recommends rulesets over legacy branch protection rules
- **Script reliability**: The script safely replaces rulesets without data loss
- **Status check contexts**: The script leaves contexts empty by default (any successful workflow run satisfies the requirement)

### Advanced Configuration (Ruleset Rules)

The `Set-Rulesets.ps1` script creates rulesets with these rules:

| Rule Type | Setting | Purpose |
| --- | --- | --- |
| `non_fast_forward` | — | No force pushes allowed (protects history) |
| `pull_request` | `required_review_thread_resolution = true` | Conversation resolution required |
| `pull_request` | `dismiss_stale_reviews_on_push = true` | Stale reviews auto-dismissed on new commits |
| `pull_request` | `required_approving_review_count = 0` | No approval reviews required (solo dev) |
| `pull_request` | `allowed_merge_methods = [merge, squash, rebase]` | Flexible merge strategies |

---

## Why These Rules?

### The Rationale

1. **Pull Requests Required**: Prevents accidental direct commits to main—ensures everything goes through code review workflow
2. **Conversation Resolution**: Requires discussion of any feedback before merging—prevents oversights
3. **No Force Pushes**: Protects git history integrity and prevents data loss
4. **Stale Review Dismissal**: Auto-dismisses outdated reviews when new commits are pushed—keeps feedback current
5. **No Approval Reviews**: Solo developers don't need approval gates; the PR workflow is sufficient
6. **Flexible Merging**: Supports merge, squash, and rebase strategies for different use cases

### Design for Solo Developers

The `Set-Rulesets.ps1` script is specifically designed for solo developers:

- **Zero approval reviews required**: You don't need to wait for someone else to approve your code
- **PR-based workflow**: Forces a branching/PR workflow instead of committing directly—better for tracking changes
- **No restrictive rules**: Allows free branch creation and merging of PRs without overly strict gates
- **Batch application**: Apply to all your repos at once instead of configuring each one manually
- **Safe replacement**: The script cleanly replaces rulesets without losing configuration data
- **Modern approach**: Uses GitHub's recommended Rulesets feature, not legacy branch protection

### Benefits for Solo Development

- Prevents shipping broken code to main
- Maintains clean git history
- Reduces debugging time by catching issues early
- Provides a safety net for quick fixes or late-night changes
- Scales to multiple repositories efficiently

---

## Troubleshooting

### Status checks not appearing in GitHub UI?

- Wait 5 minutes after pushing the workflow file
- Ensure the workflow file is in the `main` branch (or your target branch)
- Check the **Actions** tab in GitHub to see if workflows ran successfully
- The job must run at least once before being available for rulesets

### Can't find my job name?

- Create a test PR to trigger the workflow
- Check the workflow run logs to verify the job name matches your YAML

### Script reports "Failed" for a repository?

- Verify the `gh` CLI is authenticated: `gh auth status`
- Ensure you have admin access to the repository
- Check that the repository exists and the owner/name is correct
- Run the script with just one repository to isolate the issue
- Look for error messages in the script output—they often indicate permission or API issues

### "gh api" command fails?

- Ensure `gh` CLI is installed: `gh --version`
- Authenticate with GitHub: `gh auth login`
- Verify API access: `gh repo list` (should list your repositories)
- Check your GitHub token has proper scopes: `repo` and `admin:repo_hook`
- For rulesets: ensure you're using a token that supports the modern GitHub API

### Existing rulesets conflicting with the script?

- The script automatically deletes existing rulesets before creating new ones
- Check **Settings** → **Rules** → **Rulesets** to see what exists
- If the script still fails, manually delete old rulesets and try again

### Want to skip checks temporarily?

- You can use `git push --force` locally, but GitHub will prevent merging via the UI
- For real exceptions, temporarily disable the rule in Settings (as the repo owner)
- Re-enable it when done

### Workflow not running?

- Check that the `on:` trigger includes `push` and `pull_request`
- Verify branch names in the workflow match your actual branch names
- Ensure the workflow file is valid YAML (use [yamllint.com](https://www.yamllint.com/))

---

## Rulesets vs Branch Protection Rules

**Rulesets** (recommended, modern approach):

- More flexible rule configuration
- Support for multiple conditions and target types
- Better organization-wide enforcement options
- GitHub's recommended approach for new repositories

**Branch Protection Rules** (legacy):

- Simpler configuration for basic use cases
- Still fully functional but not recommended for new setups
- No longer receiving feature updates from GitHub

This guide uses **Rulesets** as the standard approach.

---

## References

- [GitHub Rulesets Documentation](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub CLI Documentation](https://cli.github.com/manual)
- [GitHub REST API - Rulesets](https://docs.github.com/en/rest/repos/rules?apiVersion=2022-11-28)
