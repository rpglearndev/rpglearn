# Updates GitHub issue bodies from docs/backlog.md (UTF-8)
param([string]$Repo = "rpglearndev/rpglearn")

$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$backlogPath = Join-Path $root "docs\backlog.md"
$bodyDir = Join-Path $root "scripts\issue-bodies"
New-Item -ItemType Directory -Force -Path $bodyDir | Out-Null

$content = Get-Content $backlogPath -Raw -Encoding UTF8
$pattern = '(?ms)^#### (US-\d+)\s+.+?\r?\n(.*?)(?=^---\r?\n|^### Epic |^### Orden |\z)'
$storyMatches = [regex]::Matches($content, $pattern)

$issues = gh issue list --repo $Repo --state all --limit 100 --json number,title | ConvertFrom-Json
$byUs = @{}
foreach ($i in $issues) {
    if ($i.title -match '^US-(\d+)') { $byUs[$Matches[1]] = $i.number }
}

foreach ($m in $storyMatches) {
    $id = ($m.Groups[1].Value -replace 'US-', '')
    $body = $m.Groups[2].Value.Trim()
    $footer = "---`nDocs: [plan](https://github.com/$Repo/blob/master/docs/plan.md) | [backlog](https://github.com/$Repo/blob/master/docs/backlog.md)"
    $fullBody = "**Backlog:** US-$id`n`n$body`n`n$footer"
    $bodyFile = Join-Path $bodyDir "US-$id.md"
    [System.IO.File]::WriteAllText($bodyFile, $fullBody, [System.Text.UTF8Encoding]::new($false))

    $num = $byUs[$id]
    if (-not $num) { Write-Warning "No issue for US-$id"; continue }
    gh issue edit $num --repo $Repo --body-file $bodyFile
    if ($LASTEXITCODE -ne 0) { Write-Warning "Failed US-$id (#$num)" }
    else { Write-Host "Updated #$num US-$id" }
    Start-Sleep -Milliseconds 350
}

Write-Host "Done."
