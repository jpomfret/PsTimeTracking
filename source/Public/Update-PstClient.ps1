<#
.SYNOPSIS
Updates an existing client's name.

.DESCRIPTION
Updates the name of an existing client in the configuration.

.PARAMETER Name
The current name of the client.

.PARAMETER NewName
The new name for the client.

.EXAMPLE
PS> Update-PstClient -Name 'ClientA' -NewName 'Client Alpha'

Renames ClientA to 'Client Alpha'.
#>
function Update-PstClient {
    [CmdletBinding()]
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

        [Parameter(Mandatory)]
        [string]$NewName
    )

    $config = Get-PstConfig

    $existingClient = $config.Clients | Where-Object { $_.Name -eq $Name }
    if (!$existingClient) {
        Write-Warning "Client '$Name' not found."
        return
    }

    # Check if new name already exists
    $conflictClient = $config.Clients | Where-Object { $_.Name -eq $NewName }
    if ($conflictClient) {
        Write-Warning "A client with name '$NewName' already exists."
        return
    }

    # Recreate the client list with updated name
    $updatedClients = foreach ($client in $config.Clients) {
        if ($client.Name -eq $Name) {
            [PSCustomObject]@{
                Name = $NewName
                Projects = $client.Projects
            }
        } else {
            $client
        }
    }

    # Recreate config object
    $newConfig = [PSCustomObject]@{
        Clients = $updatedClients
    }

    Save-PstConfig -Config $newConfig

    Write-Host "Client renamed from '$Name' to '$NewName' successfully." -ForegroundColor Green
}
