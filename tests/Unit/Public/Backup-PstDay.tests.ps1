
Describe "Backup-PstDay Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        It "Should only contain our specific parameters" {
            $command = 'Backup-PstDay'
            [object[]]$params = (Get-Command $command).Parameters.Keys
            [object[]]$specificParameters = 'TodaysWork'
            $allCommonParameters = [System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

            # Filter out common parameters to check only specific ones
            $actualSpecificParams = $params | Where-Object { $_ -notin $allCommonParameters }
            (@(Compare-Object -ReferenceObject $specificParameters -DifferenceObject $actualSpecificParams).Count ) | Should -Be 0
        }
    }

    Context "Functionality" {
        BeforeEach {
            $script:testWork = @(
                [PSCustomObject]@{ Client = 'ClientA'; Project = 'Project Alpha'; StartTime = $null; Elapsed = New-TimeSpan -Minutes 60 }
            )
            Mock -CommandName 'Test-Path' -ModuleName 'PsTimeTracking' -MockWith { $true }
            Mock -CommandName 'New-Item' -ModuleName 'PsTimeTracking' -MockWith {}
            Mock -CommandName 'Out-File' -ModuleName 'PsTimeTracking' -MockWith {}
            Mock -CommandName 'Get-ChildItem' -ModuleName 'PsTimeTracking' -MockWith { @() }
        }

        It 'Should not throw with valid work data' {
            { Backup-PstDay -TodaysWork $script:testWork } | Should -Not -Throw
        }

        It 'Should create the folder when it does not exist' {
            Mock -CommandName 'Test-Path' -ModuleName 'PsTimeTracking' -MockWith { $false }
            Backup-PstDay -TodaysWork $script:testWork
            Should -Invoke 'New-Item' -ModuleName 'PsTimeTracking' -Exactly 1
        }

        It 'Should not create the folder when it already exists' {
            Mock -CommandName 'Test-Path' -ModuleName 'PsTimeTracking' -MockWith { $true }
            Backup-PstDay -TodaysWork $script:testWork
            Should -Invoke 'New-Item' -ModuleName 'PsTimeTracking' -Exactly 0
        }

        It 'Should write the JSON file when work data is provided' {
            Backup-PstDay -TodaysWork $script:testWork
            Should -Invoke 'Out-File' -ModuleName 'PsTimeTracking' -Exactly 1
        }

        It 'Should check for old files to clean up' {
            Backup-PstDay -TodaysWork $script:testWork
            Should -Invoke 'Get-ChildItem' -ModuleName 'PsTimeTracking' -Exactly 1
        }

        It 'Should only prune todayswork-*.json files, not config.json' {
            $script:capturedFilter = $null
            Mock -CommandName 'Get-ChildItem' -ModuleName 'PsTimeTracking' -MockWith {
                param($Path, $Filter)
                $script:capturedFilter = $Filter
                @()
            }
            Backup-PstDay -TodaysWork $script:testWork
            $script:capturedFilter | Should -Be 'todayswork-*.json'
        }
    }
}
