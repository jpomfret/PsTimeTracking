
Describe "Remove-PstProject Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        It "Should only contain our specific parameters" {
            $command = 'Remove-PstProject'
            [object[]]$params = (Get-Command $command).Parameters.Keys
            [object[]]$specificParameters = 'Client','Project','Force'
            $allCommonParameters = [System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters
            $allCommonParameters += 'WhatIf', 'Confirm' # ShouldProcess adds these

            # Filter out common parameters to check only specific ones
            $actualSpecificParams = $params | Where-Object { $_ -notin $allCommonParameters }
            (@(Compare-Object -ReferenceObject $specificParameters -DifferenceObject $actualSpecificParams).Count ) | Should -Be 0
        }

        It "Should have mandatory parameters" {
            (Get-Command Remove-PstProject).Parameters['Client'].Attributes.Mandatory | Should -Be $true
            (Get-Command Remove-PstProject).Parameters['Project'].Attributes.Mandatory | Should -Be $true
        }

        It "Should support ShouldProcess" {
            (Get-Command Remove-PstProject).Parameters.ContainsKey('WhatIf') | Should -Be $true
            (Get-Command Remove-PstProject).Parameters.ContainsKey('Confirm') | Should -Be $true
        }
    }

    Context "Config structure after Remove-PstProject" {
        BeforeEach {
            $script:capturedConfig = $null

            $testConfig = [PSCustomObject]@{
                Clients = @(
                    [PSCustomObject]@{
                        Name     = 'TestClient'
                        Projects = @('ProjectToRemove', 'LastProject')
                    }
                    [PSCustomObject]@{
                        Name     = 'OtherClient'
                        Projects = @('OtherProject1', 'OtherProject2')
                    }
                )
            }

            Mock -CommandName 'Get-PstConfig' -ModuleName 'PsTimeTracking' -MockWith { $testConfig }
            Mock -CommandName 'Save-PstConfig' -ModuleName 'PsTimeTracking' -MockWith {
                param($Config)
                $script:capturedConfig = $Config
            }
        }

        It 'Should call Save-PstConfig when removing a project' {
            Remove-PstProject -Client 'TestClient' -Project 'ProjectToRemove' -Force
            Should -Invoke 'Save-PstConfig' -ModuleName 'PsTimeTracking' -Exactly 1
        }

        It 'Should save Clients as an array' {
            Remove-PstProject -Client 'TestClient' -Project 'ProjectToRemove' -Force
            $script:capturedConfig.Clients.GetType().IsArray | Should -Be $true
        }

        It 'Should save target client with Projects as an array even when one project remains' {
            Remove-PstProject -Client 'TestClient' -Project 'ProjectToRemove' -Force
            $client = $script:capturedConfig.Clients | Where-Object { $_.Name -eq 'TestClient' }
            $client.Projects.GetType().IsArray | Should -Be $true
        }

        It 'Should remove the project from the target client' {
            Remove-PstProject -Client 'TestClient' -Project 'ProjectToRemove' -Force
            $client = $script:capturedConfig.Clients | Where-Object { $_.Name -eq 'TestClient' }
            $client.Projects | Should -Not -Contain 'ProjectToRemove'
        }

        It 'Should preserve remaining projects in the target client' {
            Remove-PstProject -Client 'TestClient' -Project 'ProjectToRemove' -Force
            $client = $script:capturedConfig.Clients | Where-Object { $_.Name -eq 'TestClient' }
            $client.Projects | Should -Contain 'LastProject'
        }

        It 'Should not modify other clients when removing a project' {
            Remove-PstProject -Client 'TestClient' -Project 'ProjectToRemove' -Force
            $client = $script:capturedConfig.Clients | Where-Object { $_.Name -eq 'OtherClient' }
            $client.Projects | Should -Contain 'OtherProject1'
            $client.Projects | Should -Contain 'OtherProject2'
        }
    }
}
