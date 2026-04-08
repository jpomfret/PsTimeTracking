<#
.SYNOPSIS
Gets the PsTimeTracking configuration from the JSON file.

.DESCRIPTION
Internal function that loads the configuration file containing clients and projects.
If the file doesn't exist, it creates a default configuration.

.EXAMPLE
PS> Get-PstConfig

Returns the configuration object with all clients and projects.
#>
function Get-PstConfig {
    [CmdletBinding()]
    param()

    # Cross-platform config folder location
    if ($IsWindows -or $PSVersionTable.PSVersion.Major -le 5) {
        $folder = Join-Path $env:LOCALAPPDATA 'PstTimeTracker'
    }
    else {
        # Linux/macOS
        $folder = Join-Path $HOME '.local/share/PstTimeTracker'
    }
    
    $configFile = Join-Path $folder 'config.json'

    Write-Debug "Config file location: $configFile"

    if (!(Test-Path $folder)) {
        New-Item $folder -ItemType Directory | Out-Null
    }

    if (!(Test-Path $configFile)) {
        # Create default configuration
        $defaultConfig = @{
            Clients = @(
                @{
                    Name = 'ClientA'
                    Projects = @('Project Alpha', 'Project Beta', 'Support')
                },
                @{
                    Name = 'ClientB'
                    Projects = @('Website Redesign', 'Database Migration')
                },
                @{
                    Name = 'MMG - Data'
                    Projects = @('Data Analysis', 'ETL Pipeline', 'Reporting')
                },
                @{
                    Name = 'MMG - DevOps'
                    Projects = @('CI/CD Setup', 'Infrastructure', 'Monitoring')
                }
            )
        }

        $defaultConfig | ConvertTo-Json -Depth 10 | Out-File $configFile -Encoding UTF8
    }

    $config = Get-Content $configFile -Raw | ConvertFrom-Json
    return $config
}
