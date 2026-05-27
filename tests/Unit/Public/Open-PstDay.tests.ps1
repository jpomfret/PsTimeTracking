Describe "Open-PstDay Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        It "Should only contain our specific parameters" {
            $command = 'Open-PstDay'
            [object[]]$params = (Get-Command $command).Parameters.Keys
            [object[]]$specificParameters = 'Date', 'Editor'
            $allCommonParameters = [System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

            # Filter out common parameters to check only specific ones
            $actualSpecificParams = $params | Where-Object { $_ -notin $allCommonParameters }
            (@(Compare-Object -ReferenceObject $specificParameters -DifferenceObject $actualSpecificParams).Count ) | Should -Be 0
        }

        It 'Should use VSCode by default when no editor is specified' {
            Mock -CommandName 'Test-Path' -ModuleName 'PsTimeTracking' -MockWith { $true }
            Mock -CommandName 'Start-Process' -ModuleName 'PsTimeTracking' -MockWith {}
            Open-PstDay
            Should -Invoke 'Start-Process' -ModuleName 'PsTimeTracking' -Exactly 1 -ParameterFilter { $FilePath -eq 'code' }
        }

        It 'Should have an optional Date parameter' {
            (Get-Command Open-PstDay).Parameters['Date'].Attributes.Mandatory | Should -Be $false
        }

        It 'Should only accept VSCode or Notepad as valid editor values' {
            $validateSet = (Get-Command Open-PstDay).Parameters['Editor'].Attributes |
                Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] }
            $validateSet.ValidValues | Should -Contain 'VSCode'
            $validateSet.ValidValues | Should -Contain 'Notepad'
            $validateSet.ValidValues.Count | Should -Be 2
        }
    }

    Context "Functionality - file not found" {
        BeforeEach {
            Mock -CommandName 'Test-Path' -ModuleName 'PsTimeTracking' -MockWith { $false }
        }

        It 'Should write a warning when no time tracking file exists for the date' {
            { Open-PstDay -Date '2025-01-01' -WarningAction Stop } | Should -Throw
        }

        It 'Should return early without opening an editor when file does not exist' {
            Mock -CommandName 'Start-Process' -ModuleName 'PsTimeTracking' -MockWith {}
            Open-PstDay -Date '2025-01-01' -WarningAction SilentlyContinue
            Should -Invoke 'Start-Process' -ModuleName 'PsTimeTracking' -Exactly 0
        }
    }

    Context "Functionality - file exists" {
        BeforeEach {
            Mock -CommandName 'Test-Path' -ModuleName 'PsTimeTracking' -MockWith { $true }
            Mock -CommandName 'Start-Process' -ModuleName 'PsTimeTracking' -MockWith {}
        }

        It 'Should not throw when opening a specific date with VSCode' {
            { Open-PstDay -Date '2025-01-01' -Editor VSCode } | Should -Not -Throw
        }

        It 'Should not throw when opening a specific date with Notepad' {
            { Open-PstDay -Date '2025-01-01' -Editor Notepad } | Should -Not -Throw
        }

        It 'Should use today as the default date' {
            Open-PstDay
            Should -Invoke 'Test-Path' -ModuleName 'PsTimeTracking' -Exactly 1 -ParameterFilter {
                $Path -like "*$(Get-Date -Format 'yyyy-MM-dd')*"
            }
        }
    }
}
