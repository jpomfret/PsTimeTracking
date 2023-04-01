# format output
function Add-PstTimer {
    param (

        $Client,

        $Project,

        $Minutes,

        $StartTime
    )
    Clear-Host

    Write-host ('Adding {0} minutes for {1} - {2}' -f $Minutes, $Client, $Project)


    $Addtime = $Client | Select-Object  @{l='Client';e={$Client}},@{l='Project';e={$Project}},@{l='StartTime';e={$StartTime}}, @{l='Elapsed';e={New-TimeSpan -Minutes $Minutes}}
    $Addtime | Format-Table -AutoSize | Out-String | Write-Host  -ForegroundColor White
    $global:TodaysWork += $AddTime

    # backup the day so far just in case
    Backup-PstDay

    # Output day summary
    Get-PstDaySummary

}
