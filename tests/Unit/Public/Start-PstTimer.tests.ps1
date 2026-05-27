
Describe "Start-PstTimer Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        It "Should only contain our specific parameters" {
            $command = 'Start-PstTimer'
            [object[]]$params = (Get-Command $command).Parameters.Keys
            [object[]]$specificParameters = 'Client','Project'
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

        It 'Should warn when client is not found' {
            { Start-PstTimer -Client 'NonExistent' -Project 'Project Alpha' -WarningAction Stop } | Should -Throw
        }

        It 'Should warn when project is not found for the client' {
            { Start-PstTimer -Client 'ClientA' -Project 'NonExistent' -WarningAction Stop } | Should -Throw
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
            Mock -CommandName 'Read-Host' -ModuleName 'PsTimeTracking' -MockWith { '' }
            Mock -CommandName 'Backup-PstDay' -ModuleName 'PsTimeTracking' -MockWith {}
            Mock -CommandName 'Get-PstDaySummary' -ModuleName 'PsTimeTracking' -MockWith {}
            Mock -CommandName 'Clear-Host' -ModuleName 'PsTimeTracking' -MockWith {}
        }

        It 'Should not throw with valid client and project' {
            { Start-PstTimer -Client 'ClientA' -Project 'Project Alpha' } | Should -Not -Throw
        }

        It 'Should call Backup-PstDay after the timer stops' {
            Start-PstTimer -Client 'ClientA' -Project 'Project Alpha'
            Should -Invoke 'Backup-PstDay' -ModuleName 'PsTimeTracking' -Exactly 1
        }

        It 'Should call Get-PstDaySummary after the timer stops' {
            Start-PstTimer -Client 'ClientA' -Project 'Project Alpha'
            Should -Invoke 'Get-PstDaySummary' -ModuleName 'PsTimeTracking' -Exactly 1
        }

        It 'Should pass an entry with the correct client and project to Backup-PstDay' {
            $script:capturedWork = $null
            Mock -CommandName 'Backup-PstDay' -ModuleName 'PsTimeTracking' -MockWith {
                param($TodaysWork)
                $script:capturedWork = $TodaysWork
            }
            Start-PstTimer -Client 'ClientA' -Project 'Project Alpha'
            $timerEntry = $script:capturedWork | Where-Object { $_.Client -eq 'ClientA' -and $_.Project -eq 'Project Alpha' }
            $timerEntry | Should -Not -BeNullOrEmpty
        }

        It 'Should show existing day summary if work exists before the timer starts' {
            Mock -CommandName 'Restore-PstDay' -ModuleName 'PsTimeTracking' -MockWith {
                @(
                    [PSCustomObject]@{ Client = 'ClientB'; Project = 'Website'; StartTime = $null; Elapsed = New-TimeSpan -Minutes 30 }
                )
            }
            Start-PstTimer -Client 'ClientA' -Project 'Project Alpha'
            Should -Invoke 'Get-PstDaySummary' -ModuleName 'PsTimeTracking' -Exactly 2
        }
    }
}
