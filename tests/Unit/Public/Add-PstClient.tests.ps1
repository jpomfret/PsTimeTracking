
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
}
