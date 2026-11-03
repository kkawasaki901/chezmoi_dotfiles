param(
    [switch]$All
)

$ErrorActionPreference = 'Stop'

$dbPath = Join-Path $env:USERPROFILE '.gemini\antigravity-cli\conversation_summaries.db'
if (-not (Test-Path -LiteralPath $dbPath -PathType Leaf)) {
    Write-Error "agy session database was not found: $dbPath"
    return
}

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Error 'Python is required to read the agy session database.'
    return
}

$pythonCode = @'
import json
import sqlite3
import sys
import urllib.parse

db_path = sys.argv[1]
current_dir = sys.argv[2]
show_all = sys.argv[3] == "1"

def normalize(path):
    return path.replace("/", "\\").rstrip("\\").casefold()

def uri_to_path(uri):
    parsed = urllib.parse.urlparse(uri)
    if parsed.scheme != "file":
        return ""
    path = urllib.parse.unquote(parsed.path)
    if len(path) >= 3 and path[0] == "/" and path[2] == ":":
        path = path[1:]
    return path.replace("/", "\\")

connection = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
rows = connection.execute(
    """
    SELECT conversation_id, title, preview, last_modified_time, workspace_uris,
           step_count
      FROM conversation_summaries
     WHERE killed = 0
     ORDER BY last_modified_time DESC
    """
).fetchall()
connection.close()

result = []
for conversation_id, title, preview, modified, workspace_json, step_count in rows:
    try:
        uris = json.loads(workspace_json or "[]")
    except json.JSONDecodeError:
        uris = []
    paths = [uri_to_path(uri) for uri in uris]
    paths = [path for path in paths if path]
    if not paths:
        continue
    if not show_all and not any(normalize(path) == normalize(current_dir) for path in paths):
        continue
    result.append({
        "id": conversation_id,
        "label": title or preview or "(untitled)",
        "modified": modified[:19].replace("T", " "),
        "workspace": paths[0],
        "steps": step_count,
    })

print(json.dumps(result, ensure_ascii=True))
'@

$json = & python -c $pythonCode $dbPath $PWD.Path $(if ($All) { '1' } else { '0' })
if ($LASTEXITCODE -ne 0) {
    Write-Error 'Failed to read agy session history.'
    return
}

$sessions = @($json | ConvertFrom-Json)
if ($sessions.Count -eq 0) {
    if ($All) {
        Write-Host '再開できる agy セッションがありません。'
    } else {
        Write-Host "現在のディレクトリに一致する agy セッションがありません: $($PWD.Path)"
        Write-Host '全履歴を表示するには agyr -All を使ってください。'
    }
    return
}

$lines = $sessions | ForEach-Object {
    "$($_.modified)`t$($_.label)`t$($_.workspace)`t$($_.steps) steps`t$($_.id)"
}

$prompt = if ($All) { 'agy all> ' } else { 'agy cwd> ' }
$selected = $lines | fzf --delimiter "`t" --with-nth 1,2,3,4 --prompt=$prompt --height=100% --reverse
if ([string]::IsNullOrWhiteSpace($selected)) {
    return
}

$parts = $selected -split "`t", 5
$workspace = $parts[2]
$conversationId = $parts[4]

if (-not (Test-Path -LiteralPath $workspace -PathType Container)) {
    Write-Error "セッションの作業ディレクトリが見つかりません: $workspace"
    return
}

Push-Location -LiteralPath $workspace
try {
    Write-Host "Resume: $conversationId" -ForegroundColor Cyan
    Write-Host "Workspace: $workspace" -ForegroundColor DarkGray
    & agy --conversation $conversationId
}
finally {
    Pop-Location
}
