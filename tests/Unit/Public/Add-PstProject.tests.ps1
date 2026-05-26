
Describe "Add-PstProject Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        It "Should only contain our specific parameters" {
            $command = 'Add-PstProject'
            [object[]]$params = (Get-Command $command).Parameters.Keys
            [object[]]$specificParameters = 'Client','Project'
            $allCommonParameters = [System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

            # Filter out common parameters to check only specific ones
            $actualSpecificParams = $params | Where-Object { $_ -notin $allCommonParameters }
            (@(Compare-Object -ReferenceObject $specificParameters -DifferenceObject $actualSpecificParams).Count ) | Should -Be 0
        }

        It "Should have mandatory parameters" {
            (Get-Command Add-PstProject).Parameters['Client'].Attributes.Mandatory | Should -Be $true
            (Get-Command Add-PstProject).Parameters['Project'].Attributes.Mandatory | Should -Be $true
        }
    }

    Context "Config structure after Add-PstProject" {
        BeforeEach {
            $script:capturedConfig = $null

            $testConfig = [PSCustomObject]@{
                Clients = @(
                    [PSCustomObject]@{
                        Name     = 'TestClient'
                        Projects = @('ExistingProject', 'AnotherProject')
                    }
                    [PSCustomObject]@{
                        Name     = 'OtherClient'
                        Projects = @('OtherProject')
                    }
                )
            }

            Mock -CommandName 'Get-PstConfig' -ModuleName 'PsTimeTracking' -MockWith { $testConfig }
            Mock -CommandName 'Save-PstConfig' -ModuleName 'PsTimeTracking' -MockWith {
                param($Config)
                $script:capturedConfig = $Config
            }
        }

        It 'Should call Save-PstConfig when adding a project' {
            Add-PstProject -Client 'TestClient' -Project 'NewProject'
            Should -Invoke 'Save-PstConfig' -ModuleName 'PsTimeTracking' -Exactly 1
        }

        It 'Should save Clients as an array' {
            Add-PstProject -Client 'TestClient' -Project 'NewProject'
            $script:capturedConfig.Clients.GetType().IsArray | Should -Be $true
        }

        It 'Should save each client with Projects as an array' {
            Add-PstProject -Client 'TestClient' -Project 'NewProject'
            foreach ($c in $script:capturedConfig.Clients) {
                $c.Projects.GetType().IsArray | Should -Be $true
            }
        }

        It 'Should add the new project to the specified client' {
            Add-PstProject -Client 'TestClient' -Project 'NewProject'
            $client = $script:capturedConfig.Clients | Where-Object { $_.Name -eq 'TestClient' }
            $client.Projects | Should -Contain 'NewProject'
        }

        It 'Should preserve existing projects when adding a new one' {
            Add-PstProject -Client 'TestClient' -Project 'NewProject'
            $client = $script:capturedConfig.Clients | Where-Object { $_.Name -eq 'TestClient' }
            $client.Projects | Should -Contain 'ExistingProject'
            $client.Projects | Should -Contain 'AnotherProject'
        }

        It 'Should not modify other clients when adding a project' {
            Add-PstProject -Client 'TestClient' -Project 'NewProject'
            $client = $script:capturedConfig.Clients | Where-Object { $_.Name -eq 'OtherClient' }
            $client.Projects | Should -Contain 'OtherProject'
            $client.Projects | Should -Not -Contain 'NewProject'
        }
    }
}
