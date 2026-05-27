# Descarga lua-gdextension (release) en client/godot/addons/lua-gdextension
$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$dest = Join-Path $repoRoot "client\godot\addons\lua-gdextension"
$zipUrl = "https://github.com/gilzoide/lua-gdextension/releases/download/0.8.1/lua-gdextension.zip"
$zipPath = Join-Path $env:TEMP "lua-gdextension.zip"

if (Test-Path (Join-Path $dest "luagdextension.gdextension")) {
    Write-Host "lua-gdextension already installed at $dest"
    exit 0
}

Write-Host "Downloading lua-gdextension 0.8.1..."
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing

$extractRoot = Join-Path $env:TEMP "lua-gdextension-extract"
if (Test-Path $extractRoot) { Remove-Item $extractRoot -Recurse -Force }
Expand-Archive -Path $zipPath -DestinationPath $extractRoot

$candidates = @(
    (Join-Path $extractRoot "addons\lua-gdextension"),
    (Join-Path $extractRoot "lua-gdextension")
)
$src = $null
foreach ($c in $candidates) {
    if (Test-Path (Join-Path $c "luagdextension.gdextension")) {
        $src = $c
        break
    }
}
if ($null -eq $src) {
    $found = Get-ChildItem -Path $extractRoot -Recurse -Filter "luagdextension.gdextension" -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($null -ne $found) {
        $src = $found.Directory.FullName
    }
}
if ($null -eq $src -or -not (Test-Path $src)) {
    Write-Error "Could not find lua-gdextension folder inside zip (expected addons/lua-gdextension)"
}

New-Item -ItemType Directory -Path (Split-Path $dest) -Force | Out-Null
if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
Copy-Item -Path $src -Destination $dest -Recurse -Force
Write-Host "Installed: $dest"
