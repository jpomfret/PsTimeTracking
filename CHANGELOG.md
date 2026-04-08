# Changelog for PsTimeTracking

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- Initial add of functions

### Added

- Added tab completion (ArgumentCompleter) for Client and Project parameters across all relevant functions
- Added debug message to Get-PstConfig to show configuration file location

### Changed

- Updated GitHub Actions workflow to use actions/upload-artifact@v4 and actions/download-artifact@v4 (from deprecated v3)

### Deprecated

- For soon-to-be removed features.

### Removed

- For now removed features.

### Fixed

- Fixed cross-platform compatibility for config file paths (Windows uses LOCALAPPDATA, Linux/macOS uses .local/share)

### Security

- In case of vulnerabilities.
