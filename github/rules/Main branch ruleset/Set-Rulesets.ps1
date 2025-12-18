<#
.SYNOPSIS
Applies standard branch protection rulesets to GitHub repositories using gh CLI.

.DESCRIPTION
This script applies consistent branch protection rulesets to one or more GitHub repositories.
Rulesets include: required pull requests, conversation resolution, and no force pushes.
No approval reviews required (designed for solo developers).

If a repository already has a ruleset, it will be skipped to preserve any custom configuration
(such as status checks or custom rules). Only repositories without existing rulesets will be updated.

For detailed information about rulesets and GitHub Actions workflows, see:
  github-branch-protection-and-status-checks.md

.PARAMETER Repos
Array of repository names in format "owner/repo" (e.g., "J-MaFf/gitconfig").
If not provided, will prompt for input.

.PARAMETER ApplyToAll
If specified, applies rules to all repositories the user has access to.

.EXAMPLE
# Apply to single repo
.\Set-Rulesets.ps1 -Repos "J-MaFf/gitconfig"

# Apply to multiple repos
.\Set-Rulesets.ps1 -Repos "J-MaFf/gitconfig", "J-MaFf/Guides"

# Apply to all repos
.\Set-Rulesets.ps1 -ApplyToAll

# Interactive mode (prompts for repo names)
.\Set-Rulesets.ps1

.NOTES
Requires: gh CLI installed and authenticated
Date: 2025-12-15
Location: github/rules/Main branch ruleset/Set-Rulesets.ps1

See Also:
  github-branch-protection-and-status-checks.md - Full setup and troubleshooting guide
#>

param(
    [Parameter(ValueFromPipeline = $true)]
    [string[]]$Repos,

    [switch]$ApplyToAll
)

process {
    # Process pipeline input
    if ($PSBoundParameters.ContainsKey('Repos')) {
        # Repos provided via param or pipeline
    }
}

# Function to apply ruleset to a single repo
function Set-BranchRuleset {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
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

        # Check if ruleset already exists
        $existingRulesets = gh api repos/$Repo/rulesets --jq '.[].id' 2>$null
        if ($existingRulesets) {
            Write-Host "  ⊘ Ruleset already exists (ID: $existingRulesets), skipping to preserve custom configuration" -ForegroundColor Yellow
            Remove-Item $tempFile -Force
            return $true
        }

        # Create new ruleset only if it doesn't exist
        if ($PSCmdlet.ShouldProcess($Repo, "Apply branch protection ruleset")) {
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
        else {
            Write-Host "  Skipped applying ruleset to $Repo" -ForegroundColor Yellow
            Remove-Item $tempFile -Force
            return $false
        }
    }
    catch {
        Write-Host "  ✗ Failed: $_" -ForegroundColor Red
        return $false
    }
}

# Main logic - only run if script is invoked directly (not dot-sourced)
if ($MyInvocation.InvocationName -ne '.') {
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
            $repoInput = Read-Host "Repo"
            if ($repoInput) {
                $reposToProcess += $repoInput
            }
        } while ($repoInput)
    }

    if ($reposToProcess.Count -eq 0) {
        Write-Host "No repositories specified. Exiting." -ForegroundColor Yellow
        exit
    }

    # Confirm before applying
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Rulesets to Apply:" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "✓ Block force pushes (protects git history)"
    Write-Host "✓ Require a pull request before merging (prevents direct commits)"
    Write-Host "✓ Dismiss stale pull request approvals when new commits are pushed (keeps reviews current)"
    Write-Host "✓ Require conversation resolution before merging (ensures discussions addressed)"
    Write-Host "✓ Allow merge, squash, and rebase merge methods (flexible merging)"
    Write-Host "`nNote: Repos with existing rulesets will be skipped to preserve custom configurations`n"
    Write-Host "Repositories: $($reposToProcess.Count)`n" -ForegroundColor Cyan

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
        if (Set-BranchRuleset -Repo $repo) {
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
}
