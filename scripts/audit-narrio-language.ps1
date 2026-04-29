param(
  [string]$RepoRoot = ".",
  [string]$OutputPath = "narrio-language-audit-report.txt"
)

$ErrorActionPreference = "Stop"

$resolvedRoot = Resolve-Path -Path $RepoRoot
$rootPath = $resolvedRoot.Path

# Keep paths as simple child strings first.
# This avoids PowerShell treating comma-separated Join-Path calls as array input to -ChildPath.
$candidateRootChildren = @(
  "apps\web\app",
  "apps\marketing\app",
  "packages\config\src",
  "packages\ui\src"
)

$scanRoots = @()
foreach ($childPath in $candidateRootChildren) {
  $candidatePath = Join-Path -Path $rootPath -ChildPath $childPath
  if (Test-Path -Path $candidatePath) {
    $scanRoots += $candidatePath
  }
}

$rules = @(
  @{ Severity="ERROR";   Find="storyies";                Prefer="universes / stories"; Note="Typo. Never valid." },
  @{ Severity="WARN";    Find="Story page";              Prefer="Universe page";       Note="Reader-facing route copy should use Narrio product language." },
  @{ Severity="WARN";    Find="public stories";          Prefer="public universes";    Note="Discovery page should position published works as universes." },
  @{ Severity="WARN";    Find="Publish Control Center";  Prefer="Release Center";      Note="Writer-facing publishing language should feel productized." },
  @{ Severity="WARN";    Find="Reader preview";          Prefer="Reader view";         Note="Avoid internal preview phrasing on public-facing actions." },
  @{ Severity="WARN";    Find="ForkCraft";               Prefer="Forkcraft";           Note="Use locked casing unless used in old docs only." },
  @{ Severity="REVIEW";  Find="branch";                  Prefer="timeline / path";     Note="May be valid in code variables. Review only if visible UI copy." },
  @{ Severity="REVIEW";  Find="version";                 Prefer="snapshot";            Note="May be valid in technical UI. Review only if visible UI copy." },
  @{ Severity="REVIEW";  Find="published chapters";      Prefer="released chapters";   Note="Writer UI can use release language." },
  @{ Severity="REVIEW";  Find="Forking enabled";         Prefer="Forkcraft open";      Note="Use product language for permission state." },
  @{ Severity="REVIEW";  Find="Forking disabled";        Prefer="Closed canon";        Note="Use product language for permission state." }
)

$extensions = @("*.tsx", "*.ts", "*.css", "*.md")

$files = @()
foreach ($scanRoot in $scanRoots) {
  foreach ($ext in $extensions) {
    $files += Get-ChildItem -Path $scanRoot -Filter $ext -Recurse -File -ErrorAction SilentlyContinue
  }
}

$report = New-Object System.Collections.Generic.List[string]
$report.Add("Narrio Language Audit Report")
$report.Add(("RepoRoot: {0}" -f $rootPath))
$report.Add(("Generated: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")))
$report.Add("")
$report.Add("This script is read-only. It does not modify your local files.")
$report.Add("")
$report.Add("Scanned roots:")
foreach ($scanRoot in $scanRoots) {
  $report.Add(("  - {0}" -f $scanRoot))
}
$report.Add("")

$total = 0

foreach ($file in $files) {
  try {
    $relative = Resolve-Path -Path $file.FullName -Relative
  } catch {
    $relative = $file.FullName.Replace($rootPath, "").TrimStart("\")
  }

  $lines = Get-Content -Path $file.FullName -ErrorAction SilentlyContinue

  for ($i = 0; $i -lt $lines.Count; $i++) {
    foreach ($rule in $rules) {
      if ($lines[$i] -like ("*" + $rule.Find + "*")) {
        $total++
        $report.Add(("[{0}] {1}:{2}" -f $rule.Severity, $relative, ($i + 1)))
        $report.Add(("  Found : {0}" -f $rule.Find))
        $report.Add(("  Prefer: {0}" -f $rule.Prefer))
        $report.Add(("  Note  : {0}" -f $rule.Note))
        $report.Add(("  Line  : {0}" -f $lines[$i].Trim()))
        $report.Add("")
      }
    }
  }
}

$report.Add(("Total findings: {0}" -f $total))

$finalOutputPath = Join-Path -Path $rootPath -ChildPath $OutputPath
$report | Set-Content -Path $finalOutputPath -Encoding UTF8

Write-Host "Narrio language audit complete."
Write-Host ("Report written to: {0}" -f $finalOutputPath)
Write-Host ("Total findings: {0}" -f $total)
