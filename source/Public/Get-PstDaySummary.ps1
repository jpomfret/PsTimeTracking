function Get-PstDaySummary {
    param (
        $date
    )

    if($date) {
        $RestoredWork = Restore-PstDay -date $date

        [Array]$results = $RestoredWork | Group-Object Client, Project | Select-Object Name, @{l='Total';e={New-TimeSpan -Seconds (($_.Group.Elapsed.TotalSeconds | Measure-Object -sum ).sum)}}
        $results += [PSCustomObject]@{
            Name = '===Total'
            Total = New-TimeSpan -Seconds ($RestoredWork | Select @{l='TotalSecs';e={$_.elapsed.TotalSeconds}} | Measure-object -Property TotalSecs -Sum).Sum
        }
        $results | Out-String | Write-Host  -ForegroundColor White

    } elseif($global:TodaysWork) {


        Write-Host '--------------------------' -ForegroundColor DarkGreen -BackgroundColor White
        Write-Host 'So far today:             ' -ForegroundColor DarkGreen -BackgroundColor White
        Write-Host '--------------------------' -ForegroundColor DarkGreen -BackgroundColor White

        [Array]$results = $global:TodaysWork | Group-Object Client, Project | Select-Object Name, @{l='Total';e={New-TimeSpan -Seconds (($_.Group.Elapsed.TotalSeconds | Measure-Object -sum ).sum)}}
        $results += [PSCustomObject]@{
            Name = '===Total'
            Total = New-TimeSpan -Seconds ($global:TodaysWork | Select @{l='TotalSecs';e={$_.elapsed.TotalSeconds}} | Measure-object -Property TotalSecs -Sum).Sum
        }
        $results | Out-String | Write-Host  -ForegroundColor White

    } else {
        Write-Host 'Nothing recorded yet...' -ForegroundColor DarkRed -BackgroundColor White
    }
}
