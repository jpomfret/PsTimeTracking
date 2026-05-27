Describe "Move-PstTime Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        It "Should only contain our specific parameters" {
            $command = 'Move-PstTime'
            [object[]]$params = (Get-Command $command).Parameters.Keys
            [object[]]$specificParameters = 'FromClient','FromProject','ToClient','ToProject','Minutes'
            $allCommonParameters = [System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

            # Filter out common parameters to check only specific ones
            $actualSpecificParams = $params | Where-Object { $_ -notin $allCommonParameters }
            (@(Compare-Object -ReferenceObject $specificParameters -DifferenceObject $actualSpecificParams).Count ) | Should -Be 0
        }
    }

    Context "Validation - unknown clients or projects" {
        BeforeEach {
            $testConfig = [PSCustomObject]@{
                Clients = @(
                    [PSCustomObject]@{ Name = 'ClientA'; Projects = @('Project Alpha', 'Project Beta') }
                    [PSCustomObject]@{ Name = 'ClientB'; Projects = @('Website') }
                )
            }
            Mock -CommandName 'Get-PstConfig' -ModuleName 'PsTimeTracking' -MockWith { $testConfig }
            Mock -CommandName 'Restore-PstDay' -ModuleName 'PsTimeTracking' -MockWith {
                @(
                    [PSCustomObject]@{ Client = 'ClientA'; Project = 'Project Alpha'; StartTime = $null; Elapsed = New-TimeSpan -Minutes 60 }
                )
            }
        }

        It 'Should warn when FromClient is not found' {
            { Move-PstTime -FromClient 'NonExistent' -FromProject 'Project Alpha' -ToClient 'ClientB' -ToProject 'Website' -Minutes 10 -WarningAction Stop } | Should -Throw
        }

        It 'Should warn when FromProject is not found for FromClient' {
            { Move-PstTime -FromClient 'ClientA' -FromProject 'NonExistent' -ToClient 'ClientB' -ToProject 'Website' -Minutes 10 -WarningAction Stop } | Should -Throw
        }

        It 'Should warn when ToClient is not found' {
            { Move-PstTime -FromClient 'ClientA' -FromProject 'Project Alpha' -ToClient 'NonExistent' -ToProject 'Website' -Minutes 10 -WarningAction Stop } | Should -Throw
        }

        It 'Should warn when ToProject is not found for ToClient' {
            { Move-PstTime -FromClient 'ClientA' -FromProject 'Project Alpha' -ToClient 'ClientB' -ToProject 'NonExistent' -Minutes 10 -WarningAction Stop } | Should -Throw
        }

        It 'Should warn when there is no work recorded for today' {
            Mock -CommandName 'Restore-PstDay' -ModuleName 'PsTimeTracking' -MockWith { $null }
            { Move-PstTime -FromClient 'ClientA' -FromProject 'Project Alpha' -ToClient 'ClientB' -ToProject 'Website' -Minutes 10 -WarningAction Stop } | Should -Throw
        }

        It 'Should warn when there is no time in the source bucket' {
            Mock -CommandName 'Restore-PstDay' -ModuleName 'PsTimeTracking' -MockWith {
                @(
                    [PSCustomObject]@{ Client = 'ClientB'; Project = 'Website'; StartTime = $null; Elapsed = New-TimeSpan -Minutes 60 }
                )
            }
            { Move-PstTime -FromClient 'ClientA' -FromProject 'Project Alpha' -ToClient 'ClientB' -ToProject 'Website' -Minutes 10 -WarningAction Stop } | Should -Throw
        }

        It 'Should warn when requesting more minutes than available in the source bucket' {
            { Move-PstTime -FromClient 'ClientA' -FromProject 'Project Alpha' -ToClient 'ClientB' -ToProject 'Website' -Minutes 120 -WarningAction Stop } | Should -Throw
        }
    }

    Context "Functionality - successful move" {
        BeforeEach {
            $testConfig = [PSCustomObject]@{
                Clients = @(
                    [PSCustomObject]@{ Name = 'ClientA'; Projects = @('Project Alpha') }
                    [PSCustomObject]@{ Name = 'ClientB'; Projects = @('Website') }
                )
            }
            Mock -CommandName 'Get-PstConfig' -ModuleName 'PsTimeTracking' -MockWith { $testConfig }
            Mock -CommandName 'Restore-PstDay' -ModuleName 'PsTimeTracking' -MockWith {
                @(
                    [PSCustomObject]@{ Client = 'ClientA'; Project = 'Project Alpha'; StartTime = $null; Elapsed = New-TimeSpan -Minutes 60 }
                )
            }
            Mock -CommandName 'Backup-PstDay' -ModuleName 'PsTimeTracking' -MockWith {}
            Mock -CommandName 'Get-PstDaySummary' -ModuleName 'PsTimeTracking' -MockWith {}
            Mock -CommandName 'Clear-Host' -ModuleName 'PsTimeTracking' -MockWith {}
        }

        It 'Should not throw with valid parameters' {
            { Move-PstTime -FromClient 'ClientA' -FromProject 'Project Alpha' -ToClient 'ClientB' -ToProject 'Website' -Minutes 30 } | Should -Not -Throw
        }

        It 'Should call Backup-PstDay after a successful move' {
            Move-PstTime -FromClient 'ClientA' -FromProject 'Project Alpha' -ToClient 'ClientB' -ToProject 'Website' -Minutes 30
            Should -Invoke 'Backup-PstDay' -ModuleName 'PsTimeTracking' -Exactly 1
        }

        It 'Should call Get-PstDaySummary after a successful move' {
            Move-PstTime -FromClient 'ClientA' -FromProject 'Project Alpha' -ToClient 'ClientB' -ToProject 'Website' -Minutes 30
            Should -Invoke 'Get-PstDaySummary' -ModuleName 'PsTimeTracking' -Exactly 1
        }

        It 'Should reduce the source bucket by the moved minutes' {
            $script:capturedWork = $null
            Mock -CommandName 'Backup-PstDay' -ModuleName 'PsTimeTracking' -MockWith {
                param($TodaysWork)
                $script:capturedWork = $TodaysWork
            }
            Move-PstTime -FromClient 'ClientA' -FromProject 'Project Alpha' -ToClient 'ClientB' -ToProject 'Website' -Minutes 30
            $sourceTotal = ($script:capturedWork | Where-Object { $_.Client -eq 'ClientA' -and $_.Project -eq 'Project Alpha' } | Measure-Object { $_.Elapsed.TotalMinutes } -Sum).Sum
            $sourceTotal | Should -Be 30
        }

        It 'Should add the moved minutes to the destination bucket' {
            $script:capturedWork = $null
            Mock -CommandName 'Backup-PstDay' -ModuleName 'PsTimeTracking' -MockWith {
                param($TodaysWork)
                $script:capturedWork = $TodaysWork
            }
            Move-PstTime -FromClient 'ClientA' -FromProject 'Project Alpha' -ToClient 'ClientB' -ToProject 'Website' -Minutes 30
            $destTotal = ($script:capturedWork | Where-Object { $_.Client -eq 'ClientB' -and $_.Project -eq 'Website' } | Measure-Object { $_.Elapsed.TotalMinutes } -Sum).Sum
            $destTotal | Should -Be 30
        }

        It 'Should remove the source entry entirely when moving all its minutes' {
            $script:capturedWork = $null
            Mock -CommandName 'Backup-PstDay' -ModuleName 'PsTimeTracking' -MockWith {
                param($TodaysWork)
                $script:capturedWork = $TodaysWork
            }
            Move-PstTime -FromClient 'ClientA' -FromProject 'Project Alpha' -ToClient 'ClientB' -ToProject 'Website' -Minutes 60
            $sourceEntries = $script:capturedWork | Where-Object { $_.Client -eq 'ClientA' -and $_.Project -eq 'Project Alpha' }
            $sourceEntries | Should -BeNullOrEmpty
        }
    }
}
