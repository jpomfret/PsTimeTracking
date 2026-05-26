
Describe "Remove-PstClient Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        It "Should only contain our specific parameters" {
            $command = 'Remove-PstClient'
            [object[]]$params = (Get-Command $command).Parameters.Keys
            [object[]]$specificParameters = 'Name','Force'
            $allCommonParameters = [System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters
            $allCommonParameters += 'WhatIf', 'Confirm' # ShouldProcess adds these

            # Filter out common parameters to check only specific ones
            $actualSpecificParams = $params | Where-Object { $_ -notin $allCommonParameters }
            (@(Compare-Object -ReferenceObject $specificParameters -DifferenceObject $actualSpecificParams).Count ) | Should -Be 0
        }

        It "Should have a mandatory Name parameter" {
            (Get-Command Remove-PstClient).Parameters['Name'].Attributes.Mandatory | Should -Be $true
        }

        It "Should support ShouldProcess" {
            (Get-Command Remove-PstClient).Parameters.ContainsKey('WhatIf') | Should -Be $true
            (Get-Command Remove-PstClient).Parameters.ContainsKey('Confirm') | Should -Be $true
        }
    }

    Context "Config structure after Remove-PstClient" {
        BeforeEach {
            $script:capturedConfig = $null

            $testConfig = [PSCustomObject]@{
                Clients = @(
                    [PSCustomObject]@{
                        Name     = 'ClientToRemove'
                        Projects = @('Project1')
                    }
                    [PSCustomObject]@{
                        Name     = 'RemainingClient'
                        Projects = @('ProjectA', 'ProjectB')
                    }
                )
            }

            Mock -CommandName 'Get-PstConfig' -ModuleName 'PsTimeTracking' -MockWith { $testConfig }
            Mock -CommandName 'Save-PstConfig' -ModuleName 'PsTimeTracking' -MockWith {
                param($Config)
                $script:capturedConfig = $Config
            }
        }

        It 'Should call Save-PstConfig when removing a client' {
            Remove-PstClient -Name 'ClientToRemove' -Force
            Should -Invoke 'Save-PstConfig' -ModuleName 'PsTimeTracking' -Exactly 1
        }

        It 'Should save Clients as an array even when one client remains' {
            Remove-PstClient -Name 'ClientToRemove' -Force
            $script:capturedConfig.Clients.GetType().IsArray | Should -Be $true
        }

        It 'Should remove the named client from the saved config' {
            Remove-PstClient -Name 'ClientToRemove' -Force
            $script:capturedConfig.Clients | Where-Object { $_.Name -eq 'ClientToRemove' } | Should -BeNullOrEmpty
        }

        It 'Should preserve remaining clients and their projects' {
            Remove-PstClient -Name 'ClientToRemove' -Force
            $remaining = $script:capturedConfig.Clients | Where-Object { $_.Name -eq 'RemainingClient' }
            $remaining | Should -Not -BeNullOrEmpty
            $remaining.Projects | Should -Contain 'ProjectA'
            $remaining.Projects | Should -Contain 'ProjectB'
        }
    }
}
