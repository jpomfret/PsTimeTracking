<#
.SYNOPSIS
Adds a project to a client.

.DESCRIPTION
Adds a new project to the specified client's project list.

.PARAMETER Client
The name of the client to add the project to.

.PARAMETER Project
The name of the project to add.

.EXAMPLE
PS> Add-PstProject -Client 'ClientA' -Project 'New Project'

Adds 'New Project' to ClientA's project list.
#>
function Add-PstProject {
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
        [string]$Client,

        [Parameter(Mandatory)]
        [string]$Project
    )

    $config = Get-PstConfig

    $clientObj = $config.Clients | Where-Object { $_.Name -eq $Client }
    if (!$clientObj) {
        Write-Warning "Client '$Client' not found. Use Add-PstClient to create it first."
        return
    }

    # Check if project already exists
    if ($clientObj.Projects -contains $Project) {
        Write-Warning "Project '$Project' already exists for client '$Client'."
        return
    }

    # Convert to ArrayList for easier manipulation
    $projectsList = [System.Collections.ArrayList]::new()
    if ($clientObj.Projects) {
        foreach ($proj in $clientObj.Projects) {
            $null = $projectsList.Add($proj)
        }
    }
    $null = $projectsList.Add($Project)

    # Recreate the client list with updated projects
    $updatedClients = foreach ($client in $config.Clients) {
        if ($client.Name -eq $Client) {
            [PSCustomObject]@{
                Name = $client.Name
                Projects = $projectsList.ToArray()
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

    Write-Host "Project '$Project' added to client '$Client' successfully." -ForegroundColor Green
}
