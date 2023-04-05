<#
.SYNOPSIS
Starts a timer for a client and project.

.DESCRIPTION
Starts a timer for a client and project.

.PARAMETER Client
Client to track time against.

.PARAMETER Project
Project to track time against.

.EXAMPLE
PS> Start-PstTimer -Client ClientA -Project BigProject

This will start a timer for ClientA - BigProject.

#>
function Start-PstTimer {
    param (
        $Client,

        $Project
    )
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
