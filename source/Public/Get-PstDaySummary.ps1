<#
.SYNOPSIS
Gets the day summary.

.DESCRIPTION
Gets the day summary.

If a date is provided it will restore the day so far from the json file in the local appdata folder and display the summary.

.PARAMETER date
If provided this will restore the specified day from the json file in the local appdata folder and display the summary.

.EXAMPLE
PS> Get-PstDaySummary

This will display the day summary for the day so far.

.EXAMPLE
PS> Get-PstDaySummary -date 2023-01-01

This will restore the json from the local appdata folder for 2023-01-01 and display the summary.

#>
function Get-PstDaySummary {
    param (
        $date
    )
    if($date) {
        $RestoredWork = Restore-PstDay -date $date

        if (-not $RestoredWork) {
            Write-Host ('No work found for {0}...' -f $date) -ForegroundColor DarkRed -BackgroundColor White
            return
        }

        [Array]$results = $RestoredWork | Group-Object Client, Project | Select-Object Name, @{l='Total';e={New-TimeSpan -Seconds (($_.Group.Elapsed.TotalSeconds | Measure-Object -sum ).sum)}}
        $results += [PSCustomObject]@{
            Name = '===Total'
            Total = New-TimeSpan -Seconds ($RestoredWork | Select-Object @{l='TotalSecs';e={$_.elapsed.TotalSeconds}} | Measure-object -Property TotalSecs -Sum).Sum
        }
        $results | Out-String | Write-Host  -ForegroundColor White

    } else {
        $TodaysWork = Restore-PstDay

        if($TodaysWork) {

            Write-Host '--------------------------' -ForegroundColor DarkGreen -BackgroundColor White
            Write-Host 'So far today:             ' -ForegroundColor DarkGreen -BackgroundColor White
            Write-Host '--------------------------' -ForegroundColor DarkGreen -BackgroundColor White

            [Array]$results = $TodaysWork | Group-Object Client, Project | Select-Object Name, @{l='Total';e={New-TimeSpan -Seconds (($_.Group.Elapsed.TotalSeconds | Measure-Object -sum ).sum)}}
            $results += [PSCustomObject]@{
                Name = '===Total'
                Total = New-TimeSpan -Seconds ($TodaysWork | Select-Object @{l='TotalSecs';e={$_.elapsed.TotalSeconds}} | Measure-object -Property TotalSecs -Sum).Sum
            }
            $results | Out-String | Write-Host  -ForegroundColor White
        } else {
            Write-Host 'Nothing recorded yet...' -ForegroundColor DarkRed -BackgroundColor White
        }
    }

}
