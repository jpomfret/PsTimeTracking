Describe "Open-PstConfig Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        It "Should only contain our specific parameters" {
            $command = 'Open-PstConfig'
            [object[]]$params = (Get-Command $command).Parameters.Keys
            [object[]]$specificParameters = 'Editor'
            $allCommonParameters = [System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

            # Filter out common parameters to check only specific ones
            $actualSpecificParams = $params | Where-Object { $_ -notin $allCommonParameters }
            (@(Compare-Object -ReferenceObject $specificParameters -DifferenceObject $actualSpecificParams).Count ) | Should -Be 0
        }

        It 'Should use VSCode by default when no editor is specified' {
            Mock -CommandName 'Test-Path' -ModuleName 'PsTimeTracking' -MockWith { $true }
            Mock -CommandName 'code' -ModuleName 'PsTimeTracking' -MockWith {}
            Open-PstConfig
            Should -Invoke 'code' -ModuleName 'PsTimeTracking' -Exactly 1
        }

        It 'Should only accept VSCode or Notepad as valid editor values' {
            $validateSet = (Get-Command Open-PstConfig).Parameters['Editor'].Attributes |
                Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] }
            $validateSet.ValidValues | Should -Contain 'VSCode'
            $validateSet.ValidValues | Should -Contain 'Notepad'
            $validateSet.ValidValues.Count | Should -Be 2
        }
    }

    Context "Functionality - config file not found" {
        BeforeEach {
            Mock -CommandName 'Test-Path' -ModuleName 'PsTimeTracking' -MockWith { $false }
        }

        It 'Should write a warning when config file does not exist' {
            { Open-PstConfig -WarningAction Stop } | Should -Throw
        }

        It 'Should return early without opening an editor when config file does not exist' {
            Mock -CommandName 'code' -ModuleName 'PsTimeTracking' -MockWith {}
            Open-PstConfig -WarningAction SilentlyContinue
            Should -Invoke 'code' -ModuleName 'PsTimeTracking' -Exactly 0
        }
    }

    Context "Functionality - config file exists" {
        BeforeEach {
            Mock -CommandName 'Test-Path' -ModuleName 'PsTimeTracking' -MockWith { $true }
            Mock -CommandName 'code' -ModuleName 'PsTimeTracking' -MockWith {}
            Mock -CommandName 'notepad' -ModuleName 'PsTimeTracking' -MockWith {}
        }

        It 'Should not throw when opening with VSCode' {
            { Open-PstConfig -Editor VSCode } | Should -Not -Throw
        }

        It 'Should not throw when opening with Notepad' {
            { Open-PstConfig -Editor Notepad } | Should -Not -Throw
        }
    }
}
