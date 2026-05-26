# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Behavioral Guidelines

### Think Before Coding

Before implementing, state assumptions explicitly. If multiple interpretations exist, present them — don't pick silently. If something is unclear, stop and ask rather than guessing.

### Simplicity First

Minimum code that solves the problem. No features beyond what was asked, no abstractions for single-use code, no "flexibility" that wasn't requested. If you write 200 lines and it could be 50, rewrite it.

### Surgical Changes

Touch only what you must. Don't improve adjacent code, comments, or formatting. Match existing style. If you notice unrelated dead code, mention it — don't delete it. Every changed line should trace directly to the request.

When your changes create orphans (unused imports, variables, functions), clean those up. Don't remove pre-existing dead code unless asked.

### Goal-Driven Execution

For multi-step tasks, state a brief plan with verifiable steps before starting:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
```

Transform tasks into verifiable goals — "fix the bug" → "write a test that reproduces it, then make it pass."

## Build and Test Commands

First-time setup (download and resolve dependencies):
```powershell
.\build.ps1 -ResolveDependency -Tasks noop
```

Build the module:
```powershell
.\build.ps1 -Tasks build
```

Build and run all tests:
```powershell
.\build.ps1 -Tasks build,test
```

Run tests directly (after building):
```powershell
Invoke-Pester .\tests\
```

Run a single test file:
```powershell
Invoke-Pester .\tests\Unit\Public\Get-PstClient.tests.ps1
```

## Architecture

This is a PowerShell module built with the [Sampler](https://github.com/gaelcolas/Sampler) framework. Source lives in `source/`; the build system (InvokeBuild + ModuleBuilder) compiles it into `output/module/PsTimeTracking/`.

**Build pipeline:** `build.ps1` → InvokeBuild tasks → ModuleBuilder merges `source/Classes/*.ps1`, `source/Private/*.ps1`, and `source/Public/*.ps1` into a single `.psm1`.

**Class loading order matters:** Files in `source/Classes/` are numbered (`1.class1.ps1`, `2.class2.ps1`, etc.) because PowerShell requires parent classes to be defined before child classes. These are currently scaffold placeholders.

### Config management pattern

All config-modifying functions (`Add-PstProject`, `Remove-PstProject`, `Update-PstProject`, `Add-PstClient`, `Remove-PstClient`, `Update-PstClient`) follow the same pattern to avoid known PowerShell bugs with JSON deserialization:

1. Call `Get-PstConfig` to load current config
2. Build a completely new config object (do not mutate the existing one — `ConvertFrom-Json` returns `PSCustomObject` with fixed-size arrays that silently drop items on mutation)
3. Use `[System.Collections.ArrayList]` for intermediate manipulation, then call `.ToArray()` to ensure arrays stay as arrays even with a single element
4. Call `Save-PstConfig -Config $newConfig`

Single-element arrays from JSON deserialization unwrap to scalars unless you force `@(...)` or `.ToArray()`. Always use `@($clientEntry.Projects)` or `.ToArray()` when rebuilding config objects.

### Time tracking data flow

- `Start-PstTimer` / `Add-PstTime`: start a session or add minutes → call `Backup-PstDay` → call `Get-PstDaySummary`
- `Backup-PstDay`: serializes `$TodaysWork` array to `todayswork-YYYY-MM-DD.json`; also prunes JSON files older than 10 days
- `Restore-PstDay`: deserializes the JSON back, reconstructing `Elapsed` as a `TimeSpan` from stored `ElapsedTotalSeconds`
- `Get-PstDaySummary`: groups entries by `Client, Project` and sums elapsed seconds

### Data storage locations

- **Windows:** `$env:LOCALAPPDATA\PstTimeTracker\`
- **Linux/macOS:** `$HOME/.local/share/PstTimeTracker/`
- `config.json` — clients and projects list
- `todayswork-YYYY-MM-DD.json` — daily time entries

### Tab completion

`-Client` and `-Project` parameters on all time-tracking functions use `[ArgumentCompleter]` scriptblocks that read `config.json` directly (not via `Get-PstConfig`) because argument completers run outside the module scope.

### Tests

Unit tests in `tests/Unit/Public/` mock `Get-PstConfig` and `Save-PstConfig` using `-ModuleName 'PsTimeTracking'` to test within the module scope. Tests capture the config passed to `Save-PstConfig` in `$script:capturedConfig` and assert array types explicitly — this guards against the single-element unwrapping bug.

QA tests in `tests/QA/module.tests.ps1` verify module import/removal, changelog presence, and per-function help quality (`.SYNOPSIS`, `.DESCRIPTION` > 40 chars, at least one `.EXAMPLE`).

## Versioning and Publishing

Every push to `main` builds, tests, and publishes a new pre-release to PSGallery. Version numbers are computed automatically by GitVersion from commit messages:

| Commit message contains | Version bump example |
|---|---|
| `fix` or `patch` | `0.6.0` → `0.6.1-preview.N` |
| `add`, `feature`, or `minor` | `0.6.0` → `0.7.0-preview.N` |
| `breaking`, `breaking change`, or `major` | `0.6.0` → `1.0.0-preview.N` |
| `+semver: none` or `+semver: skip` | no bump |

**To cut a stable release (e.g. `1.0.0`):**
1. Ensure the desired version is already being computed as `1.0.0-preview.N` on main (i.e. a major-bump commit has already been pushed and published as a preview).
2. Tag the commit you want to ship: `git tag v1.0.0 && git push origin v1.0.0`
3. The tag push triggers the workflow; GitVersion sees the tag and outputs `1.0.0` (no pre-release suffix), and the deploy step publishes it to PSGallery.

Non-preview tag pushes deploy via the condition `startsWith(github.ref, 'refs/tags/') && !contains(github.ref, 'preview')` in the workflow. Tag pushes matching `*preview*` are excluded — those are handled by the regular main branch flow.
