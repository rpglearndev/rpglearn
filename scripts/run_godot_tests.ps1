# Runs headless Godot unit tests for client/godot
param(
    [string]$GodotExe = $env:GODOT_PATH
)

$project = (Resolve-Path (Join-Path $PSScriptRoot "..\client\godot")).Path

if (-not $GodotExe) {
    $candidates = @(
        "${env:ProgramFiles}\Godot\Godot_v4.3-stable_win64.exe",
        "${env:ProgramFiles}\Godot\Godot_v4.4-stable_win64.exe",
        "${env:LOCALAPPDATA}\Godot\Godot*.exe"
    )
    foreach ($c in $candidates) {
        $found = Get-Item $c -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) { $GodotExe = $found.FullName; break }
    }
}

if (-not $GodotExe -or -not (Test-Path $GodotExe)) {
    Write-Error "Godot no encontrado. Define GODOT_PATH o instala Godot 4.3+."
    exit 2
}

Write-Host "Using: $GodotExe"
& $GodotExe --headless --path $project -s res://tests/run_tests.gd
exit $LASTEXITCODE
