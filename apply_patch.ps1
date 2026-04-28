param(
  [Parameter(Mandatory=$true)]
  [string]$RepoRoot
)

$ErrorActionPreference = "Stop"

$PatchRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$FilesRoot = Join-Path $PatchRoot "files"

if (!(Test-Path $RepoRoot)) {
  throw "RepoRoot not found: $RepoRoot"
}

if (!(Test-Path $FilesRoot)) {
  throw "Patch files folder not found: $FilesRoot"
}

Write-Host "Applying Narrio Sprint 5.1 Timeline Explorer patch..." -ForegroundColor Cyan
Write-Host "RepoRoot: $RepoRoot"

Get-ChildItem -Path $FilesRoot -Recurse -File | ForEach-Object {
  $relative = $_.FullName.Substring($FilesRoot.Length).TrimStart('\', '/')
  $destination = Join-Path $RepoRoot $relative
  $destinationDir = Split-Path -Parent $destination

  if (!(Test-Path $destinationDir)) {
    New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
  }

  Copy-Item -Path $_.FullName -Destination $destination -Force
  Write-Host "  patched $relative"
}

Write-Host "Done. Now run: pnpm typecheck && pnpm build" -ForegroundColor Green
