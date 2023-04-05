<#
.SYNOPSIS
Restores the day so far from the json file in the local appdata folder.

.DESCRIPTION
Restores the day so far from the json file in the local appdata folder.

This is used to restore the day so far if the script is closed.

.PARAMETER date
If provided this will restore the specified day from the json file in the local appdata folder.

.EXAMPLE
PS> Restore-PstDay

This will restore the day so far from the json file in the local appdata folder.

.EXAMPLE
PS> Restore-PstDay -date 2023-01-01

This will restore the json from the local appdata folder for 2023-01-01.

#>
function Restore-PstDay {
    param (
        $date = (Get-Date).Date
    )

    $folder = Join-Path $env:localappdata 'PstTimeTracker'

    $fileName = Join-Path $folder ('todayswork-{0}.json' -f (Get-Date($date) -Format 'yyyy-MM-dd'))

    if (Test-Path $fileName) {

        Get-Content $fileName | ConvertFrom-Json | Select-Object Client, Project, StartTime, @{l='Elapsed';e={New-TimeSpan -Seconds $_.ElapsedTotalSeconds}}
    }
}
