# Enlaza data/mvp del repo con el proyecto Godot (res://data/mvp).
$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$target = Join-Path $repoRoot "data\mvp"
$link = Join-Path $repoRoot "client\godot\data\mvp"

if (-not (Test-Path $target)) {
    Write-Error "Missing data/mvp at $target"
}
if (Test-Path $link) {
    Write-Host "Already linked: $link"
    exit 0
}
New-Item -ItemType Junction -Path $link -Target $target | Out-Null
Write-Host "Created junction: $link -> $target"
