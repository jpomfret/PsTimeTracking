
Describe "Get-PstProject Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        It "Should only contain our specific parameters" {
            $command = 'Get-PstProject'
            [object[]]$params = (Get-Command $command).Parameters.Keys
            [object[]]$specificParameters = 'Client'
            $allCommonParameters = [System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

            # Filter out common parameters to check only specific ones
            $actualSpecificParams = $params | Where-Object { $_ -notin $allCommonParameters }
            (@(Compare-Object -ReferenceObject $specificParameters -DifferenceObject $actualSpecificParams).Count ) | Should -Be 0
        }

        It "Should have a mandatory Client parameter" {
            (Get-Command Get-PstProject).Parameters['Client'].Attributes.Mandatory | Should -Be $true
        }
    }

    Context "Functionality" {
        BeforeEach {
            $testConfig = [PSCustomObject]@{
                Clients = @(
                    [PSCustomObject]@{ Name = 'ClientA'; Projects = @('Project Alpha', 'Project Beta') }
                    [PSCustomObject]@{ Name = 'ClientB'; Projects = @('Website') }
                )
            }
            Mock -CommandName 'Get-PstConfig' -ModuleName 'PsTimeTracking' -MockWith { $testConfig }
        }

        It 'Should return the projects for a valid client' {
            $result = Get-PstProject -Client 'ClientA'
            $result | Should -Contain 'Project Alpha'
            $result | Should -Contain 'Project Beta'
        }

        It 'Should only return projects for the specified client' {
            $result = Get-PstProject -Client 'ClientA'
            $result | Should -Not -Contain 'Website'
        }

        It 'Should return null when client is not found' {
            $result = Get-PstProject -Client 'NonExistent' -WarningAction SilentlyContinue
            $result | Should -BeNullOrEmpty
        }

        It 'Should write a warning when client is not found' {
            { Get-PstProject -Client 'NonExistent' -WarningAction Stop } | Should -Throw
        }
    }
}
