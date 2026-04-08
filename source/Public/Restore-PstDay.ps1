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

    if ($IsWindows -or $PSVersionTable.PSVersion.Major -le 5) {
        $folder = Join-Path $env:LOCALAPPDATA 'PstTimeTracker'
    } else {
        $folder = Join-Path $HOME '.local/share/PstTimeTracker'
    }

    $fileName = Join-Path $folder ('todayswork-{0}.json' -f (Get-Date($date) -Format 'yyyy-MM-dd'))

    Write-Verbose "Restoring day from file: $fileName"

    if (Test-Path $fileName) {

        Get-Content $fileName | ConvertFrom-Json | Select-Object Client, Project, StartTime, @{l='Elapsed';e={New-TimeSpan -Seconds $_.ElapsedTotalSeconds}}
    }
}
