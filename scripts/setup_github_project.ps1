# Creates org Project "MVP Roadmap" and adds all rpglearn issues.
# Prerequisite: gh auth refresh -s project,read:project
# Usage: .\scripts\setup_github_project.ps1

param(
    [string]$Org = "rpglearndev",
    [string]$Repo = "rpglearn"
)

$ErrorActionPreference = "Stop"
$fullRepo = "$Org/$Repo"
$baseUrl = "https://github.com/$fullRepo/issues"

Write-Host "Checking gh project scope..."
$null = gh project list --owner $Org --limit 1 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Token sin scope 'project'. Ejecuta primero:" -ForegroundColor Yellow
    Write-Host "  gh auth refresh -s project,read:project" -ForegroundColor Cyan
    Write-Host "  (acepta en el navegador y vuelve a lanzar este script)" -ForegroundColor Yellow
    exit 1
}

$existing = gh project list --owner $Org --format json | ConvertFrom-Json
$found = $existing.projects | Where-Object { $_.title -eq "MVP Roadmap" } | Select-Object -First 1
if ($found) {
    $projectNumber = $found.number
    Write-Host "Project 'MVP Roadmap' ya existe (#$projectNumber). Anadiendo issues faltantes..."
} else {
    Write-Host "Creando project MVP Roadmap en $Org..."
    $project = gh project create --owner $Org --title "MVP Roadmap" --format json | ConvertFrom-Json
    $projectNumber = $project.number
    Write-Host "Creado: https://github.com/orgs/$Org/projects/$projectNumber"
}

# Optional: extra Status columns (GitHub Projects v2)
$statusNames = @("Backlog", "Ready", "In Progress", "Review", "Done")
foreach ($name in $statusNames) {
    gh project field-create $projectNumber --owner $Org --name "Status" --single-select-option $name 2>$null
}

$issues = gh issue list --repo $fullRepo --state all --limit 100 --json number | ConvertFrom-Json
$added = 0
foreach ($i in $issues) {
    $url = "$baseUrl/$($i.number)"
    gh project item-add $projectNumber --owner $Org --url $url 2>$null
    if ($LASTEXITCODE -eq 0) { $added++ }
}
Write-Host "Issues enlazadas al board: $added / $($issues.Count)"
Write-Host ""
Write-Host "Abre el tablero:" -ForegroundColor Green
Write-Host "  https://github.com/orgs/$Org/projects/$projectNumber" -ForegroundColor Cyan
Write-Host ""
Write-Host "Columnas sugeridas (Status): Backlog -> Ready -> In Progress -> Review -> Done"
Write-Host "Arrastra las cards o usa el menu Status en cada issue."
