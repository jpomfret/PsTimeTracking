
Describe "Update-PstProject Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        It "Should only contain our specific parameters" {
            $command = 'Update-PstProject'
            [object[]]$params = (Get-Command $command).Parameters.Keys
            [object[]]$specificParameters = 'Client','Project','NewName'
            $allCommonParameters = [System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

            # Filter out common parameters to check only specific ones
            $actualSpecificParams = $params | Where-Object { $_ -notin $allCommonParameters }
            (@(Compare-Object -ReferenceObject $specificParameters -DifferenceObject $actualSpecificParams).Count ) | Should -Be 0
        }

        It "Should have mandatory parameters" {
            (Get-Command Update-PstProject).Parameters['Client'].Attributes.Mandatory | Should -Be $true
            (Get-Command Update-PstProject).Parameters['Project'].Attributes.Mandatory | Should -Be $true
            (Get-Command Update-PstProject).Parameters['NewName'].Attributes.Mandatory | Should -Be $true
        }
    }

    Context "Config structure after Update-PstProject" {
        BeforeEach {
            $script:capturedConfig = $null

            $testConfig = [PSCustomObject]@{
                Clients = @(
                    [PSCustomObject]@{
                        Name     = 'TestClient'
                        Projects = @('OldProjectName', 'OtherProject')
                    }
                    [PSCustomObject]@{
                        Name     = 'OtherClient'
                        Projects = @('UnrelatedProject')
                    }
                )
            }

            Mock -CommandName 'Get-PstConfig' -ModuleName 'PsTimeTracking' -MockWith { $testConfig }
            Mock -CommandName 'Save-PstConfig' -ModuleName 'PsTimeTracking' -MockWith {
                param($Config)
                $script:capturedConfig = $Config
            }
        }

        It 'Should call Save-PstConfig when renaming a project' {
            Update-PstProject -Client 'TestClient' -Project 'OldProjectName' -NewName 'NewProjectName'
            Should -Invoke 'Save-PstConfig' -ModuleName 'PsTimeTracking' -Exactly 1
        }

        It 'Should save Clients as an array' {
            Update-PstProject -Client 'TestClient' -Project 'OldProjectName' -NewName 'NewProjectName'
            $script:capturedConfig.Clients.GetType().IsArray | Should -Be $true
        }

        It 'Should save each client with Projects as an array' {
            Update-PstProject -Client 'TestClient' -Project 'OldProjectName' -NewName 'NewProjectName'
            foreach ($c in $script:capturedConfig.Clients) {
                $c.Projects.GetType().IsArray | Should -Be $true
            }
        }

        It 'Should rename the project in the target client' {
            Update-PstProject -Client 'TestClient' -Project 'OldProjectName' -NewName 'NewProjectName'
            $client = $script:capturedConfig.Clients | Where-Object { $_.Name -eq 'TestClient' }
            $client.Projects | Should -Contain 'NewProjectName'
            $client.Projects | Should -Not -Contain 'OldProjectName'
        }

        It 'Should preserve other projects in the target client' {
            Update-PstProject -Client 'TestClient' -Project 'OldProjectName' -NewName 'NewProjectName'
            $client = $script:capturedConfig.Clients | Where-Object { $_.Name -eq 'TestClient' }
            $client.Projects | Should -Contain 'OtherProject'
        }

        It 'Should not modify other clients when renaming a project' {
            Update-PstProject -Client 'TestClient' -Project 'OldProjectName' -NewName 'NewProjectName'
            $client = $script:capturedConfig.Clients | Where-Object { $_.Name -eq 'OtherClient' }
            $client.Projects | Should -Contain 'UnrelatedProject'
            $client.Projects | Should -Not -Contain 'NewProjectName'
        }
    }
}
