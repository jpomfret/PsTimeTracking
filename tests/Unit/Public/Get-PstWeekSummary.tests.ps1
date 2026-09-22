
Describe "Get-PstWeekSummary Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        It "Should only contain our specific parameters" {
            $command = 'Get-PstWeekSummary'
            [object[]]$params = (Get-Command $command).Parameters.Keys
            [object[]]$specificParameters = 'Date', 'Detailed'
            $allCommonParameters = [System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

            # Filter out common parameters to check only specific ones
            $actualSpecificParams = $params | Where-Object { $_ -notin $allCommonParameters }
            (@(Compare-Object -ReferenceObject $specificParameters -DifferenceObject $actualSpecificParams).Count ) | Should -Be 0
        }
    }

    Context "Current week - work exists" {
        BeforeEach {
            Mock -CommandName 'Restore-PstDay' -ModuleName 'PsTimeTracking' -MockWith {
                @(
                    [PSCustomObject]@{ Client = 'ClientA'; Project = 'Project Alpha'; StartTime = $null; Elapsed = New-TimeSpan -Minutes 60 }
                    [PSCustomObject]@{ Client = 'ClientB'; Project = 'Website'; StartTime = $null; Elapsed = New-TimeSpan -Minutes 45 }
                )
            }
        }

        It 'Should not throw when work exists this week' {
            { Get-PstWeekSummary } | Should -Not -Throw
        }

        It 'Should call Restore-PstDay once per day of the week' {
            Get-PstWeekSummary
            Should -Invoke 'Restore-PstDay' -ModuleName 'PsTimeTracking' -Exactly 7
        }

        It 'Should call Restore-PstDay for the Monday of the requested week' {
            # 2025-01-08 is a Wednesday; Monday of that week is 2025-01-06
            $expectedMonday = [datetime]'2025-01-06'
            Get-PstWeekSummary -Date '2025-01-08'
            Should -Invoke 'Restore-PstDay' -ModuleName 'PsTimeTracking' -Exactly 1 -ParameterFilter { $Date -eq $expectedMonday }
        }

        It 'Should call Restore-PstDay for the Sunday of the requested week' {
            # Sunday of the week containing 2025-01-08 is 2025-01-12
            $expectedSunday = [datetime]'2025-01-12'
            Get-PstWeekSummary -Date '2025-01-08'
            Should -Invoke 'Restore-PstDay' -ModuleName 'PsTimeTracking' -Exactly 1 -ParameterFilter { $Date -eq $expectedSunday }
        }
    }

    Context "Sunday date resolves to the correct Monday" {
        BeforeEach {
            Mock -CommandName 'Restore-PstDay' -ModuleName 'PsTimeTracking' -MockWith { $null }
        }

        It 'Should treat a Sunday as the end of its week' {
            # 2025-01-12 is a Sunday; Monday of that week is 2025-01-06
            $expectedMonday = [datetime]'2025-01-06'
            Get-PstWeekSummary -Date '2025-01-12'
            Should -Invoke 'Restore-PstDay' -ModuleName 'PsTimeTracking' -Exactly 1 -ParameterFilter { $Date -eq $expectedMonday }
        }
    }

    Context "Detailed - work exists" {
        BeforeEach {
            Mock -CommandName 'Restore-PstDay' -ModuleName 'PsTimeTracking' -MockWith {
                @(
                    [PSCustomObject]@{ Client = 'ClientA'; Project = 'Project Alpha'; StartTime = $null; Elapsed = New-TimeSpan -Minutes 60 }
                    [PSCustomObject]@{ Client = 'ClientA'; Project = 'Project Beta'; StartTime = $null; Elapsed = New-TimeSpan -Minutes 30 }
                )
            }
        }

        It 'Should not throw when work exists with -Detailed' {
            { Get-PstWeekSummary -Detailed } | Should -Not -Throw
        }
    }

    Context "No work for the week" {
        BeforeEach {
            Mock -CommandName 'Restore-PstDay' -ModuleName 'PsTimeTracking' -MockWith { $null }
        }

        It 'Should not throw when no work recorded this week' {
            { Get-PstWeekSummary } | Should -Not -Throw
        }
    }
}
