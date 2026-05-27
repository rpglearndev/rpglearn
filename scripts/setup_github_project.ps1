param([string]$Org = "rpglearndev", [string]$Repo = "rpglearn")

$ErrorActionPreference = "Stop"

$owner = gh api user --jq .login
Write-Host "Creating project MVP Roadmap under org $Org..."

$projectJson = gh project create --owner $Org --title "MVP Roadmap" --format json 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Trying user owner instead..."
    $projectJson = gh project create --owner $owner --title "MVP Roadmap" --format json
}
$project = $projectJson | ConvertFrom-Json
$projectNumber = $project.number
Write-Host "Project number: $projectNumber"

$fields = gh project field-list $projectNumber --owner $Org --format json | ConvertFrom-Json
$statusField = $fields.fields | Where-Object { $_.name -eq "Status" } | Select-Object -First 1
if (-not $statusField) {
    Write-Warning "Status field not found; skipping column customization"
    exit 0
}

$optionIds = @{}
foreach ($opt in $statusField.options) {
    $optionIds[$opt.name] = $opt.id
}

# GitHub default Status options: Todo, In Progress, Done — add Backlog if API allows
Write-Host "Link repo issues to project via: gh project item-add $projectNumber --owner $Org --url <issue-url>"
Write-Host "Project URL: https://github.com/orgs/$Org/projects/$projectNumber"
