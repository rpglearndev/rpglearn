# Enlaza assets/mixel del repo con el proyecto Godot (res://assets/mixel).
$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$target = Join-Path $repoRoot "assets\mixel"
$link = Join-Path $repoRoot "client\godot\assets\mixel"

if (-not (Test-Path $target)) {
    Write-Error "Missing pack at $target — download Mixel PNG zip into assets/mixel."
}
if (Test-Path $link) {
    Write-Host "Already linked: $link"
    exit 0
}
New-Item -ItemType Junction -Path $link -Target $target | Out-Null
Write-Host "Created junction: $link -> $target"
