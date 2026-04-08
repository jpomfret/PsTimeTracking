<#
.SYNOPSIS
Gets all configured clients or a specific client.

.DESCRIPTION
Returns all clients from the configuration or a specific client by name.

.PARAMETER Name
Optional. The name of the client to retrieve. If not specified, all clients are returned.

.EXAMPLE
PS> Get-PstClient

Returns all configured clients.

.EXAMPLE
PS> Get-PstClient -Name 'ClientA'

Returns the ClientA configuration including its projects.
#>
function Get-PstClient {
    [CmdletBinding()]
    param(
        [Parameter()]
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
        [string]$Name
    )

    $config = Get-PstConfig

    if ($Name) {
        $client = $config.Clients | Where-Object { $_.Name -eq $Name }
        if ($client) {
            return $client
        } else {
            Write-Warning "Client '$Name' not found."
            return $null
        }
    } else {
        return $config.Clients
    }
}
