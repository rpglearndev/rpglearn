param([string]$Repo = "rpglearndev/rpglearn")

$labels = @(
    @{ name = "epic/E00"; color = "1D76DB"; description = "Repo y documentación" },
    @{ name = "epic/E01"; color = "1D76DB"; description = "Motor ticks y movimiento" },
    @{ name = "epic/E02"; color = "1D76DB"; description = "Combate, loot, tienda" },
    @{ name = "epic/E03"; color = "1D76DB"; description = "Lua sandbox y editor" },
    @{ name = "epic/E04"; color = "1D76DB"; description = "Clases, skills, equipo" },
    @{ name = "epic/E05"; color = "1D76DB"; description = "Misiones tutorial" },
    @{ name = "epic/E06"; color = "1D76DB"; description = "i18n" },
    @{ name = "epic/E07"; color = "1D76DB"; description = "Backend Node" },
    @{ name = "epic/E08"; color = "1D76DB"; description = "Rankings" },
    @{ name = "epic/E09"; color = "1D76DB"; description = "Data MVP JSON" },
    @{ name = "phase-0"; color = "0E8A16"; description = "Offline MVP core" },
    @{ name = "phase-1"; color = "FBCA04"; description = "Lua, clases, quests" },
    @{ name = "phase-2"; color = "D93F0B"; description = "Backend y rankings" },
    @{ name = "area/client"; color = "5319E7"; description = "Godot cliente" },
    @{ name = "area/server"; color = "5319E7"; description = "Node servidor" },
    @{ name = "area/content"; color = "5319E7"; description = "Datos y contenido" },
    @{ name = "priority/p0"; color = "B60205"; description = "Bloqueante MVP" },
    @{ name = "priority/p1"; color = "E99695"; description = "Importante post-P0" },
    @{ name = "user-story"; color = "C5DEF5"; description = "Historia de usuario" }
)

foreach ($l in $labels) {
    gh label create $l.name --repo $Repo --color $l.color --description $l.description --force 2>$null
    if ($LASTEXITCODE -ne 0) { Write-Warning "Label: $($l.name)" }
}

Write-Host "Labels ready for $Repo"
