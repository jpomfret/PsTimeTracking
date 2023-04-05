
Describe "$commandName Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        It "Should only contain our specific parameters" -skip {
            $command = 'Start-PstDay'
            [object[]]$params = (Get-Command $command).Parameters.Keys | Where-Object {$_ -notin ('whatif', 'confirm')}
            [object[]]$knownParameters

            (@(Compare-Object -ReferenceObject ($knownParameters | Where-Object {$_}) -DifferenceObject $params).Count ) | Should -Be 0
        }
        It "Should have no parameters" {
            $command = 'Start-PstDay'
            [object[]]$params = (Get-Command $command).Parameters.Keys | Where-Object {$_ -notin ('whatif', 'confirm')}
            $params.Count | Should -Be 0
        }
    }
}
