# Runs headless Godot unit tests for client/godot
param(
    [string]$GodotExe = $env:GODOT_PATH
)

$project = (Resolve-Path (Join-Path $PSScriptRoot "..\client\godot")).Path

if (-not $GodotExe) {
    $godotDir = "${env:ProgramFiles}\Godot"
    if (Test-Path $godotDir) {
        $found = Get-ChildItem $godotDir -Filter "Godot*.exe" -ErrorAction SilentlyContinue |
            Sort-Object Name -Descending | Select-Object -First 1
        if ($found) { $GodotExe = $found.FullName }
    }
    if (-not $GodotExe) {
        $found = Get-Item "${env:LOCALAPPDATA}\Godot\Godot*.exe" -ErrorAction SilentlyContinue |
            Select-Object -First 1
        if ($found) { $GodotExe = $found.FullName }
    }
}

if (-not $GodotExe -or -not (Test-Path $GodotExe)) {
    Write-Error "Godot no encontrado. Define GODOT_PATH o instala Godot 4.3+."
    exit 2
}

Write-Host "Using: $GodotExe"

$luaExt = Join-Path $project "addons\lua-gdextension\luagdextension.gdextension"
if (Test-Path $luaExt) {
    Write-Host "Importing project (GDExtension)..."
    & $GodotExe --headless --path $project --import --quit
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

& $GodotExe --headless --path $project -s res://tests/run_tests.gd
exit $LASTEXITCODE
