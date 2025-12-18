# GitHub Actions Status Checks

This directory contains guides and templates for setting up automated status checks using GitHub Actions. Status checks run on every push and pull request, ensuring code quality before merging.

---

## 📋 Overview

Status checks are automated tests and validations that must pass before allowing pull requests to merge. They integrate with GitHub Rulesets to enforce quality standards.

### What Are Status Checks?

- **Automated tests** that run on every push and PR
- **Blocking checks** that prevent merging if they fail
- **Visible in GitHub UI** with pass/fail indicators
- **Required by rulesets** to maintain code quality

### Why Use Status Checks?

✅ **Catch bugs early** - Before code reaches main branch
✅ **Enforce standards** - Linting, formatting, code style
✅ **Automated validation** - No manual review needed
✅ **Peace of mind** - Know your code is tested before merging
✅ **Documentation** - Shows what's required for each repo

---

## 🚀 Quick Start

### 1. Choose Your Workflow

Pick the workflow template that matches your project type:

- [PowerShell Projects](#powershell-workflow) - Tests + Linting + Build
- [Python Projects](#python-workflow) - Tests + Linting
- [Generic/Other](#generic-workflow) - Template for any language

### 2. Create the Workflow File

Create `.github/workflows/ci.yml` in your repository with the appropriate template.

### 3. Commit and Push

```bash
git add .github/workflows/ci.yml
git commit -m "ci: add GitHub Actions workflow"
git push
```

### 4. View Results

- Check the **Actions** tab in GitHub
- Wait for the first run to complete
- Once it passes, the status check is available for rulesets

---

## 📝 Workflow Templates

### PowerShell Workflow

**File:** `.github/workflows/ci.yml`

```yaml
name: PowerShell CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: windows-latest
    strategy:
      matrix:
        pwsh-version: [ '7.2', '7.3', '7.4' ]
    
    steps:
    - uses: actions/checkout@v4

    - name: Set up PowerShell ${{ matrix.pwsh-version }}
      uses: actions/setup-powershell@v2
      with:
        powershell-version: ${{ matrix.pwsh-version }}

    - name: Display PowerShell version
      run: |
        pwsh -Command {
          Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)"
        }

    - name: Install dependencies
      shell: pwsh
      run: |
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        Install-Module -Name Pester -Force -SkipPublisherCheck
        Install-Module -Name PSScriptAnalyzer -Force
        Get-Module -ListAvailable Pester, PSScriptAnalyzer

    - name: Run Pester tests
      shell: pwsh
      run: |
        $pesterConfig = New-PesterConfiguration
        $pesterConfig.Run.Path = './tests'
        $pesterConfig.CodeCoverage.Enabled = $true
        $pesterConfig.CodeCoverage.Path = './src'
        $pesterConfig.Output.Verbosity = 'Detailed'
        Invoke-Pester -Configuration $pesterConfig

    - name: Run PSScriptAnalyzer
      shell: pwsh
      run: |
        $scriptFiles = Get-ChildItem -Path './src' -Filter '*.ps1' -Recurse
        if ($scriptFiles.Count -gt 0) {
          $results = Invoke-ScriptAnalyzer -Path './src' -Recurse -Severity Warning
          if ($results) {
            Write-Error "PSScriptAnalyzer found issues"
            $results | Format-Table -AutoSize
            exit 1
          }
        } else {
          Write-Host "No PowerShell files found to analyze"
        }

    - name: Validate script syntax
      shell: pwsh
      run: |
        $scriptFiles = Get-ChildItem -Path './src' -Filter '*.ps1' -Recurse
        foreach ($file in $scriptFiles) {
          $tokens = $errors = $null
          [System.Management.Automation.PSParser]::Tokenize((Get-Content $file.FullName -Raw), [ref]$errors)
          if ($errors) {
            Write-Error "Syntax error in $($file.Name)"
            $errors | Format-List
            exit 1
          }
        }
```

**Key points:**

- Tests on multiple PowerShell versions
- Runs Pester tests with code coverage
- Runs PSScriptAnalyzer for code quality
- Validates script syntax
- Uses `windows-latest` (best for PowerShell)

**Requirements:**

- Test files in `./tests/` directory
- Scripts in `./src/` directory
- Optional: `PSScriptAnalyzerSettings.psd1` in root

### Python Workflow

**File:** `.github/workflows/ci.yml`

```yaml
name: Python CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [ '3.9', '3.10', '3.11', '3.12' ]

    steps:
    - uses: actions/checkout@v4

    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        pip install pytest flake8 coverage

    - name: Lint with flake8
      run: |
        flake8 src/ --count --select=E9,F63,F7,F82 --show-source --statistics
        flake8 src/ --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics

    - name: Run tests with pytest
      run: |
        pytest tests/ -v --cov=src --cov-report=xml

    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        files: ./coverage.xml
```

**Key points:**

- Tests on multiple Python versions
- Linting with flake8
- Testing with pytest
- Code coverage tracking
- Uses `ubuntu-latest`

**Requirements:**

- `requirements.txt` with dependencies
- Test files in `./tests/` directory
- Source code in `./src/` directory

### Generic Workflow

**File:** `.github/workflows/ci.yml`

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

    - name: Run build command
      run: |
        echo "Running build..."
        # Replace with your actual build command
        # ./build.sh
        # make build
        # npm run build
        true

    - name: Run test command
      run: |
        echo "Running tests..."
        # Replace with your actual test command
        # ./test.sh
        # make test
        # npm test
        true

    - name: Run lint command
      run: |
        echo "Running linter..."
        # Replace with your actual lint command
        # ./lint.sh
        # make lint
        # npm run lint
        true
```

**Customize with your commands:**
- Replace comments with actual build/test/lint commands
- Choose appropriate `runs-on` image (ubuntu-latest, windows-latest, macos-latest)
- Add matrix testing for multiple versions if needed

---

## 🔧 Setting Up Your Repository

### Step 1: Create the Workflow File

1. Create `.github/workflows/` directory in your repo root
2. Add `ci.yml` with your chosen workflow template
3. Commit and push

### Step 2: Run Your First Workflow

The workflow runs automatically on push. Check results in:
- **Actions** tab in GitHub
- **Pull Requests** page (shows status)
- **Commits** page (shows checkmarks/X's)

### Step 3: Add Status Checks to Rulesets

Once the workflow runs successfully:

1. Go to **Settings** → **Rules** → **Rulesets**
2. Edit your "Main Branch Ruleset"
3. Scroll to **Required status checks**
4. Add your workflow job names:
   - For PowerShell: `test`, `build`, etc.
   - For Python: `test`, `lint`, etc.
5. Save changes

Now your status checks are blocking—PRs can't merge until they pass!

---

## 📊 Common Checks Explained

### Pester (PowerShell Testing)

```powershell
# Tests verify functionality
Describe "Get-Config function" {
    It "returns configuration" {
        $result = Get-Config
        $result | Should -Not -BeNullOrEmpty
    }
}
```

**Job name:** `test`
**What it does:** Runs unit tests
**Fail if:** Tests don't pass or throw errors

### PSScriptAnalyzer (PowerShell Linting)

**Job name:** `test` (or separate job)
**What it does:** Checks code style, common mistakes
**Fail if:** Warnings/errors found

### flake8 (Python Linting)

**Job name:** `test` (or separate job)
**What it does:** Checks Python style (PEP 8)
**Fail if:** Style violations found

### pytest (Python Testing)

**Job name:** `test`
**What it does:** Runs unit tests
**Fail if:** Tests don't pass

### Code Coverage

**Optional:** Add coverage requirements

```yaml
- name: Check coverage
  run: |
    coverage run -m pytest
    coverage report --fail-under=80
```

Fails if coverage drops below 80%.

---

## 🛠️ Troubleshooting

### Workflow Won't Run

**Problem:** No "Actions" tab or workflows not triggering

**Solutions:**
- Ensure `.github/workflows/ci.yml` is in root of default branch
- Check file is valid YAML (use [yamllint.com](https://www.yamllint.com/))
- Trigger manually: Go to **Actions** → **Run workflow**

### Workflow Runs but Test Fails

**Problem:** All steps are red

**Solutions:**
1. Check the job logs for error messages
2. Verify paths match your directory structure
3. Ensure required tools are installed in the workflow
4. Test locally first: `pester`, `pytest`, etc.

### Can't Find Job Names for Rulesets

**Problem:** Status checks not appearing in GitHub UI

**Solutions:**
1. Workflow must run at least once successfully
2. Check **Actions** tab to see if workflow ran
3. Job name is in the YAML under `jobs:` → `test:`, `build:`, etc.
4. Wait 5 minutes after first success, then refresh GitHub

### Status Check Requires Approval

**Problem:** PR is blocking even though tests pass

**Likely cause:** Ruleset requires status check that hasn't run yet

**Solution:**
1. Push a new commit to trigger the workflow
2. Wait for workflow to complete
3. Then the status check will be available

### Different Results Locally vs GitHub

**Common causes:**
- Different PowerShell/Python versions
- Missing dependencies
- Path differences (Windows vs Linux)
- Environment variables

**Solution:**
```powershell
# Test locally with same environment
pwsh -Version 7.4
pytest -v
```

---

## 📈 Best Practices

### 1. Keep Checks Fast

- Tests should complete in under 5 minutes
- Avoid unnecessary dependencies
- Use caching where possible

### 2. Make Failures Clear

Use descriptive error messages:

```powershell
if ($tests.FailedCount -gt 0) {
    Write-Error "Tests failed: $($tests.FailedCount) failures"
    exit 1
}
```

### 3. Test Multiple Versions

```yaml
strategy:
  matrix:
    version: [ '7.2', '7.3', '7.4' ]
```

Ensures compatibility across PowerShell/Python versions.

### 4. Use Consistent Names

Use same job names across repos:
- `test` - for testing jobs
- `lint` - for linting jobs
- `build` - for build jobs

Makes it easier to add to rulesets.

### 5. Document Requirements

Create `TESTING.md` in your repo:

```markdown
# Testing Guide

## Local Testing

```powershell
# Run tests
Invoke-Pester -Path ./tests

# Run linter
Invoke-ScriptAnalyzer -Path ./src
```

## Required Tools

- PowerShell 7.2+
- Pester 5.0+
- PSScriptAnalyzer
```

### 6. Cache Dependencies

Save time between runs:

```yaml
- uses: actions/cache@v3
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip
```

---

## 🔗 Integration with Rulesets

### Complete Workflow

1. **Developer** creates branch and commits code
2. **GitHub Actions** automatically runs workflow
3. **Workflow runs checks** (tests, linting, build)
4. **Results show in PR** with pass/fail status
5. **Ruleset checks** - Won't allow merge if failed
6. **Developer fixes** any failures and pushes again
7. **Workflow re-runs** and checks again
8. **When all pass** - PR can be merged

### Adding to Ruleset

```
Settings → Rules → Rulesets → Edit Ruleset
  ↓
Required status checks
  ↓
Add: "test", "lint", "build"
  ↓
Save
```

Now these must pass before merging!

---

## 📚 Examples by Repository Type

### PowerShell Module

```yaml
- Run Pester tests
- Run PSScriptAnalyzer
- Test multiple PowerShell versions
- Validate manifest file
```

### Python Package

```yaml
- Run pytest tests
- Run flake8 linting
- Check coverage (optional)
- Test multiple Python versions
- Build package
```

### Node.js/JavaScript

```yaml
- Run npm test
- Run npm run lint
- Run npm run build
- Test multiple Node versions
```

### Go Project

```yaml
- Run go test
- Run go vet
- Run golint
- Test multiple Go versions
```

---

## 📖 References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Actions - Set up PowerShell](https://github.com/actions/setup-powershell)
- [GitHub Actions - Set up Python](https://github.com/actions/setup-python)
- [Pester Testing Guide](https://pester.dev)
- [PSScriptAnalyzer Rules](https://github.com/PowerShell/PSScriptAnalyzer)
- [pytest Documentation](https://docs.pytest.org)

---

## 🎯 Next Steps

1. **Choose a workflow template** above
2. **Create `.github/workflows/ci.yml`** in your repo
3. **Commit and push** to trigger the workflow
4. **Wait for it to succeed** (check Actions tab)
5. **Add job names to your ruleset** in GitHub Settings
6. **Test with a PR** to verify it's blocking

Questions? Check the troubleshooting section or the linked documentation.
