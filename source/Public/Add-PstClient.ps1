<#
.SYNOPSIS
Adds a new client to the configuration.

.DESCRIPTION
Adds a new client with an optional list of projects to the configuration.

.PARAMETER Name
The name of the client to add.

.PARAMETER Projects
Optional array of project names for this client.

.EXAMPLE
PS> Add-PstClient -Name 'ClientC' -Projects @('Project 1', 'Project 2')

Adds a new client called ClientC with two projects.

.EXAMPLE
PS> Add-PstClient -Name 'ClientD'

Adds a new client called ClientD with no projects.
#>
function Add-PstClient {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter()]
        [string[]]$Projects = @()
    )

    $config = Get-PstConfig

    # Check if client already exists
    $existingClient = $config.Clients | Where-Object { $_.Name -eq $Name }
    if ($existingClient) {
        Write-Warning "Client '$Name' already exists. Use Update-PstClient to modify it."
        return
    }

    # Create new client
    $newClient = [PSCustomObject]@{
        Name = $Name
        Projects = $Projects
    }

    # Convert to ArrayList for easier manipulation
    $clientsList = [System.Collections.ArrayList]::new()
    if ($config.Clients) {
        foreach ($client in $config.Clients) {
            $null = $clientsList.Add($client)
        }
    }
    $null = $clientsList.Add($newClient)

    # Recreate config object to avoid mutation issues
    $newConfig = [PSCustomObject]@{
        Clients = $clientsList.ToArray()
    }

    Save-PstConfig -Config $newConfig
}
