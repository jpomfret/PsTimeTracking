# Simple test to manually load all functions and test for issues

$ErrorActionPreference = 'Stop'

Write-Host "Loading Private functions..." -ForegroundColor Cyan
. "$PSScriptRoot\source\Private\Get-PstConfig.ps1"
. "$PSScriptRoot\source\Private\Save-PstConfig.ps1"

Write-Host "Loading Public functions..." -ForegroundColor Cyan
$publicFunctions = Get-ChildItem "$PSScriptRoot\source\Public\*.ps1"
foreach ($function in $publicFunctions) {
    Write-Host "  Loading $($function.Name)" -ForegroundColor Gray
    . $function.FullName
}

Write-Host "`nTesting Get-PstClient..." -ForegroundColor Yellow
Get-PstClient | Format-Table -AutoSize

Write-Host "`n✓ All functions loaded successfully!" -ForegroundColor Green
