
Describe "Add-PstClient Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        It "Should only contain our specific parameters" {
            $command = 'Add-PstClient'
            [object[]]$params = (Get-Command $command).Parameters.Keys
            [object[]]$specificParameters = 'Name', 'Projects'
            $allCommonParameters = [System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

            # Filter out common parameters to check only specific ones
            $actualSpecificParams = $params | Where-Object { $_ -notin $allCommonParameters }
            (@(Compare-Object -ReferenceObject $specificParameters -DifferenceObject $actualSpecificParams).Count ) | Should -Be 0
        }

        It "Should have a mandatory Name parameter" {
            (Get-Command Add-PstClient).Parameters['Name'].Attributes.Mandatory | Should -Be $true
        }

        It "Should have an optional Projects parameter" {
            (Get-Command Add-PstClient).Parameters['Projects'].Attributes.Mandatory | Should -Be $false
        }
    }

    Context "Config structure after Add-PstClient" {
        BeforeEach {
            $script:capturedConfig = $null

            $testConfig = [PSCustomObject]@{
                Clients = @(
                    [PSCustomObject]@{
                        Name     = 'ExistingClient'
                        Projects = @('Project1', 'Project2')
                    }
                )
            }

            Mock -CommandName 'Get-PstConfig' -ModuleName 'PsTimeTracking' -MockWith { $testConfig }
            Mock -CommandName 'Save-PstConfig' -ModuleName 'PsTimeTracking' -MockWith {
                param($Config)
                $script:capturedConfig = $Config
            }
        }

        It 'Should call Save-PstConfig when adding a client' {
            Add-PstClient -Name 'NewClient'
            Should -Invoke 'Save-PstConfig' -ModuleName 'PsTimeTracking' -Exactly 1
        }

        It 'Should save Clients as an array' {
            Add-PstClient -Name 'NewClient'
            $script:capturedConfig.Clients.GetType().IsArray | Should -Be $true
        }

        It 'Should add the new client to the saved config' {
            Add-PstClient -Name 'NewClient'
            $script:capturedConfig.Clients | Where-Object { $_.Name -eq 'NewClient' } | Should -Not -BeNullOrEmpty
        }

        It 'Should save the new client with Projects as an array' {
            Add-PstClient -Name 'NewClient' -Projects @('ProjectA', 'ProjectB')
            $newClient = $script:capturedConfig.Clients | Where-Object { $_.Name -eq 'NewClient' }
            $newClient.Projects.GetType().IsArray | Should -Be $true
        }

        It 'Should preserve existing clients when adding a new one' {
            Add-PstClient -Name 'NewClient'
            $script:capturedConfig.Clients | Where-Object { $_.Name -eq 'ExistingClient' } | Should -Not -BeNullOrEmpty
        }
    }
}
