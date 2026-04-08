<#
.SYNOPSIS
Gets projects for a specific client or all projects.

.DESCRIPTION
Returns projects for a specified client from the configuration.

.PARAMETER Client
The name of the client whose projects to retrieve.

.EXAMPLE
PS> Get-PstProject -Client 'ClientA'

Returns all projects for ClientA.
#>
function Get-PstProject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            if ($IsWindows -or $PSVersionTable.PSVersion.Major -le 5) {
                $configFile = Join-Path $env:LOCALAPPDATA 'PstTimeTracker\config.json'
            } else {
                $configFile = Join-Path $HOME '.local/share/PstTimeTracker/config.json'
            }
            if (Test-Path $configFile) {
                $config = Get-Content $configFile -Raw | ConvertFrom-Json
                $config.Clients.Name | Where-Object { $_ -like "$wordToComplete*" }
            }
        })]
        [string]$Client
    )

    $config = Get-PstConfig

    $clientObj = $config.Clients | Where-Object { $_.Name -eq $Client }
    if (!$clientObj) {
        Write-Warning "Client '$Client' not found."
        return $null
    }

    return $clientObj.Projects
}
