<#
.SYNOPSIS
Adds a chunk of time to the day so far.

.DESCRIPTION
Adds a chunk of time to the day so far.

.PARAMETER Client
The client to add time to. Must be a client configured in the system.

.PARAMETER Project
The project to add time to. Must be a project associated with the client.

.PARAMETER Minutes
The number of minutes to add.

.PARAMETER StartTime
If provided this will be added to the day summary.

.EXAMPLE
PS> Add-PstTime -Client ClientA -Project 'Project Alpha' -Minutes 60

Adds 60 mins to the day so far for ClientA - Project Alpha.

#>

function Add-PstTime {
    param (
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
        [int]$Minutes,

        [Parameter()]
        [datetime]$StartTime
    )

    # Validate client exists
    $config = Get-PstConfig
    $clientObj = $config.Clients | Where-Object { $_.Name -eq $Client }
    if (!$clientObj) {
        Write-Warning "Client '$Client' not found in configuration. Use Get-PstClient to see available clients."
        return
    }

    # Validate project exists for this client
    if ($clientObj.Projects -notcontains $Project) {
        Write-Warning "Project '$Project' not found for client '$Client'. Use Get-PstProject -Client '$Client' to see available projects."
        return
    }
    Clear-Host

    Write-host ('Adding {0} minutes for {1} - {2}' -f $Minutes, $Client, $Project)

    [Array]$TodaysWork = Restore-Pstday

    $Addtime = $Client | Select-Object  @{l='Client';e={$Client}},@{l='Project';e={$Project}},@{l='StartTime';e={$StartTime}}, @{l='Elapsed';e={New-TimeSpan -Minutes $Minutes}}
    $Addtime | Format-Table -AutoSize | Out-String | Write-Host  -ForegroundColor White
    $TodaysWork += $AddTime

    # backup the day so far just in case
    Backup-PstDay -TodaysWork $TodaysWork

    # Output day summary
    Get-PstDaySummary

}
