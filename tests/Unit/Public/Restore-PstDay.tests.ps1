
Describe "Restore-PstDay Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        It "Should only contain our specific parameters" {
            $command = 'Restore-PstDay'
            [object[]]$params = (Get-Command $command).Parameters.Keys
            [object[]]$specificParameters = 'Date'
            $allCommonParameters = [System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

            # Filter out common parameters to check only specific ones
            $actualSpecificParams = $params | Where-Object { $_ -notin $allCommonParameters }
            (@(Compare-Object -ReferenceObject $specificParameters -DifferenceObject $actualSpecificParams).Count ) | Should -Be 0
        }
    }

    Context "Functionality" {
        It 'Should return nothing when no file exists for the date' {
            Mock -CommandName 'Test-Path' -ModuleName 'PsTimeTracking' -MockWith { $false }
            $result = Restore-PstDay -Date '2025-01-01'
            $result | Should -BeNullOrEmpty
        }

        It 'Should return deserialized work when file exists' {
            $jsonContent = '[{"Client":"ClientA","Project":"Project Alpha","StartTime":null,"ElapsedTotalSeconds":3600}]'
            Mock -CommandName 'Test-Path' -ModuleName 'PsTimeTracking' -MockWith { $true }
            Mock -CommandName 'Get-Content' -ModuleName 'PsTimeTracking' -MockWith { $jsonContent }

            $result = Restore-PstDay -Date '2025-01-01'
            $result | Should -Not -BeNullOrEmpty
            $result.Client | Should -Be 'ClientA'
            $result.Project | Should -Be 'Project Alpha'
        }

        It 'Should reconstruct Elapsed as a TimeSpan from ElapsedTotalSeconds' {
            $jsonContent = '[{"Client":"ClientA","Project":"Project Alpha","StartTime":null,"ElapsedTotalSeconds":3600}]'
            Mock -CommandName 'Test-Path' -ModuleName 'PsTimeTracking' -MockWith { $true }
            Mock -CommandName 'Get-Content' -ModuleName 'PsTimeTracking' -MockWith { $jsonContent }

            $result = Restore-PstDay -Date '2025-01-01'
            $result.Elapsed | Should -BeOfType [TimeSpan]
            $result.Elapsed.TotalSeconds | Should -Be 3600
        }

        It 'Should use today as the default date when no date is provided' {
            Mock -CommandName 'Test-Path' -ModuleName 'PsTimeTracking' -MockWith { $false }
            Restore-PstDay
            Should -Invoke 'Test-Path' -ModuleName 'PsTimeTracking' -Exactly 1 -ParameterFilter {
                $Path -like "*$(Get-Date -Format 'yyyy-MM-dd')*"
            }
        }
    }
}
