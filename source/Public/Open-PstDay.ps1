<#
.SYNOPSIS
Opens a day's time tracking file in an editor.

.DESCRIPTION
Opens the time tracking JSON file for the specified date in the chosen editor.
Defaults to today's file and VSCode if no parameters are specified.

.PARAMETER Date
The date of the time tracking file to open. Defaults to today.

.PARAMETER Editor
The editor to open the file in. Valid values are 'VSCode' and 'Notepad'. Defaults to 'VSCode'.

.EXAMPLE
PS> Open-PstDay

Opens today's time tracking file in VSCode.

.EXAMPLE
PS> Open-PstDay -Date 2025-05-20

Opens the time tracking file for 2025-05-20 in VSCode.

.EXAMPLE
PS> Open-PstDay -Editor Notepad

Opens today's time tracking file in Notepad.

#>
function Open-PstDay {
    [CmdletBinding()]
    param (
        [Parameter()]
        [datetime]$Date = (Get-Date).Date,

        [Parameter()]
        [ValidateSet('VSCode', 'Notepad')]
        [string]$Editor = 'VSCode'
    )

    if ($IsWindows -or $PSVersionTable.PSVersion.Major -le 5) {
        $folder = Join-Path $env:LOCALAPPDATA 'PstTimeTracker'
    } else {
        $folder = Join-Path $HOME '.local/share/PstTimeTracker'
    }

    $fileName = Join-Path $folder ('todayswork-{0}.json' -f (Get-Date $Date -Format 'yyyy-MM-dd'))

    if (!(Test-Path $fileName)) {
        Write-Warning "No time tracking file found for $(Get-Date $Date -Format 'yyyy-MM-dd')."
        return
    }

    switch ($Editor) {
        'VSCode'  { Start-Process -FilePath 'code' -ArgumentList $fileName }
        'Notepad' { Start-Process -FilePath 'notepad' -ArgumentList $fileName }
    }
}
