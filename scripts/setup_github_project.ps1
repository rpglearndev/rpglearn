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

# Status columns: GitHub crea Todo / In Progress / Done por defecto.
# Para Backlog, Ready, Review: en el board -> ... -> Settings -> Fields -> Status -> edit options.

$issues = gh issue list --repo $fullRepo --state all --limit 100 --json number | ConvertFrom-Json
$added = 0
$skipped = 0
foreach ($i in $issues) {
    $url = "$baseUrl/$($i.number)"
    gh project item-add $projectNumber --owner $Org --url $url 2>$null
    if ($LASTEXITCODE -eq 0) { $added++ } else { $skipped++ }
}
Write-Host "Issues enlazadas: $added nuevas, $skipped ya estaban o fallaron (total issues repo: $($issues.Count))"
Write-Host ""
Write-Host "Abre el tablero:" -ForegroundColor Green
Write-Host "  https://github.com/orgs/$Org/projects/$projectNumber" -ForegroundColor Cyan
Write-Host ""
Write-Host "Columnas Status (manual en GitHub UI):" -ForegroundColor Yellow
Write-Host "  Settings -> Fields -> Status -> anade: Backlog, Ready, Review (ademas de Todo/In Progress/Done)"
Write-Host "  Orden P0: US-001 Done, US-002 Ready, US-010/011/012/090 en Backlog"
