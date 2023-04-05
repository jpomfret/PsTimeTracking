
Describe "$commandName Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        It "Should only contain our specific parameters" {
            $command = 'Get-PstDaySummary'
            [object[]]$params = (Get-Command $command).Parameters.Keys | Where-Object {$_ -notin ('whatif', 'confirm')}
            [object[]]$knownParameters = 'Date'
            #$knownParameters += [System.Management.Automation.PSCmdlet]::CommonParameters

            (@(Compare-Object -ReferenceObject ($knownParameters | Where-Object {$_}) -DifferenceObject $params).Count ) | Should -Be 0
        }
    }
}
