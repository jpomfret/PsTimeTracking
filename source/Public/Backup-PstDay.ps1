<#
.SYNOPSIS
Backups the day so far to a json file in the local appdata folder.

.DESCRIPTION
backups the day so far to a json file in the local appdata folder.

This is used to restore the day so far if the script is closed.

.PARAMETER TodaysWork
The day so far to backup.

.EXAMPLE
PS> Backup-PstDay -TodaysWork $TodaysWork

Backups the day so far to a json file in the local appdata folder.

#>
function Backup-PstDay {
    param (
        [parameter(ValueFromPipeline=$true, Mandatory)]
        $TodaysWork
    )
    if ($IsWindows -or $PSVersionTable.PSVersion.Major -le 5) {
        $folder = Join-Path $env:LOCALAPPDATA 'PstTimeTracker'
    } else {
        $folder = Join-Path $HOME '.local/share/PstTimeTracker'
    }

    if (!(Test-Path $folder)) {
        New-Item $folder -ItemType Directory | Out-Null
    }

    if($TodaysWork) {

        $fileName = Join-Path $folder ('todayswork-{0}.json' -f (Get-Date -Format 'yyyy-MM-dd'))
        $TodaysWork | Select-Object Client, Project, StartTime, @{l='ElapsedTotalSeconds';e={$_.Elapsed.TotalSeconds}} | ConvertTo-Json | Out-File $fileName
    }

    # remove daily backup files older than 10 days (config.json is excluded by the filter)
    Get-ChildItem $folder 'todayswork-*.json' | Where-Object lastWriteTime -lt (Get-Date).AddDays(-10) | Remove-Item
}
