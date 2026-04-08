# Configuration Management

This module supports centralized configuration management for clients and projects via a user-specific JSON configuration file.

## Important Notes

- **The configuration file is NOT included in the module** - it's user-specific and customizable
- **Created automatically on first use** at: `$env:LocalAppData\PstTimeTracker\config.json`
- **Fully customizable** - edit directly or use the provided management functions
- **Per-user storage** - each user has their own configuration

## Configuration File Location

The configuration file is automatically created at:
`$env:LocalAppData\PstTimeTracker\config.json`

Example path: `C:\Users\YourName\AppData\Local\PstTimeTracker\config.json`

## Default Configuration

When first run, the module creates a default configuration with sample clients and projects:
- **ClientA**: Project Alpha, Project Beta, Support
- **ClientB**: Website Redesign, Database Migration
- **MMG - Data**: Data Analysis, ETL Pipeline, Reporting
- **MMG - DevOps**: CI/CD Setup, Infrastructure, Monitoring

## Managing Clients

### View All Clients
```powershell
Get-PstClient
```

### View Specific Client
```powershell
Get-PstClient -Name 'ClientA'
```

### Add a New Client
```powershell
# Add client with projects
Add-PstClient -Name 'ClientC' -Projects @('Project 1', 'Project 2')

# Add client without projects
Add-PstClient -Name 'ClientD'
```

### Update a Client Name
```powershell
Update-PstClient -Name 'ClientA' -NewName 'Client Alpha'
```

### Remove a Client
```powershell
# With confirmation
Remove-PstClient -Name 'ClientC'

# Without confirmation
Remove-PstClient -Name 'ClientC' -Force
```

## Managing Projects

### View Projects for a Client
```powershell
Get-PstProject -Client 'ClientA'
```

### Add a Project to a Client
```powershell
Add-PstProject -Client 'ClientA' -Project 'New Project'
```

### Update a Project Name
```powershell
Update-PstProject -Client 'ClientA' -Project 'Project Alpha' -NewName 'Alpha Project v2'
```

### Remove a Project from a Client
```powershell
# With confirmation
Remove-PstProject -Client 'ClientA' -Project 'Old Project'

# Without confirmation
Remove-PstProject -Client 'ClientA' -Project 'Old Project' -Force
```

## Using Clients and Projects in Time Tracking

The existing time tracking functions now validate against the configuration:

```powershell
# Start a timer
Start-PstTimer -Client 'ClientA' -Project 'Project Alpha'

# Add time manually
Add-PstTime -Client 'ClientB' -Project 'Website Redesign' -Minutes 60
```

If you specify a client or project that doesn't exist in the configuration, you'll receive a warning message indicating the available options.

## Configuration File Format

The JSON configuration follows this structure:

```json
{
  "Clients": [
    {
      "Name": "ClientA",
      "Projects": [
        "Project Alpha",
        "Project Beta",
        "Support"
      ]
    },
    {
      "Name": "ClientB",
      "Projects": [
        "Website Redesign",
        "Database Migration"
      ]
    }
  ]
}
```

See [config-example.json](config-example.json) for a complete example.

## Manual Configuration

You can edit the configuration file directly with any text editor:

- You can edit the config.json file directly or use the PowerShell management functions - both methods work perfectly
- The configuration file is specific to each user - it won't be shared or committed to source control
1. Open the file at `$env:LocalAppData\PstTimeTracker\config.json`
2. Edit the JSON structure following the format above
3. Save and close - changes take effect immediately

**Or** use PowerShell to open it:
```powershell
notepad "$env:LocalAppData\PstTimeTracker\config.json"
# or
code "$env:LocalAppData\PstTimeTracker\config.json"  # Opens in VS Code
```

## Tips

- Use `Get-PstClient` to see all available clients before starting a timer
- Use `Get-PstProject -Client 'ClientName'` to see available projects for a specific client
- The configuration persists across sessions and is stored per user
- All management functions include proper validation and helpful error messages
