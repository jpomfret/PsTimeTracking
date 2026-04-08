
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
}
