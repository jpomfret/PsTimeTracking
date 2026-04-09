
Describe "$commandName Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        It "Should have no parameters" {
            $command = 'Start-PstDay'
            [object[]]$params = (Get-Command $command).Parameters.Keys
            $commonParams = [System.Management.Automation.PSCmdlet]::CommonParameters
            $commonParams += [System.Management.Automation.PSCmdlet]::OptionalCommonParameters
            $specificParams = $params | Where-Object {$_ -notin $commonParams}
            $specificParams.Count | Should -Be 0
        }
    }
}
