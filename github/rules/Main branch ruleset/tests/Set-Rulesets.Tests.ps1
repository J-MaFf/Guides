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

    It "Should output status messages" {
        $content = Get-Content $Script:ScriptPath -Raw
        $content | Should -Match "Write-Host.*Processing" -Because "Function should provide user feedback"
    }

    It "Should handle temp files" {
        $content = Get-Content $Script:ScriptPath -Raw
        $content | Should -Match "GetTempFileName" -Because "Function should create temporary files safely"
    }
}

Describe "Set-Rulesets.ps1 Help Documentation" {
    It "Should contain SYNOPSIS comment" {
        $content = Get-Content $Script:ScriptPath -Raw
        $content | Should -Match "\.SYNOPSIS" -Because "Script needs descriptive help"
    }

    It "Should contain DESCRIPTION comment" {
        $content = Get-Content $Script:ScriptPath -Raw
        $content | Should -Match "\.DESCRIPTION" -Because "Script needs detailed description"
    }

    It "Should contain PARAMETER documentation" {
        $content = Get-Content $Script:ScriptPath -Raw
        $content | Should -Match "\.PARAMETER" -Because "Script parameters should be documented"
    }

    It "Should contain EXAMPLE section" {
        $content = Get-Content $Script:ScriptPath -Raw
        $content | Should -Match "\.EXAMPLE" -Because "Script should include usage examples"
    }
}

Describe "Set-Rulesets.ps1 Error Handling" {
    It "Should handle empty repositories list" {
        $content = Get-Content $Script:ScriptPath -Raw
        $content | Should -Match "No repositories specified" -Because "Script should handle empty input"
    }

    It "Should have try-catch error handling" {
        $content = Get-Content $Script:ScriptPath -Raw
        $content | Should -Match "try \{" -Because "Script should have error handling"
        $content | Should -Match "catch \{" -Because "Script should catch errors"
    }

    It "Should provide user confirmation before applying" {
        $content = Get-Content $Script:ScriptPath -Raw
        $content | Should -Match "Read-Host.*Continue" -Because "Script should prompt for confirmation"
    }
}
