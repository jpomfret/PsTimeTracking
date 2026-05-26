<#
.SYNOPSIS
Removes a project from a client.

.DESCRIPTION
Removes the specified project from a client's project list.

.PARAMETER Client
The name of the client to remove the project from.

.PARAMETER Project
The name of the project to remove.

.PARAMETER Force
If specified, removes the project without confirmation.

.EXAMPLE
PS> Remove-PstProject -Client 'ClientA' -Project 'Old Project'

Prompts for confirmation, then removes 'Old Project' from ClientA.

.EXAMPLE
PS> Remove-PstProject -Client 'ClientA' -Project 'Old Project' -Force

Removes 'Old Project' from ClientA without confirmation.
#>
function Remove-PstProject {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
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

        [Parameter()]
        [switch]$Force
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

    if ($Force -or $PSCmdlet.ShouldProcess("$Client - $Project", "Remove project")) {
        $updatedProjects = @($clientObj.Projects | Where-Object { $_ -ne $Project })

        # Recreate the client list with updated projects
        $updatedClients = @(foreach ($clientEntry in $config.Clients) {
            if ($clientEntry.Name -eq $Client) {
                [PSCustomObject]@{
                    Name     = $clientEntry.Name
                    Projects = $updatedProjects
                }
            } else {
                [PSCustomObject]@{
                    Name     = $clientEntry.Name
                    Projects = @($clientEntry.Projects)
                }
            }
        })

        # Recreate config object
        $newConfig = [PSCustomObject]@{
            Clients = $updatedClients
        }

        Save-PstConfig -Config $newConfig
        Write-Host "Project '$Project' removed from client '$Client' successfully." -ForegroundColor Green
    }
}
