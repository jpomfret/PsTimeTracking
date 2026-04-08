<#
.SYNOPSIS
Removes a client from the configuration.

.DESCRIPTION
Removes the specified client and all its projects from the configuration.

.PARAMETER Name
The name of the client to remove.

.PARAMETER Force
If specified, removes the client without confirmation.

.EXAMPLE
PS> Remove-PstClient -Name 'ClientC'

Prompts for confirmation, then removes ClientC from the configuration.

.EXAMPLE
PS> Remove-PstClient -Name 'ClientC' -Force

Removes ClientC without confirmation.
#>
function Remove-PstClient {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        [Parameter(Mandatory)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            $configFile = Join-Path $env:localappdata 'PstTimeTracker\config.json'
            if (Test-Path $configFile) {
                $config = Get-Content $configFile -Raw | ConvertFrom-Json
                $config.Clients.Name | Where-Object { $_ -like "$wordToComplete*" }
            }
        })]
        [string]$Name,

        [Parameter()]
        [switch]$Force
    )

    $config = Get-PstConfig

    $existingClient = $config.Clients | Where-Object { $_.Name -eq $Name }
    if (!$existingClient) {
        Write-Warning "Client '$Name' not found."
        return
    }

    if ($Force -or $PSCmdlet.ShouldProcess($Name, "Remove client")) {
        $updatedClients = $config.Clients | Where-Object { $_.Name -ne $Name }

        # Recreate config object to avoid mutation issues
        $newConfig = [PSCustomObject]@{
            Clients = $updatedClients
        }

        Save-PstConfig -Config $newConfig
        Write-Host "Client '$Name' removed successfully." -ForegroundColor Green
    }
}
