function Backup-PstDay {
    $folder = Join-Path $env:localappdata 'PstTimeTracker'

    if (!(Test-Path $folder)) {
        New-Item $folder -ItemType Directory | Out-Null
    }

    if($global:TodaysWork) {

        $fileName = Join-Path $folder ('todayswork-{0}.json' -f (Get-Date -Format 'yyyy-MM-dd'))
        $global:TodaysWork | Select Client, Project, StartTime, @{l='ElapsedTotalSeconds';e={$_.Elapsed.TotalSeconds}} | ConvertTo-Json | Out-File $fileName
    }

    # remove jsons older than 10 days
    Get-ChildItem $folder *.json | where-object lastWriteTime -lt (get-date).AddDays(-10) | Remove-Item
}
