function Restore-PstDay {
    param (
        $date = (Get-Date).Date
    )

    $folder = Join-Path $env:localappdata 'PstTimeTracker'

    $fileName = Join-Path $folder ('todayswork-{0}.json' -f (Get-Date($date) -Format 'yyyy-MM-dd'))

    if (Test-Path $fileName) {
        Write-Warning 'Restoring todays work from backup'

        # If date is today, restore to global variable
        if ($date -eq (Get-Date).Date) {
            $global:TodaysWork = Get-Content $fileName | ConvertFrom-Json | Select Client, Project, StartTime, @{l='Elapsed';e={New-TimeSpan -Seconds $_.ElapsedTotalSeconds}}
        } else {
            Get-Content $fileName | ConvertFrom-Json | Select Client, Project, StartTime, @{l='Elapsed';e={New-TimeSpan -Seconds $_.ElapsedTotalSeconds}}
        }
    }
}
