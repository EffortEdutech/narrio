param(
  [string]$RepoRoot = "."
)

$ErrorActionPreference = "Stop"

function Step($Name) {
  Write-Host ""
  Write-Host "==== $Name ====" -ForegroundColor Cyan
}

if (!(Test-Path $RepoRoot)) {
  throw "RepoRoot not found: $RepoRoot"
}

Set-Location $RepoRoot

Step "Sprint 6.0 QA Environment"
Write-Host "Repo: $(Get-Location)"
Write-Host "Node: $(node -v)"
Write-Host "pnpm: $(pnpm -v)"

Step "Git status"
git status --short

Step "Install dependencies"
pnpm install

Step "Typecheck"
pnpm typecheck

Step "Build"
pnpm build

Step "Done"
Write-Host "Command QA passed. Now run manual route QA from docs/sprint-6.0-manual-qa-matrix.md" -ForegroundColor Green
