
Describe "Get-PstDaySummary Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        It "Should only contain our specific parameters" {
            $command = 'Get-PstDaySummary'
            [object[]]$params = (Get-Command $command).Parameters.Keys
            [object[]]$specificParameters = 'Date'
            $allCommonParameters = [System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

            # Filter out common parameters to check only specific ones
            $actualSpecificParams = $params | Where-Object { $_ -notin $allCommonParameters }
            (@(Compare-Object -ReferenceObject $specificParameters -DifferenceObject $actualSpecificParams).Count ) | Should -Be 0
        }
    }

    Context "Today's summary - work exists" {
        BeforeEach {
            Mock -CommandName 'Restore-PstDay' -ModuleName 'PsTimeTracking' -MockWith {
                @(
                    [PSCustomObject]@{ Client = 'ClientA'; Project = 'Project Alpha'; StartTime = $null; Elapsed = New-TimeSpan -Minutes 60 }
                    [PSCustomObject]@{ Client = 'ClientA'; Project = 'Project Alpha'; StartTime = $null; Elapsed = New-TimeSpan -Minutes 30 }
                    [PSCustomObject]@{ Client = 'ClientB'; Project = 'Website'; StartTime = $null; Elapsed = New-TimeSpan -Minutes 45 }
                )
            }
        }

        It 'Should not throw when work exists for today' {
            { Get-PstDaySummary } | Should -Not -Throw
        }

        It 'Should call Restore-PstDay once for today' {
            Get-PstDaySummary
            Should -Invoke 'Restore-PstDay' -ModuleName 'PsTimeTracking' -Exactly 1
        }
    }

    Context "Today's summary - no work" {
        BeforeEach {
            Mock -CommandName 'Restore-PstDay' -ModuleName 'PsTimeTracking' -MockWith { $null }
        }

        It 'Should not throw when no work recorded today' {
            { Get-PstDaySummary } | Should -Not -Throw
        }
    }

    Context "Historical date - work exists" {
        BeforeEach {
            Mock -CommandName 'Restore-PstDay' -ModuleName 'PsTimeTracking' -MockWith {
                @(
                    [PSCustomObject]@{ Client = 'ClientA'; Project = 'Project Alpha'; StartTime = $null; Elapsed = New-TimeSpan -Minutes 120 }
                )
            }
        }

        It 'Should not throw when retrieving a past day' {
            { Get-PstDaySummary -Date '2025-01-01' } | Should -Not -Throw
        }

        It 'Should call Restore-PstDay with the provided date' {
            $testDate = [datetime]'2025-01-01'
            Get-PstDaySummary -Date $testDate
            Should -Invoke 'Restore-PstDay' -ModuleName 'PsTimeTracking' -Exactly 1 -ParameterFilter { $Date -eq $testDate }
        }
    }

    Context "Historical date - no work" {
        BeforeEach {
            Mock -CommandName 'Restore-PstDay' -ModuleName 'PsTimeTracking' -MockWith { $null }
        }

        It 'Should not throw when no work found for past date' {
            { Get-PstDaySummary -Date '2025-01-01' } | Should -Not -Throw
        }
    }
}
