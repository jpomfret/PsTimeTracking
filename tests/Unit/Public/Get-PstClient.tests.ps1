
Describe "Get-PstClient Unit Tests" -Tag 'UnitTests' {
    BeforeAll {
        # Ensure we have a clean config for testing
        if ($IsWindows -or $PSVersionTable.PSVersion.Major -le 5) {
            $configFile = Join-Path $env:LOCALAPPDATA 'PstTimeTracker\config.json'
        } else {
            $configFile = Join-Path $HOME '.local/share/PstTimeTracker/config.json'
        }
        if (Test-Path $configFile) {
            Remove-Item $configFile -Force
        }
    }

    Context "Validate parameters" {
        It "Should only contain our specific parameters" {
            $command = 'Get-PstClient'
            [object[]]$params = (Get-Command $command).Parameters.Keys
            [object[]]$specificParameters = 'Name'
            $allCommonParameters = [System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

            # Filter out common parameters to check only specific ones
            $actualSpecificParams = $params | Where-Object { $_ -notin $allCommonParameters }
            (@(Compare-Object -ReferenceObject $specificParameters -DifferenceObject $actualSpecificParams).Count ) | Should -Be 0
        }
    }

    Context "Functionality" {
        It "Should return all clients when no name is specified" {
            $clients = Get-PstClient
            $clients | Should -Not -BeNullOrEmpty
            $clients.Count | Should -BeGreaterThan 0
        }

        It "Should return a specific client when name is provided" {
            $client = Get-PstClient -Name 'ClientA'
            $client | Should -Not -BeNullOrEmpty
            $client.Name | Should -Be 'ClientA'
        }
    }
}
