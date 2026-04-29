param(
  [string]$RepoRoot = (Get-Location).Path,
  [string]$DbUrl = "postgresql://postgres:postgres@127.0.0.1:54322/postgres"
)

$ErrorActionPreference = "Stop"
$SeedFile = Join-Path $RepoRoot "supabase\seed_forkcraft_demo.sql"

if (!(Test-Path $SeedFile)) {
  throw "Seed file not found: $SeedFile"
}

Write-Host "Narrio ForkCraft demo seed - hotfix 2" -ForegroundColor Cyan
Write-Host "RepoRoot: $RepoRoot"
Write-Host "SeedFile: $SeedFile"
Write-Host "DbUrl:    $DbUrl"
Write-Host ""
Write-Host "This version avoids temporary tables so it is safer in Supabase Studio and psql." -ForegroundColor Yellow
Write-Host "It will insert demo auth users, profiles, 12 stories, and 112 timeline/universe branches." -ForegroundColor Yellow
Write-Host "Default password for all demo users: test123" -ForegroundColor Yellow
Write-Host ""

$psql = Get-Command psql -ErrorAction SilentlyContinue
if ($null -eq $psql) {
  Write-Host "psql was not found in PATH." -ForegroundColor Red
  Write-Host "Open Supabase Studio SQL Editor instead and paste/run the full file:" -ForegroundColor Yellow
  Write-Host $SeedFile
  exit 1
}

psql $DbUrl -v ON_ERROR_STOP=1 -f $SeedFile
Write-Host "Done. Open Narrio and test /library, story pages, timelines, writer profiles, and activity." -ForegroundColor Green
