function Start-PstTimer {
    param (
        $Client,

        $Project,

        $StartTime = (Get-Date)
    )
    Clear-Host

    $timer = New-Object System.Diagnostics.Stopwatch
    $timer.Start()

    if($global:TodaysWork) {
        # Output day summary
        Get-PstDaySummary
    }


    $null = Read-host ('Working on {0} - {1}, since {2} - Press any key to stop?' -f $Client, $Project, $StartTime)

    $timer.Stop()

    Write-Host '--------------------------' -ForegroundColor DarkMagenta -BackgroundColor White
    Write-Host 'Just worked on:           ' -ForegroundColor DarkMagenta -BackgroundColor White
    Write-Host '--------------------------' -ForegroundColor DarkMagenta -BackgroundColor White

    $Addtime = $timer | Select-Object  @{l='Client';e={$Client}},@{l='Project';e={$Project}},@{l='StartTime';e={$StartTime}},  Elapsed
    $Addtime | Format-Table -AutoSize | Out-String | Write-Host  -ForegroundColor White
    $global:TodaysWork += $AddTime

    # backup the day so far just in case
    Backup-PstDay

    # Output day summary
    Get-PstDaySummary

}
