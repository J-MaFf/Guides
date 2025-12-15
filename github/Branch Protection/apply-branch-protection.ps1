<#
.SYNOPSIS
Applies standard branch protection rules to GitHub repositories using gh CLI.

.DESCRIPTION
This script applies consistent branch protection rules to one or more GitHub repositories.
Rules include: required status checks, conversation resolution, no force pushes, and no deletions.
No approval reviews required (designed for solo developers).

For detailed information about branch protection rules and GitHub Actions workflows, see:
  C:\Users\jmaffiola\Documents\Guides\github\github-branch-protection-and-status-checks.md

.PARAMETER Repos
Array of repository names in format "owner/repo" (e.g., "J-MaFf/gitconfig").
If not provided, will prompt for input.

.PARAMETER ApplyToAll
If specified, applies rules to all repositories the user has access to.

.EXAMPLE
# Apply to single repo
.\apply-branch-protection.ps1 -Repos "J-MaFf/gitconfig"

# Apply to multiple repos
.\apply-branch-protection.ps1 -Repos "J-MaFf/gitconfig", "J-MaFf/Guides"

# Apply to all repos
.\apply-branch-protection.ps1 -ApplyToAll

# Interactive mode (prompts for repo names)
.\apply-branch-protection.ps1

.NOTES
Requires: gh CLI installed and authenticated
Date: 2025-12-15

See Also:
  github-branch-protection-and-status-checks.md - Full setup and troubleshooting guide
#>

param(
    [Parameter(ValueFromPipeline = $true)]
    [string[]]$Repos,
    
    [switch]$ApplyToAll
)

# Function to apply protection to a single repo
function Apply-BranchProtection {
    param(
        [string]$Repo
    )
    
    Write-Host "Processing $Repo..." -ForegroundColor Cyan
    
    # Get default branch
    $branch = gh repo view $Repo --json defaultBranchRef --jq '.defaultBranchRef.name' 2>$null
    if (-not $branch) {
        $branch = "main"
    }
    
    Write-Host "  Default branch: $branch"
    
    # Apply branch protection rule
    try {
        gh api repos/$Repo/branches/$branch/protection `
            -X PUT `
            -f required_status_checks='{"strict":true,"contexts":[]}' `
            -f enforce_admins=true `
            -f required_pull_request_reviews='null' `
            -f restrictions='null' `
            -f allow_force_pushes=false `
            -f allow_deletions=false `
            -f block_creations=false `
            -f required_conversation_resolution=true `
            -f lock_branch=false 2>&1 | Out-Null
        
        Write-Host "  ✓ Branch protection applied" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  ✗ Failed: $_" -ForegroundColor Red
        return $false
    }
}

# Main logic
$reposToProcess = @()

if ($ApplyToAll) {
    Write-Host "Fetching all repositories..." -ForegroundColor Yellow
    $reposToProcess = gh repo list --json nameWithOwner --limit 100 | ConvertFrom-Json | ForEach-Object { $_.nameWithOwner }
    Write-Host "Found $($reposToProcess.Count) repositories`n" -ForegroundColor Yellow
}
elseif ($Repos) {
    $reposToProcess = $Repos
}
else {
    # Interactive mode
    Write-Host "Enter repository names (owner/repo format), one per line. Leave blank when done:`n" -ForegroundColor Yellow
    do {
        $input = Read-Host "Repo"
        if ($input) {
            $reposToProcess += $input
        }
    } while ($input)
}

if ($reposToProcess.Count -eq 0) {
    Write-Host "No repositories specified. Exiting." -ForegroundColor Yellow
    exit
}

# Confirm before applying
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Branch Protection Rules to Apply:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✓ Required status checks to pass before merging"
Write-Host "✓ Branches must be up-to-date before merging"
Write-Host "✓ Conversation resolution required"
Write-Host "✓ Enforce admin restrictions"
Write-Host "✗ No approval reviews required"
Write-Host "✗ Force pushes not allowed"
Write-Host "✗ Deletions not allowed"
Write-Host "`nRepositories: $($reposToProcess.Count)`n" -ForegroundColor Cyan

$confirm = Read-Host "Continue? (y/n)"
if ($confirm -ne "y") {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit
}

Write-Host "`n" -ForegroundColor Cyan

# Apply to all repos
$successCount = 0
$failureCount = 0

foreach ($repo in $reposToProcess) {
    if (Apply-BranchProtection -Repo $repo) {
        $successCount++
    }
    else {
        $failureCount++
    }
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Success: $successCount" -ForegroundColor Green
Write-Host "Failed: $failureCount" -ForegroundColor $(if ($failureCount -gt 0) { "Red" } else { "Green" })
Write-Host "`nDone!" -ForegroundColor Green
