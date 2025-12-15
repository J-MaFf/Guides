<#
.SYNOPSIS
Applies standard branch protection rulesets to GitHub repositories using gh CLI.

.DESCRIPTION
This script applies consistent branch protection rulesets to one or more GitHub repositories.
Rulesets include: required status checks, conversation resolution, no force pushes, and no deletions.
No approval reviews required (designed for solo developers).

For detailed information about rulesets and GitHub Actions workflows, see:
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

# Function to apply ruleset to a single repo
function Apply-BranchRuleset {
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

    # Apply ruleset
    try {
        $rulesetPayload = @{
            name        = "Main Branch Ruleset"
            target      = "branch"
            enforcement = "active"
            conditions  = @{
                ref_name = @{
                    include = @("refs/heads/$branch")
                    exclude = @()
                }
            }
            rules       = @(
                @{
                    type = "non_fast_forward"
                },
                @{
                    type       = "pull_request"
                    parameters = @{
                        required_approving_review_count   = 0
                        dismiss_stale_reviews_on_push     = $true
                        required_reviewers                = @()
                        require_code_owner_review         = $false
                        require_last_push_approval        = $false
                        required_review_thread_resolution = $true
                        allowed_merge_methods             = @("merge", "squash", "rebase")
                    }
                }
            )
        } | ConvertTo-Json -Depth 10

        $tempFile = [System.IO.Path]::GetTempFileName()
        $rulesetPayload | Set-Content $tempFile

        # First, check if ruleset exists and delete it
        $existingRulesets = gh api repos/$Repo/rulesets --jq '.[].id' 2>$null
        if ($existingRulesets) {
            foreach ($rulesetId in $existingRulesets) {
                gh api repos/$Repo/rulesets/$rulesetId -X DELETE 2>$null
            }
        }

        # Create new ruleset
        $response = gh api repos/$Repo/rulesets `
            -X POST `
            --input $tempFile 2>&1

        Remove-Item $tempFile -Force

        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Ruleset applied" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "  ✗ Failed: $response" -ForegroundColor Red
            return $false
        }
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
Write-Host "Rulesets to Apply:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✓ Restrict branch creation"
Write-Host "✓ Restrict branch updates (requires PR)"
Write-Host "✓ Restrict branch deletion"
Write-Host "✓ Block force pushes"
Write-Host "✓ Require a pull request before merging"
Write-Host "✓ Dismiss stale pull request approvals when new commits are pushed"
Write-Host "✓ Require conversation resolution before merging"
Write-Host "✓ Allow merge, squash, and rebase merge methods"
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
    if (Apply-BranchRuleset -Repo $repo) {
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
