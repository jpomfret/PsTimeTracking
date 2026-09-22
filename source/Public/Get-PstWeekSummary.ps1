<#
.SYNOPSIS
Gets a summary of the week's hours as a table.

.DESCRIPTION
Gets a summary of the week's hours as a table.

Clients are listed down the left, the days of the week (Monday to Sunday) across the top,
with a total column per client and a total row per day. Each day is restored from the json
files in the local appdata folder using Restore-PstDay.

.PARAMETER Date
Any date within the week to summarise. The week is taken as Monday to Sunday containing
this date. If not provided, summarises the current week.

.PARAMETER Detailed
Breaks each client down by project, listing 'Client\Project' down the side instead of just
the client.

.EXAMPLE
PS> Get-PstWeekSummary

This will display the summary for the current week (Monday to Sunday).

.EXAMPLE
PS> Get-PstWeekSummary -Date 2023-01-04

This will display the summary for the week containing 2023-01-04.

.EXAMPLE
PS> Get-PstWeekSummary -Detailed

This will display the summary for the current week broken down by client and project.

#>
function Get-PstWeekSummary {
    param (
        [Parameter()]
        [datetime]$Date = (Get-Date).Date,

        [Parameter()]
        [switch]$Detailed
    )

    # Find the Monday of the week containing $Date (DayOfWeek: Sunday = 0 ... Saturday = 6)
    $dayOfWeek = [int]$Date.DayOfWeek
    $offset = if ($dayOfWeek -eq 0) { 6 } else { $dayOfWeek - 1 }
    $monday = $Date.Date.AddDays(-$offset)

    $days = 0..6 | ForEach-Object { $monday.AddDays($_) }
    $dayHeaders = $days | ForEach-Object { $_.ToString('ddd MM/dd') }

    # The leftmost column groups by client, or client and project when -Detailed is used
    $rowLabel = if ($Detailed) { 'Client\Project' } else { 'Client' }

    # Restore each day's work, tagging every entry with the day and its row grouping key
    $allWork = foreach ($day in $days) {
        foreach ($entry in (Restore-PstDay -Date $day)) {
            [PSCustomObject]@{
                Day     = $day
                RowKey  = if ($Detailed) { '{0}\{1}' -f $entry.Client, $entry.Project } else { $entry.Client }
                Seconds = $entry.Elapsed.TotalSeconds
            }
        }
    }

    if (-not $allWork) {
        Write-Host ('No work found for week of {0}...' -f $monday.ToString('yyyy-MM-dd')) -ForegroundColor DarkRed -BackgroundColor White
        return
    }

    # Format seconds as a compact H:mm string, blank when there is nothing recorded
    $format = {
        param($seconds)
        if ($seconds) {
            $ts = [timespan]::FromSeconds($seconds)
            '{0}:{1:D2}' -f [int][math]::Floor($ts.TotalHours), $ts.Minutes
        } else {
            ''
        }
    }

    Write-Host '------------------------------' -ForegroundColor DarkGreen -BackgroundColor White
    Write-Host ('Week of {0}:                  ' -f $monday.ToString('yyyy-MM-dd')) -ForegroundColor DarkGreen -BackgroundColor White
    Write-Host '------------------------------' -ForegroundColor DarkGreen -BackgroundColor White

    # One row per grouping key, one column per day, plus a per-row total
    $rowKeys = $allWork.RowKey | Sort-Object -Unique
    [Array]$results = foreach ($key in $rowKeys) {
        $row = [ordered]@{ $rowLabel = $key }
        $rowTotal = 0
        for ($i = 0; $i -lt 7; $i++) {
            $secs = ($allWork | Where-Object { $_.RowKey -eq $key -and $_.Day -eq $days[$i] } | Measure-Object -Property Seconds -Sum).Sum
            $rowTotal += $secs
            $row[$dayHeaders[$i]] = & $format $secs
        }
        $row['Total'] = & $format $rowTotal
        [PSCustomObject]$row
    }

    # Total row - one total per day, and a grand total for the week
    $totalRow = [ordered]@{ $rowLabel = '===Total' }
    $grandTotal = 0
    for ($i = 0; $i -lt 7; $i++) {
        $daySecs = ($allWork | Where-Object { $_.Day -eq $days[$i] } | Measure-Object -Property Seconds -Sum).Sum
        $grandTotal += $daySecs
        $totalRow[$dayHeaders[$i]] = & $format $daySecs
    }
    $totalRow['Total'] = & $format $grandTotal
    $results += [PSCustomObject]$totalRow

    $results | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
}
