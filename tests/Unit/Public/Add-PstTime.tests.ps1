
Describe "Add-PstTime Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        It "Should only contain our specific parameters" {
            $command = 'Add-PstTime'
            [object[]]$params = (Get-Command $command).Parameters.Keys
            [object[]]$specificParameters = 'Client','Project','Minutes','StartTime'
            $allCommonParameters = [System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

            # Filter out common parameters to check only specific ones
            $actualSpecificParams = $params | Where-Object { $_ -notin $allCommonParameters }
            (@(Compare-Object -ReferenceObject $specificParameters -DifferenceObject $actualSpecificParams).Count ) | Should -Be 0
        }
    }

    Context "Validation - unknown client or project" {
        BeforeEach {
            $testConfig = [PSCustomObject]@{
                Clients = @(
                    [PSCustomObject]@{ Name = 'ClientA'; Projects = @('Project Alpha') }
                )
            }
            Mock -CommandName 'Get-PstConfig' -ModuleName 'PsTimeTracking' -MockWith { $testConfig }
        }

        It 'Should warn and return when client is not found' {
            { Add-PstTime -Client 'NonExistent' -Project 'Project Alpha' -Minutes 30 -WarningAction Stop } | Should -Throw
        }

        It 'Should warn and return when project is not found for the client' {
            { Add-PstTime -Client 'ClientA' -Project 'NonExistent' -Minutes 30 -WarningAction Stop } | Should -Throw
        }
    }

    Context "Functionality - valid client and project" {
        BeforeEach {
            $testConfig = [PSCustomObject]@{
                Clients = @(
                    [PSCustomObject]@{ Name = 'ClientA'; Projects = @('Project Alpha') }
                )
            }
            Mock -CommandName 'Get-PstConfig' -ModuleName 'PsTimeTracking' -MockWith { $testConfig }
            Mock -CommandName 'Restore-PstDay' -ModuleName 'PsTimeTracking' -MockWith { @() }
            Mock -CommandName 'Backup-PstDay' -ModuleName 'PsTimeTracking' -MockWith {}
            Mock -CommandName 'Get-PstDaySummary' -ModuleName 'PsTimeTracking' -MockWith {}
            Mock -CommandName 'Clear-Host' -ModuleName 'PsTimeTracking' -MockWith {}
        }

        It 'Should not throw with valid parameters' {
            { Add-PstTime -Client 'ClientA' -Project 'Project Alpha' -Minutes 30 } | Should -Not -Throw
        }

        It 'Should call Backup-PstDay after adding time' {
            Add-PstTime -Client 'ClientA' -Project 'Project Alpha' -Minutes 30
            Should -Invoke 'Backup-PstDay' -ModuleName 'PsTimeTracking' -Exactly 1
        }

        It 'Should call Get-PstDaySummary after adding time' {
            Add-PstTime -Client 'ClientA' -Project 'Project Alpha' -Minutes 30
            Should -Invoke 'Get-PstDaySummary' -ModuleName 'PsTimeTracking' -Exactly 1
        }

        It 'Should pass the new entry with correct minutes to Backup-PstDay' {
            $script:capturedWork = $null
            Mock -CommandName 'Backup-PstDay' -ModuleName 'PsTimeTracking' -MockWith {
                param($TodaysWork)
                $script:capturedWork = $TodaysWork
            }
            Add-PstTime -Client 'ClientA' -Project 'Project Alpha' -Minutes 45
            $newEntry = $script:capturedWork | Where-Object { $_.Client -eq 'ClientA' -and $_.Project -eq 'Project Alpha' }
            $newEntry | Should -Not -BeNullOrEmpty
            $newEntry.Elapsed.TotalMinutes | Should -Be 45
        }
    }
}
