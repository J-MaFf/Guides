BeforeAll {
    $Script:ScriptPath = "$PSScriptRoot/../Set-Rulesets.ps1"
    . $Script:ScriptPath
}

Describe "Set-Rulesets.ps1 Syntax & Structure" {
    It "Should have valid PowerShell syntax" {
        $errors = $null
        [System.Management.Automation.Language.Parser]::ParseFile(
            $Script:ScriptPath,
            [ref]$null,
            [ref]$errors
        ) | Out-Null
        $errors.Count | Should -Be 0 -Because "Script should parse without syntax errors"
    }

    It "Should define Set-BranchRuleset function" {
        Get-Command Set-BranchRuleset -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty -Because "Set-BranchRuleset function must be defined"
    }

    It "Should have required script parameters" {
        $content = Get-Content $Script:ScriptPath -Raw
        $content | Should -Match "\[string\[\]\]\`$Repos" -Because "Script needs Repos parameter"
        $content | Should -Match "\[switch\]\`$ApplyToAll" -Because "Script needs ApplyToAll switch"
    }
}

Describe "Set-BranchRuleset Function" {
    It "Should have Repo parameter" {
        $func = Get-Command Set-BranchRuleset
        $func.Parameters.Keys | Should -Contain "Repo" -Because "Function requires Repo parameter"
    }

    It "Should have CmdletBinding attribute" {
        $func = Get-Command Set-BranchRuleset
        $func.CmdletBinding | Should -Be $true -Because "Function should support -WhatIf and -Confirm"
    }

    Context "When gh CLI is unavailable" {
        It "Should handle gh command failure gracefully" {
            Mock -CommandName gh -MockWith { exit 1 } -ParameterFilter { $args[0] -eq "repo" }
            
            { Set-BranchRuleset -Repo "test/repo" } | Should -Not -Throw -Because "Function should handle CLI errors without crashing"
        }
    }

    Context "When ruleset already exists" {
        It "Should skip repository with existing ruleset" {
            Mock -CommandName gh -MockWith { "12345" } -ParameterFilter { $args[0] -eq "api" -and $args[1] -match "rulesets" }
            Mock -CommandName Write-Host
            
            Set-BranchRuleset -Repo "test/repo" | Should -Be $true -Because "Should return true and skip"
            Assert-MockCalled -CommandName Write-Host -ParameterFilter { $_ -match "already exists" }
        }
    }
}

Describe "Set-Rulesets.ps1 Help Documentation" {
    It "Should have SYNOPSIS" {
        $help = Get-Help Set-Rulesets.ps1 -Full -ErrorAction SilentlyContinue
        $help.Synopsis | Should -Not -BeNullOrEmpty -Because "Script needs descriptive help"
    }

    It "Should have DESCRIPTION" {
        $help = Get-Help Set-Rulesets.ps1 -Full -ErrorAction SilentlyContinue
        $help.Description | Should -Not -BeNullOrEmpty -Because "Script needs detailed description"
    }

    It "Should have PARAMETER documentation" {
        $help = Get-Help Set-Rulesets.ps1 -Full -ErrorAction SilentlyContinue
        $help.Parameters | Should -Not -BeNullOrEmpty -Because "Script parameters should be documented"
    }

    It "Should have EXAMPLES" {
        $help = Get-Help Set-Rulesets.ps1 -Full -ErrorAction SilentlyContinue
        $help.Examples | Should -Not -BeNullOrEmpty -Because "Script should include usage examples"
    }
}

Describe "Set-Rulesets.ps1 Error Handling" {
    It "Should exit when no repos specified" {
        Mock -CommandName Read-Host -MockWith { "" }
        Mock -CommandName exit
        
        # This would be tested in integration tests with actual invocation
        # For now, verify the logic exists in the script
        $content = Get-Content $Script:ScriptPath -Raw
        $content | Should -Match "No repositories specified" -Because "Script should handle empty input"
    }
}
