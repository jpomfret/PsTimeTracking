# PsTimeTracking

PowerShell module to make tracking time easier.

## Overview

PsTimeTracking helps you track time spent on different projects and clients. It features:
- JSON-based configuration for clients and projects
- Interactive timers to track work sessions
- Manual time entry and time correction
- Daily summaries for today or any past date
- Persistent local storage — no data leaves your machine

## Installation

```powershell
Install-Module -Name PsTimeTracking
```

## Quick Start

```powershell
# 1. View your clients (sample config created automatically on first use)
Get-PstClient

# 2. Start tracking time
Start-PstTimer -Client 'ClientA' -Project 'Project Alpha'

# 3. View your day summary
Get-PstDaySummary
```

## Configuration Management

The module uses a **user-specific JSON configuration file** to manage clients and their associated projects. This file is:
- **Not included in the module** - created automatically in your local AppData folder
- **Fully customizable** - edit manually via `Open-PstConfig` or use the management functions

### Managing Clients

```powershell
Get-PstClient                                                    # list all clients
Add-PstClient -Name 'Acme' -Projects @('Project 1', 'Project 2')
Update-PstClient -Name 'Acme' -NewName 'Acme Corp'
Remove-PstClient -Name 'Acme Corp'
```

### Managing Projects

```powershell
Get-PstProject -Client 'Acme'                                    # list projects for a client
Add-PstProject -Client 'Acme' -Project 'New Project'
Update-PstProject -Client 'Acme' -Project 'Old Name' -NewName 'New Name'
Remove-PstProject -Client 'Acme' -Project 'Old Name'
```

### Time Tracking

```powershell
Start-PstTimer -Client 'Acme' -Project 'Website'                 # interactive stopwatch
Add-PstTime -Client 'Acme' -Project 'Website' -Minutes 60        # manual entry
Move-PstTime -FromClient 'Acme' -FromProject 'Website' -ToClient 'Globex' -ToProject 'API' -Minutes 30
Get-PstDaySummary                                                # today's summary
Get-PstDaySummary -Date '2025-12-01'                             # past day
```

### Opening Files

```powershell
Open-PstConfig                                                   # open config.json in VS Code
Open-PstDay                                                      # open today's JSON in VS Code
Open-PstDay -Date '2025-12-01' -Editor Notepad
```

For full examples, see [docs/Examples.md](docs/Examples.md).

## Data Storage

All data is stored per-user locally:

| Platform | Path |
|---|---|
| Windows | `$env:LocalAppData\PstTimeTracker\` |
| Linux / macOS | `$HOME/.local/share/PstTimeTracker/` |

- `config.json` — your clients and projects list
- `todayswork-YYYY-MM-DD.json` — daily time entries, pruned after 10 days

## Development

```powershell
.\build.ps1 -ResolveDependency -Tasks noop    # first-time setup
.\build.ps1 -Tasks build                      # build module
.\build.ps1 -Tasks build,test                 # build + run tests
Invoke-Pester .\tests\                        # run tests after building
```
