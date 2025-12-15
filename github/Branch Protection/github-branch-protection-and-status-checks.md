# GitHub Branch Protection with Required Status Checks

## Overview

This comprehensive guide explains how to set up branch protection rules that require automated status checks (tests, linting, builds) to pass before merging—without needing approval reviews. Perfect for solo developers.

The branch protection rules protect your `main` or `master` branch from accidental or harmful changes by requiring:
- [x] All automated status checks to pass before merging
- [x] Branches to be up-to-date before merging
- [x] All conversations on code to be resolved before merging
- [ ] No approval reviews (designed for solo development)
- [ ] No force pushes allowed
- [ ] No branch deletions allowed

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

## Part 2: Configure Branch Protection Rules

You have three options to configure branch protection:

### Option A: GitHub Web Interface (Manual)

1. Go to your GitHub repository
2. Navigate to **Settings** → **Branches**
3. Click **Add rule** (or edit existing rule)
4. Set **Branch name pattern** to `main` (or your target branch)
5. Enable these options:
   - ✅ **Require status checks to pass before merging**
   - Under "Status checks that are required", select your workflow job names (e.g., `test`, `build`)
   - ✅ **Require branches to be up to date before merging**
   - ✅ **Require conversation resolution before merging**
   - ✅ **Restrict who can push to matching branches** (admin only)
   - ✗ **Do NOT require pull request reviews**
   - ✗ **Do NOT allow force pushes**
   - ✗ **Do NOT allow deletions**
6. Click **Create** or **Save changes**

### Option B: GitHub CLI (Single Repository)

Use `gh` CLI to apply rules to one repository:

```powershell
$repo = "owner/repo"
$branch = "main"

gh api repos/$repo/branches/$branch/protection `
  -X PUT `
  -f required_status_checks='{"strict":true,"contexts":[]}' `
  -f enforce_admins=true `
  -f required_pull_request_reviews='null' `
  -f restrictions='null' `
  -f allow_force_pushes=false `
  -f allow_deletions=false `
  -f block_creations=false `
  -f required_conversation_resolution=true `
  -f lock_branch=false
```

### Option C: Automated PowerShell Script (Multiple Repositories)

For applying rules to many repositories at once, use the included `apply-branch-protection.ps1` script:

```powershell
# Apply to a single repo
.\apply-branch-protection.ps1 -Repos "owner/repo"

# Apply to multiple repos
.\apply-branch-protection.ps1 -Repos "owner/repo1", "owner/repo2"

# Apply to all your repos
.\apply-branch-protection.ps1 -ApplyToAll

# Interactive mode (prompts for repo names)
.\apply-branch-protection.ps1
```

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
- **Admin bypass**: Admins can still force-merge if needed (Settings → "Restrict who can push to matching branches")

---

## Why These Rules?

### The Rationale

1. **Status Checks**: Ensures automated tests/linting pass before merging—catches bugs early
2. **Conversation Resolution**: Requires discussion of any feedback before merging—prevents oversights
3. **Up-to-Date Branches**: Prevents merge conflicts and ensures main is always stable
4. **No Force Pushes**: Protects git history integrity and prevents data loss
5. **No Deletions**: Prevents accidental branch deletion
6. **No Approval Reviews**: Solo developers don't need approval gates; CI automation is sufficient

### Benefits for Solo Development

- Prevents shipping broken code to main
- Maintains clean git history
- Reduces debugging time by catching issues early
- Provides a safety net for quick fixes or late-night changes

---

## Troubleshooting

### Status checks not appearing in branch protection settings?

- Wait 5 minutes after pushing the workflow file
- Ensure the workflow file is in the `main` branch (or your target branch)
- Check the **Actions** tab in GitHub to see if workflows ran successfully
- The job must run at least once before appearing in the dropdown

### Can't find my job name?

- Create a test PR to trigger the workflow
- Check the workflow run logs to verify the job name matches your YAML

### Want to skip checks temporarily?

- You can use `git push --force` locally, but GitHub will prevent merging via the UI
- For real exceptions, temporarily disable the rule in Settings (as the repo owner)
- Re-enable it when done

### Workflow not running?

- Check that the `on:` trigger includes `push` and `pull_request`
- Verify branch names in the workflow match your actual branch names
- Ensure the workflow file is valid YAML (use [yamllint.com](https://www.yamllint.com/))

---

## Example Workflow Status in Branch Protection UI

After your workflow runs, you'll see it in the "Status checks" dropdown:

```
your-job-name
your-job-name (windows-latest)
your-job-name (ubuntu-latest)
```

Select the ones you want to require for merging.

---

## References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Branch Protection Documentation](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule)
- [GitHub REST API - Update Branch Protection](https://docs.github.com/en/rest/branches/branch-protection?apiVersion=2022-11-28)
- [GitHub CLI Documentation](https://cli.github.com/manual)
