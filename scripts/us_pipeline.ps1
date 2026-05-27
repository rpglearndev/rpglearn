# GitHub Project status helpers for US pipeline
# Usage:
#   .\scripts\us_pipeline.ps1 start US-010
#   .\scripts\us_pipeline.ps1 review US-010
#   .\scripts\us_pipeline.ps1 approve US-010

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet("start", "review", "approve")]
    [string]$Action,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$UsId
)

$ErrorActionPreference = "Stop"
$Org = "rpglearndev"
$Repo = "rpglearndev/rpglearn"
$ProjectNumber = 1

if ($UsId -notmatch '^US-(\d+)$') {
    if ($UsId -match '^(\d+)$') { $UsId = "US-$($Matches[1])" }
    else { throw "Usa US-010 o 010" }
}

$projectId = (gh project view $ProjectNumber --owner $Org --format json | ConvertFrom-Json).id
$fields = (gh project field-list $ProjectNumber --owner $Org --format json | ConvertFrom-Json).fields
$statusField = $fields | Where-Object { $_.name -eq "Status" } | Select-Object -First 1
if (-not $statusField) { throw "Campo Status no encontrado" }

function Get-StatusOptionId([string]$name) {
    $opt = $statusField.options | Where-Object { $_.name -eq $name } | Select-Object -First 1
    if (-not $opt) { throw "Opcion Status '$name' no existe en el board" }
    return $opt.id
}

$issues = gh issue list --repo $Repo --state all --limit 100 --json number,title | ConvertFrom-Json
$num = ($issues | Where-Object { $_.title -match "^$UsId\s" } | Select-Object -First 1).number
if (-not $num) { throw "No hay issue con titulo $UsId" }

$items = gh project item-list $ProjectNumber --owner $Org --limit 100 --format json | ConvertFrom-Json
$item = $items.items | Where-Object { $_.content.number -eq $num } | Select-Object -First 1
if (-not $item) {
    gh project item-add $ProjectNumber --owner $Org --url "https://github.com/$Repo/issues/$num"
    $items = gh project item-list $ProjectNumber --owner $Org --limit 100 --format json | ConvertFrom-Json
    $item = $items.items | Where-Object { $_.content.number -eq $num } | Select-Object -First 1
}

$statusName = switch ($Action) {
    "start"   { "In Progress" }
    "review"  { "Review" }
    "approve" { "Done" }
}

$optionId = Get-StatusOptionId $statusName
gh project item-edit --id $item.id --project-id $projectId --field-id $statusField.id --single-select-option-id $optionId

if ($Action -eq "approve") {
    gh issue close $num --repo $Repo --comment "Aprobacion humana: $UsId completada (pipeline US)."
    Write-Host "Issue #$num cerrada."
}

Write-Host "$UsId -> Status '$statusName' (issue #$num)"
