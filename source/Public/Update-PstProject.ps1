<#
.SYNOPSIS
Updates a project name for a client.

.DESCRIPTION
Renames an existing project for the specified client.

.PARAMETER Client
The name of the client whose project to update.

.PARAMETER Project
The current name of the project.

.PARAMETER NewName
The new name for the project.

.EXAMPLE
PS> Update-PstProject -Client 'ClientA' -Project 'Project Alpha' -NewName 'Alpha Project v2'

Renames the project from 'Project Alpha' to 'Alpha Project v2' for ClientA.
#>
function Update-PstProject {
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
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            $clientName = $fakeBoundParameters['Client']
            if ($clientName) {
                if ($IsWindows -or $PSVersionTable.PSVersion.Major -le 5) {
                    $configFile = Join-Path $env:LOCALAPPDATA 'PstTimeTracker\config.json'
                } else {
                    $configFile = Join-Path $HOME '.local/share/PstTimeTracker/config.json'
                }
                if (Test-Path $configFile) {
                    $config = Get-Content $configFile -Raw | ConvertFrom-Json
                    $client = $config.Clients | Where-Object { $_.Name -eq $clientName }
                    if ($client) {
                        $client.Projects | Where-Object { $_ -like "$wordToComplete*" }
                    }
                }
            }
        })]
        [string]$Project,

        [Parameter(Mandatory)]
        [string]$NewName
    )

    $config = Get-PstConfig

    $clientObj = $config.Clients | Where-Object { $_.Name -eq $Client }
    if (!$clientObj) {
        Write-Warning "Client '$Client' not found."
        return
    }

    if ($clientObj.Projects -notcontains $Project) {
        Write-Warning "Project '$Project' not found for client '$Client'."
        return
    }

    # Check if new name already exists
    if ($clientObj.Projects -contains $NewName) {
        Write-Warning "A project with name '$NewName' already exists for client '$Client'."
        return
    }

    # Create updated project list
    $updatedProjects = $clientObj.Projects | ForEach-Object {
        if ($_ -eq $Project) { $NewName } else { $_ }
    }

    # Recreate the client list with updated projects
    $updatedClients = foreach ($client in $config.Clients) {
        if ($client.Name -eq $Client) {
            [PSCustomObject]@{
                Name = $client.Name
                Projects = $updatedProjects
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

    Write-Host "Project renamed from '$Project' to '$NewName' for client '$Client' successfully." -ForegroundColor Green
}
