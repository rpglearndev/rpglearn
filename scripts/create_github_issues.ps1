# Creates GitHub issues from docs/backlog.md
# Usage: ./scripts/create_github_issues.ps1 [-Repo rpglearndev/rpglearn] [-DryRun]

param(
    [string]$Repo = "rpglearndev/rpglearn",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$backlogPath = Join-Path $root "docs\backlog.md"
$bodyDir = Join-Path $root "scripts\issue-bodies"
New-Item -ItemType Directory -Force -Path $bodyDir | Out-Null

$titleMap = @{
    "001" = "chore: init monorepo + docs/plan.md"
    "002" = "chore: GitHub Project + issue template"
    "010" = "feat(client): tick engine 10 TPS"
    "011" = "feat(client): WASD and joystick input"
    "012" = "feat(client): World_01 TileMap 32x32"
    "020" = "feat(client): combat by ticks"
    "021" = "content: three MVP monsters and spawns"
    "022" = "feat(client): loot, inventory and capacity"
    "023" = "feat(client): Riverton shop buy/sell"
    "030" = "feat(client): Lua sandbox + API MVP"
    "031" = "feat(client): in-game code editor"
    "032" = "feat(client): pedagogical quest validator"
    "040" = "feat(client): class selection and starter gear"
    "041" = "feat(client): skills by use anti-farm"
    "042" = "feat(client): equipment slots atk/def"
    "043" = "feat(client): skip tutorial mode"
    "050" = "quest: welcome manual (quest_welcome_manual)"
    "051" = "quest: variables (quest_variables_state)"
    "052" = "quest: conditionals (quest_if_safe_or_heal)"
    "053" = "quest: loops (quest_loop_patrol)"
    "054" = "quest: functions (quest_function_move_to_flag)"
    "055" = "quest: missions 6-10 tutorial arc"
    "060" = "feat(client): i18n ES/EN"
    "070" = "feat(server): auth and profile API"
    "071" = "feat(server): cloud save"
    "072" = "feat(server): sim worker and challenge attempts"
    "080" = "feat(server): world_01 leaderboards (6 boards)"
    "081" = "feat(client): offline challenge dummy"
    "090" = "chore: MVP data JSON pack"
}

$labelMap = @{
    "001" = @("epic/E00","phase-0","priority/p0","user-story")
    "002" = @("epic/E00","phase-0","user-story")
    "010" = @("epic/E01","phase-0","area/client","priority/p0","user-story")
    "011" = @("epic/E01","phase-0","area/client","user-story")
    "012" = @("epic/E01","phase-0","area/client","area/content","user-story")
    "020" = @("epic/E02","phase-0","area/client","user-story")
    "021" = @("epic/E02","phase-0","area/content","user-story")
    "022" = @("epic/E02","phase-0","area/client","user-story")
    "023" = @("epic/E02","phase-0","area/client","user-story")
    "030" = @("epic/E03","phase-1","area/client","priority/p0","user-story")
    "031" = @("epic/E03","phase-1","area/client","user-story")
    "032" = @("epic/E03","phase-1","area/client","user-story")
    "040" = @("epic/E04","phase-1","area/client","user-story")
    "041" = @("epic/E04","phase-1","area/client","user-story")
    "042" = @("epic/E04","phase-1","area/client","user-story")
    "043" = @("epic/E04","phase-1","area/client","user-story")
    "050" = @("epic/E05","phase-1","area/content","user-story")
    "051" = @("epic/E05","phase-1","area/content","user-story")
    "052" = @("epic/E05","phase-1","area/content","user-story")
    "053" = @("epic/E05","phase-1","area/content","user-story")
    "054" = @("epic/E05","phase-1","area/content","user-story")
    "055" = @("epic/E05","phase-1","area/content","user-story")
    "060" = @("epic/E06","phase-1","area/client","user-story")
    "070" = @("epic/E07","phase-2","area/server","user-story")
    "071" = @("epic/E07","phase-2","area/server","user-story")
    "072" = @("epic/E07","phase-2","area/server","user-story")
    "080" = @("epic/E08","phase-2","area/server","user-story")
    "081" = @("epic/E08","phase-2","area/client","user-story")
    "090" = @("epic/E09","phase-0","area/content","priority/p0","user-story")
}

$content = Get-Content $backlogPath -Raw -Encoding UTF8
# Title line may use em dash, hyphen, or mojibake; body ends at next --- or Epic header
$pattern = '(?ms)^#### (US-\d+)\s+.+?\r?\n(.*?)(?=^---\r?\n|^### Epic |^### Orden |\z)'
$matches = [regex]::Matches($content, $pattern)

Write-Host "Found $($matches.Count) user stories in backlog.md"

foreach ($m in $matches) {
    $idFull = $m.Groups[1].Value
    $id = $idFull -replace 'US-', ''
    $body = $m.Groups[2].Value.Trim()

    $titleKey = $titleMap[$id]
    if (-not $titleKey) { $titleKey = "user story" }
    $title = "US-$id - $titleKey"

    $footer = "---`nDocs: [plan](https://github.com/$Repo/blob/master/docs/plan.md) | [backlog](https://github.com/$Repo/blob/master/docs/backlog.md)"
    $fullBody = "**Backlog:** US-$id`n`n$body`n`n$footer"

    $bodyFile = Join-Path $bodyDir "US-$id.md"
    [System.IO.File]::WriteAllText($bodyFile, $fullBody, [System.Text.UTF8Encoding]::new($false))

    $labels = $labelMap[$id]
    if (-not $labels) { $labels = @("user-story") }

    $labelArgs = ($labels | ForEach-Object { "--label", $_ }) -join ' '

    if ($DryRun) {
        Write-Host "[dry-run] $title"
        continue
    }

    $argList = @("issue", "create", "--repo", $Repo, "--title", $title, "--body-file", $bodyFile) + ($labels | ForEach-Object { "--label"; $_ })
    & gh @argList
    if ($LASTEXITCODE -ne 0) { Write-Warning "Failed: $title" }
    Start-Sleep -Milliseconds 400
}

Write-Host "Done."
