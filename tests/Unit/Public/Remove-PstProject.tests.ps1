
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
}
