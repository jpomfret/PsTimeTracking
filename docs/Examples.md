# PsTimeTracking - Complete Usage Examples

## Example 1: First Time Setup

```powershell
# Import the module
Import-Module PsTimeTracking

# View the default clients
Get-PstClient

# Output:
# Name           Projects
# ----           --------
# ClientA        {Project Alpha, Project Beta, Support}
# ClientB        {Website Redesign, Database Migration}
# MMG - Data     {Data Analysis, ETL Pipeline, Reporting}
# MMG - DevOps   {CI/CD Setup, Infrastructure, Monitoring}

# View projects for a specific client
Get-PstProject -Client 'ClientA'

# Output:
# Project Alpha
# Project Beta
# Support
```

## Example 2: Customizing Your Configuration

```powershell
# Add your own client
Add-PstClient -Name 'Contoso' -Projects @('Web Portal', 'API Development', 'Bug Fixes')

# Add more projects to an existing client
Add-PstProject -Client 'Contoso' -Project 'Performance Optimization'

# Update a project name
Update-PstProject -Client 'Contoso' -Project 'Web Portal' -NewName 'Customer Portal'

# View the updated client
Get-PstClient -Name 'Contoso'
Get-PstProject -Client 'Contoso'
```

## Example 3: Tracking Time with Interactive Timer

```powershell
# Start a timer for a specific client and project
Start-PstTimer -Client 'ClientA' -Project 'Project Alpha'

# The timer display will show:
# Working on ClientA - Project Alpha, since 4/7/2026 2:30:00 PM - Press any key to stop?

# When you press a key, it automatically saves and shows your day summary
```

## Example 4: Manual Time Entry

```powershell
# Add 45 minutes to a project
Add-PstTime -Client 'ClientB' -Project 'Website Redesign' -Minutes 45

# Add time with a specific start time
Add-PstTime -Client 'ClientA' -Project 'Support' -Minutes 30 -StartTime (Get-Date '2:00 PM')
```

## Example 5: Viewing Summaries

```powershell
# View today's summary
Get-PstDaySummary

# Output:
# --------------------------
# So far today:             
# --------------------------
# Name                      Total
# ----                      -----
# ClientA, Project Alpha    01:45:00
# ClientB, Website Redesign 00:45:00
# ClientA, Support          00:30:00
# ===Total                  03:00:00

# View a specific date
Get-PstDaySummary -Date '2026-04-01'
```

## Example 6: Full Day Workflow

```powershell
# Morning: Start working on first task
Start-PstTimer -Client 'MMG - Data' -Project 'ETL Pipeline'
# Work... Press key when done

# Mid-morning: Switch to another task
Start-PstTimer -Client 'MMG - DevOps' -Project 'CI/CD Setup'
# Work... Press key when done

# Add time for a meeting you forgot to track
Add-PstTime -Client 'ClientA' -Project 'Support' -Minutes 30 -StartTime (Get-Date '11:00 AM')

# Afternoon: Continue with more work
Start-PstTimer -Client 'MMG - Data' -Project 'Reporting'
# Work... Press key when done

# End of day: View your summary
Get-PstDaySummary
```

## Example 7: Manual Configuration Edit

```powershell
# Open the config file in notepad
notepad "$env:LocalAppData\PstTimeTracker\config.json"

# Or open in VS Code
code "$env:LocalAppData\PstTimeTracker\config.json"

# The config file is user-specific and fully customizable
# You can edit it directly or use the PowerShell functions
```

## Example 8: Managing Configuration via Functions

```powershell
# Remove a project you no longer work on
Remove-PstProject -Client 'ClientB' -Project 'Old Project' -Force

# Remove an entire client
Remove-PstClient -Name 'OldClient' -Force

# Rename a client to match new company name
Update-PstClient -Name 'ClientA' -NewName 'Acme Corporation'
```

## Tips

1. **Use Tab Completion**: Client and Project parameters support tab completion for easier selection

2. **Check Configuration First**: Before starting a timer, use `Get-PstClient` and `Get-PstProject` to see available options

3. **View History**: Check previous days with `Get-PstDaySummary -Date '2026-04-01'`

4. **Backup**: Your configuration and time data are automatically backed up in `$env:LocalAppData\PstTimeTracker\`

5. **Validation**: All time tracking functions validate that clients and projects exist in your configuration
