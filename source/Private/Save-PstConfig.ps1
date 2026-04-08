<#
.SYNOPSIS
Saves the PsTimeTracking configuration to the JSON file.

.DESCRIPTION
Internal function that saves the configuration object to the JSON file.

.PARAMETER Config
The configuration object to save.

.EXAMPLE
PS> Save-PstConfig -Config $config

Saves the configuration object to the JSON file.
#>
function Save-PstConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$Config
    )

    $folder = Join-Path $env:localappdata 'PstTimeTracker'
    $configFile = Join-Path $folder 'config.json'

    if (!(Test-Path $folder)) {
        New-Item $folder -ItemType Directory | Out-Null
    }

    $Config | ConvertTo-Json -Depth 10 | Out-File $configFile -Encoding UTF8
}
