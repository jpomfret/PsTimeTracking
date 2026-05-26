
Describe "Update-PstClient Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        It "Should only contain our specific parameters" {
            $command = 'Update-PstClient'
            [object[]]$params = (Get-Command $command).Parameters.Keys
            [object[]]$specificParameters = 'Name','NewName'
            $allCommonParameters = [System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

            # Filter out common parameters to check only specific ones
            $actualSpecificParams = $params | Where-Object { $_ -notin $allCommonParameters }
            (@(Compare-Object -ReferenceObject $specificParameters -DifferenceObject $actualSpecificParams).Count ) | Should -Be 0
        }

        It "Should have mandatory parameters" {
            (Get-Command Update-PstClient).Parameters['Name'].Attributes.Mandatory | Should -Be $true
            (Get-Command Update-PstClient).Parameters['NewName'].Attributes.Mandatory | Should -Be $true
        }
    }

    Context "Config structure after Update-PstClient" {
        BeforeEach {
            $script:capturedConfig = $null

            $testConfig = [PSCustomObject]@{
                Clients = @(
                    [PSCustomObject]@{
                        Name     = 'OldName'
                        Projects = @('Project1', 'Project2')
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

        It 'Should call Save-PstConfig when renaming a client' {
            Update-PstClient -Name 'OldName' -NewName 'NewName'
            Should -Invoke 'Save-PstConfig' -ModuleName 'PsTimeTracking' -Exactly 1
        }

        It 'Should save Clients as an array' {
            Update-PstClient -Name 'OldName' -NewName 'NewName'
            $script:capturedConfig.Clients.GetType().IsArray | Should -Be $true
        }

        It 'Should save the client under the new name' {
            Update-PstClient -Name 'OldName' -NewName 'NewName'
            $script:capturedConfig.Clients | Where-Object { $_.Name -eq 'NewName' } | Should -Not -BeNullOrEmpty
        }

        It 'Should remove the old client name from the saved config' {
            Update-PstClient -Name 'OldName' -NewName 'NewName'
            $script:capturedConfig.Clients | Where-Object { $_.Name -eq 'OldName' } | Should -BeNullOrEmpty
        }

        It 'Should preserve the renamed client projects' {
            Update-PstClient -Name 'OldName' -NewName 'NewName'
            $client = $script:capturedConfig.Clients | Where-Object { $_.Name -eq 'NewName' }
            $client.Projects | Should -Contain 'Project1'
            $client.Projects | Should -Contain 'Project2'
        }

        It 'Should not modify other clients when renaming' {
            Update-PstClient -Name 'OldName' -NewName 'NewName'
            $client = $script:capturedConfig.Clients | Where-Object { $_.Name -eq 'OtherClient' }
            $client | Should -Not -BeNullOrEmpty
            $client.Projects | Should -Contain 'OtherProject'
        }
    }
}
