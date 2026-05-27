# Changelog for PsTimeTracking

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Behavior tests for all public functions (121 total)
- Open-PstConfig and Open-PstDay functions to open JSON files in an editor
- Move-PstTime function to move time between client/project buckets

### Changed

- Default config sample clients now use generic fictional names (Globex, Initech)
- Module manifest now lists functions explicitly and includes PSGallery metadata
- Removed Start-PstDay (broken no-op) and placeholder class files

### Fixed

- Backup-PstDay now only prunes `todayswork-*.json` files; previously it pruned all `*.json` files which could delete config.json after 10 days of inactivity

### Fixed

- Get-PstDaySummary and Restore-PstDay parameter names and types corrected

## [0.6.0] - 2026-05-27

### Added

- Open-PstConfig function to open the config file in VS Code or Notepad
- Open-PstDay function to open a day's time tracking file in an editor

### Fixed

- Get-PstDaySummary: `$Date` parameter now typed as `[datetime]` with corrected help text
- Restore-PstDay: `$Date` parameter now typed as `[datetime]` with corrected help text
- GitHub Actions deploy condition to support stable tag releases

## [0.5.0] - 2026-04

### Added

- Move-PstTime function to move minutes between client/project buckets
- Tab completion (ArgumentCompleter) for Client and Project parameters

### Fixed

- Config file corruption bug in Add-PstProject, Update-PstProject, Update-PstClient, Remove-PstProject
- Cross-platform config file paths (Windows uses LOCALAPPDATA, Linux/macOS uses .local/share)

### Changed

- GitHub Actions workflow updated to use actions/upload-artifact@v4 and windows-latest runner

## [0.3.0] - 2023-03-29

### Added

- Initial public release with client/project management and time tracking functions
- Add-PstClient, Remove-PstClient, Update-PstClient, Get-PstClient
- Add-PstProject, Remove-PstProject, Update-PstProject, Get-PstProject
- Start-PstTimer, Add-PstTime, Get-PstDaySummary, Backup-PstDay, Restore-PstDay
