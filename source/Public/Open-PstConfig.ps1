<#
.SYNOPSIS
Opens the PsTimeTracking configuration file in an editor.

.DESCRIPTION
Opens the config.json configuration file in the specified editor (VSCode or Notepad).
Defaults to VSCode if no editor is specified.

.PARAMETER Editor
The editor to open the file in. Valid values are 'VSCode' and 'Notepad'. Defaults to 'VSCode'.

.EXAMPLE
PS> Open-PstConfig

Opens the configuration file in VSCode.

.EXAMPLE
PS> Open-PstConfig -Editor Notepad

Opens the configuration file in Notepad.

#>
function Open-PstConfig {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet('VSCode', 'Notepad')]
        [string]$Editor = 'VSCode'
    )

    if ($IsWindows -or $PSVersionTable.PSVersion.Major -le 5) {
        $folder = Join-Path $env:LOCALAPPDATA 'PstTimeTracker'
    } else {
        $folder = Join-Path $HOME '.local/share/PstTimeTracker'
    }

    $configFile = Join-Path $folder 'config.json'

    if (!(Test-Path $configFile)) {
        Write-Warning "Config file not found at '$configFile'. Run Get-PstConfig to create it."
        return
    }

    switch ($Editor) {
        'VSCode'  { code $configFile }
        'Notepad' { notepad $configFile }
    }
}
