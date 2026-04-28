param(
  [string]$BaseUrl = "http://localhost:3000"
)

Write-Host "Narrio Sprint 6.4 + 6.5 QA checklist" -ForegroundColor Cyan
Write-Host "Base URL: $BaseUrl" -ForegroundColor DarkCyan
Write-Host ""

$routes = @(
  "/library",
  "/launch",
  "/missing-narrio-route-check"
)

foreach ($route in $routes) {
  $url = "$BaseUrl$route"
  Write-Host "Open: $url" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Manual checks:" -ForegroundColor Cyan
Write-Host "1. /library loads and author names are clickable."
Write-Host "2. Click an author and verify /u/[userId] loads."
Write-Host "3. Public profile shows only public published stories."
Write-Host "4. Featured story Start Reading works."
Write-Host "5. Latest signal chapter works."
Write-Host "6. /launch loads the readiness checklist."
Write-Host "7. Missing route shows the branded Lost timeline page."
Write-Host "8. Mobile width does not break Library, Profile, or Launch pages."
