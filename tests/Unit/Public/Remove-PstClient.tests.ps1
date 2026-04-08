
Describe "Remove-PstClient Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        It "Should only contain our specific parameters" {
            $command = 'Remove-PstClient'
            [object[]]$params = (Get-Command $command).Parameters.Keys
            [object[]]$specificParameters = 'Name','Force'
            $allCommonParameters = [System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters
            $allCommonParameters += 'WhatIf', 'Confirm' # ShouldProcess adds these

            # Filter out common parameters to check only specific ones
            $actualSpecificParams = $params | Where-Object { $_ -notin $allCommonParameters }
            (@(Compare-Object -ReferenceObject $specificParameters -DifferenceObject $actualSpecificParams).Count ) | Should -Be 0
        }

        It "Should have a mandatory Name parameter" {
            (Get-Command Remove-PstClient).Parameters['Name'].Attributes.Mandatory | Should -Be $true
        }

        It "Should support ShouldProcess" {
            (Get-Command Remove-PstClient).Parameters.ContainsKey('WhatIf') | Should -Be $true
            (Get-Command Remove-PstClient).Parameters.ContainsKey('Confirm') | Should -Be $true
        }
    }
}
