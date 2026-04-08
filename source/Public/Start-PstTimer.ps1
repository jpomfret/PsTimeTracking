<#
.SYNOPSIS
Starts a timer for a client and project.

.DESCRIPTION
Starts a timer for a client and project. The client and project must be configured in the system.

.PARAMETER Client
Client to track time against. Must be a client configured in the system.

.PARAMETER Project
Project to track time against. Must be a project associated with the client.

.EXAMPLE
PS> Start-PstTimer -Client ClientA -Project 'Project Alpha'

This will start a timer for ClientA - Project Alpha.

#>
function Start-PstTimer {
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
        [string]$Project
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

    $startTime = (Get-Date)

    $timer = New-Object System.Diagnostics.Stopwatch
    $timer.Start()

    [Array]$TodaysWork = Restore-PstDay

    if($TodaysWork) {
        # Output day summary
        Get-PstDaySummary
    }

    $null = Read-host ('Working on {0} - {1}, since {2} - Press any key to stop?' -f $Client, $Project, $startTime)

    $timer.Stop()

    Write-Host '--------------------------' -ForegroundColor DarkMagenta -BackgroundColor White
    Write-Host 'Just worked on:           ' -ForegroundColor DarkMagenta -BackgroundColor White
    Write-Host '--------------------------' -ForegroundColor DarkMagenta -BackgroundColor White

    $Addtime = $timer | Select-Object  @{l='Client';e={$Client}},@{l='Project';e={$Project}},@{l='StartTime';e={$startTime}},  Elapsed
    $Addtime | Format-Table -AutoSize | Out-String | Write-Host  -ForegroundColor White
    $TodaysWork += $AddTime

    # backup the day so far just in case
    Backup-PstDay -TodaysWork $TodaysWork

    # Output day summary
    Get-PstDaySummary

}
