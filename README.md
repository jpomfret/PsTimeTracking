# PsTimeTracking

PowerShell module to make tracking time easier.

## Overview

PsTimeTracking helps you track time spent on different projects and clients. It features:
- JSON-based configuration for clients and projects
- Interactive timers to track work sessions
- Manual time entry
- Daily summaries
- Persistent storage in your local AppData folder

## Quick Start

1. Import the module
2. Start tracking time with `Start-PstTimer -Client 'ClientA' -Project 'Project Alpha'`
3. View your day summary with `Get-PstDaySummary`

## Configuration Management

The module uses a **user-specific JSON configuration file** to manage clients and their associated projects. This file is:
- **Not included in the module** - created automatically in your local AppData folder
- **Fully customizable** - edit manually or use the management functions below
- **Created on first use** with sample clients to get you started

See [config-example.json](docs/config-example.json) for the structure and [Configuration Documentation](docs/Configuration.md) for details.

### Managing Clients

```powershell
# View all clients
Get-PstClient

# View a specific client
Get-PstClient -Name 'ClientA'

# Add a new client
Add-PstClient -Name 'NewClient' -Projects @('Project 1', 'Project 2')

# Update a client name
Update-PstClient -Name 'OldName' -NewName 'NewName'

# Remove a client
Remove-PstClient -Name 'ClientName'
```

### Managing Projects

```powershell
# View projects for a client
Get-PstProject -Client 'ClientA'

# Add a project to a client
Add-PstProject -Client 'ClientA' -Project 'New Project'

# Update a project name  
Update-PstProject -Client 'ClientA' -Project 'OldName' -NewName 'NewName'

# Remove a project
Remove-PstProject -Client 'ClientA' -Project 'ProjectName'
```

### Time Tracking Functions

```powershell
# Start an interactive timer
Start-PstTimer -Client 'ClientA' -Project 'Project Alpha'

# Add time manually
Add-PstTime -Client 'ClientA' -Project 'Project Alpha' -Minutes 60

# View today's summary
Get-PstDaySummary

# View a specific date's summary
Get-PstDaySummary -Date '2023-01-15'
```

For more details, see [Configuration Documentation](docs/Configuration.md)

## Development

### Build and Test

1. Download and resolve dependencies

    ``` PowerShell
    .\build.ps1 -ResolveDependency -Tasks noop 
    ```

2. Make changes in the source directory

3. Build the module

    ``` PowerShell
    .\build.ps1 -Tasks build
    ```

4. Build and run tests

    ``` PowerShell
    .\build.ps1 -Tasks build,test
    ```

5. Run tests only

    ``` PowerShell
    invoke-pester .\tests\
    ```

## Data Storage

All data is stored per-user in your local AppData folder:

- **Configuration:** `$env:LocalAppData\PstTimeTracker\config.json`
- **Time tracking data:** `$env:LocalAppData\PstTimeTracker\todayswork-YYYY-MM-DD.json`

These files are **NOT** part of the module and are fully customizable. You can edit the config.json directly with any text editor, or use the provided management functions.

## Make it yours

1. Download and resolve dependencies

    ``` PowerShell
    .\build.ps1 -ResolveDependency -Tasks noop 
    ```

2. Make changes in the source directory
3. Build it

    ``` PowerShell
    .\build.ps1 -Tasks build

    ```

4. you can also build and run tests

    ``` PowerShell
    .\build.ps1 -Tasks build,test
    ```

5. to just run tests you can

    ``` PowerShell
    invoke-pester .\tests\
    ```
