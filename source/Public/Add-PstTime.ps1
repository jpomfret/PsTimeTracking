<#
.SYNOPSIS
Adds a chunk of time to the day so far.

.DESCRIPTION
Adds a chunk of time to the day so far.

.PARAMETER Client
The client to add time to.

.PARAMETER Project
The project to add time to.

.PARAMETER Minutes
The number of minutes to add.

.PARAMETER StartTime
If provided this will be added to the day summary.

.EXAMPLE
PS> Add-PstTime -Client ClientA -Project BigProject -Minutes 60

Adds 60 mins to the day so far for ClientA - BigProject.

#>

function Add-PstTime {
    param (

        $Client,

        $Project,

        $Minutes,

        $StartTime
    )
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
