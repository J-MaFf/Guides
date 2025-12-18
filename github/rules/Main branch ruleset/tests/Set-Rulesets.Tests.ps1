BeforeAll {
    $Script:ScriptPath = "$PSScriptRoot/../Set-Rulesets.ps1"
}

Describe "Set-Rulesets.ps1 Syntax Validation" {
    It "Should have valid PowerShell syntax" {
        $errors = $null
        [System.Management.Automation.Language.Parser]::ParseFile(
            $Script:ScriptPath,
            [ref]$null,
            [ref]$errors
        ) | Out-Null
        $errors.Count | Should -Be 0
    }

    It "Should define required parameters" {
        $content = Get-Content $Script:ScriptPath -Raw
        $content | Should -Match "param\("
        $content | Should -Match "\[string\[\]\]\`$Repos"
        $content | Should -Match "\[switch\]\`$ApplyToAll"
    }

    It "Should define Set-BranchRuleset function" {
        $content = Get-Content $Script:ScriptPath -Raw
        $content | Should -Match "function Set-BranchRuleset"
    }

    It "Should have proper parameter attributes" {
        $content = Get-Content $Script:ScriptPath -Raw
        $content | Should -Match "Parameter\(ValueFromPipeline"
    }
}

Describe "Set-Rulesets.ps1 Function Discovery" {
    It "Should contain Set-BranchRuleset function" {
        . $Script:ScriptPath
        Get-Command Set-BranchRuleset -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
    }

    It "Set-BranchRuleset should have Repo parameter" {
        . $Script:ScriptPath
        $func = Get-Command Set-BranchRuleset -ErrorAction SilentlyContinue
        $func.Parameters.Keys | Should -Contain "Repo"
    }
}

Describe "Set-Rulesets.ps1 Help Documentation" {
    It "Should contain SYNOPSIS help section" {
        $content = Get-Content $Script:ScriptPath -Raw
        $content | Should -Match "\.SYNOPSIS"
    }

    It "Should contain DESCRIPTION help section" {
        $content = Get-Content $Script:ScriptPath -Raw
        $content | Should -Match "\.DESCRIPTION"
    }

    It "Should contain PARAMETER documentation for Repos" {
        $content = Get-Content $Script:ScriptPath -Raw
        $content | Should -Match "\.PARAMETER Repos"
    }

    It "Should contain EXAMPLE help section" {
        $content = Get-Content $Script:ScriptPath -Raw
        $content | Should -Match "\.EXAMPLE"
    }
}
