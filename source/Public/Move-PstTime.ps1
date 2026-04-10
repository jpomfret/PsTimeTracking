<#
.SYNOPSIS
Moves time from one client/project bucket to another.

.DESCRIPTION
Moves a specified number of minutes from one client/project to another client/project.
This is useful when you realize time was tracked to the wrong bucket.

.PARAMETER FromClient
The client to move time from. Must be a client configured in the system.

.PARAMETER FromProject
The project to move time from. Must be a project associated with the FromClient.

.PARAMETER ToClient
The client to move time to. Must be a client configured in the system.

.PARAMETER ToProject
The project to move time to. Must be a project associated with the ToClient.

.PARAMETER Minutes
The number of minutes to move from the source to the destination.

.EXAMPLE
PS> Move-PstTime -FromClient 'ClientA' -FromProject 'Project Alpha' -ToClient 'ClientB' -ToProject 'Project Beta' -Minutes 20

Moves 20 minutes from ClientA - Project Alpha to ClientB - Project Beta.

#>

function Move-PstTime {
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
        [string]$FromClient,

        [Parameter(Mandatory)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            $clientName = $fakeBoundParameters['FromClient']
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
        [string]$FromProject,

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
        [string]$ToClient,

        [Parameter(Mandatory)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            $clientName = $fakeBoundParameters['ToClient']
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
        [string]$ToProject,

        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Minutes
    )

    # Validate clients and projects exist
    $config = Get-PstConfig

    $fromClientObj = $config.Clients | Where-Object { $_.Name -eq $FromClient }
    if (!$fromClientObj) {
        Write-Warning "Source client '$FromClient' not found in configuration. Use Get-PstClient to see available clients."
        return
    }

    if ($fromClientObj.Projects -notcontains $FromProject) {
        Write-Warning "Source project '$FromProject' not found for client '$FromClient'. Use Get-PstProject -Client '$FromClient' to see available projects."
        return
    }

    $toClientObj = $config.Clients | Where-Object { $_.Name -eq $ToClient }
    if (!$toClientObj) {
        Write-Warning "Destination client '$ToClient' not found in configuration. Use Get-PstClient to see available clients."
        return
    }

    if ($toClientObj.Projects -notcontains $ToProject) {
        Write-Warning "Destination project '$ToProject' not found for client '$ToClient'. Use Get-PstProject -Client '$ToClient' to see available projects."
        return
    }

    # Load today's work
    [Array]$TodaysWork = Restore-PstDay

    if (!$TodaysWork) {
        Write-Warning "No work found for today. Nothing to move."
        return
    }

    # Calculate total minutes available for the source client/project
    $sourceEntries = $TodaysWork | Where-Object { $_.Client -eq $FromClient -and $_.Project -eq $FromProject }
    if (!$sourceEntries) {
        Write-Warning "No time found for $FromClient - $FromProject. Nothing to move."
        return
    }

    $totalSourceMinutes = ($sourceEntries | Measure-Object -Property { $_.Elapsed.TotalMinutes } -Sum).Sum
    if ($totalSourceMinutes -lt $Minutes) {
        Write-Warning ("Insufficient time in source bucket. Available: {0:F0} minutes, Requested: {1} minutes" -f $totalSourceMinutes, $Minutes)
        return
    }

    Clear-Host

    Write-Host ('Moving {0} minutes from {1} - {2} to {3} - {4}' -f $Minutes, $FromClient, $FromProject, $ToClient, $ToProject) -ForegroundColor Cyan

    # Remove the minutes from the source
    $minutesToRemove = $Minutes
    $updatedWork = @()

    foreach ($entry in $TodaysWork) {
        if ($entry.Client -eq $FromClient -and $entry.Project -eq $FromProject -and $minutesToRemove -gt 0) {
            $entryMinutes = $entry.Elapsed.TotalMinutes

            if ($entryMinutes -le $minutesToRemove) {
                # Remove entire entry
                $minutesToRemove -= $entryMinutes
                Write-Verbose "Removing entire entry of $entryMinutes minutes"
                # Don't add to updatedWork
            } else {
                # Reduce entry time
                $newMinutes = $entryMinutes - $minutesToRemove
                Write-Verbose "Reducing entry from $entryMinutes to $newMinutes minutes"
                $updatedEntry = $entry | Select-Object Client, Project, StartTime, @{l='Elapsed'; e={New-TimeSpan -Minutes $newMinutes}}
                $updatedWork += $updatedEntry
                $minutesToRemove = 0
            }
        } else {
            $updatedWork += $entry
        }
    }

    # Add the time to the destination
    $addTime = [PSCustomObject]@{
        Client = $ToClient
        Project = $ToProject
        StartTime = $null
        Elapsed = New-TimeSpan -Minutes $Minutes
    }
    $updatedWork += $addTime

    # Backup the updated work
    Backup-PstDay -TodaysWork $updatedWork

    # Display summary
    Write-Host "`nTime moved successfully!" -ForegroundColor Green
    Get-PstDaySummary
}
