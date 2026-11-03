# Keep PATH below cmd.exe limits by removing duplicate entries before startup tools run.
. 'C:\Users\kawasaki/powershell_scripts/Optimize-ProcessPath.ps1'

$utf8 = [System.Text.UTF8Encoding]::new()
$OutputEncoding = $utf8
# Console.InputEncoding/OutputEncoding へ既に同じコードページのときも代入すると
# SetConsoleCP/SetConsoleOutputCP が呼ばれ、直後にsuperfile(spf)等のGoベースTUIが
# コンソールのraw読み取りで無反応フリーズする。値が異なる場合だけ実際に設定する。
if ([Console]::InputEncoding.CodePage -ne $utf8.CodePage) { [Console]::InputEncoding = $utf8 }
if ([Console]::OutputEncoding.CodePage -ne $utf8.CodePage) { [Console]::OutputEncoding = $utf8 }
# Python製CLI（jrnlなど）のパイプ出力もUTF-8に統一する。
$env:PYTHONIOENCODING = 'utf-8'
$env:PYTHONUTF8 = '1'
$env:MDCAT_THEME = 'catppuccin'
## lazygit
function lg(){ lazygit }
function deb {wsl -- fish -l}

function psmux {
    & 'C:\Users\kawasaki\tools\psmux-fixed\psmux.exe' @args
}

function lk() {
    cd $(walk $args --icons --preview --with-border )
    }

function jbat {
        bat --language jrnl "C:\Users\kawasaki\obsidian\2026_master\jrnl\journal.md"
    }

function jedit {
        nvim "C:\Users\kawasaki\obsidian\2026_master\jrnl\journal.md"
    }

function jmdless {
        jrnl --export md | mdless
    }
function p { psmux }

Set-Alias ls lsd
# lsd のファイル種別色。既定は太字(ESC[1m)で潰れて見えるため、太字なしの 256 色で指定する
# Tokyo Night 系の配色（Rio の [colors] と揃えている）
$env:LS_COLORS = (@(
    'di=38;5;111', 'ln=38;5;117', 'ex=38;5;114', 'fi=38;5;252',
    'pi=38;5;180', 'so=38;5;176', 'bd=38;5;208', 'cd=38;5;208', 'or=38;5;203', 'mi=38;5;203',
    '*.md=38;5;117', '*.txt=38;5;252', '*.ps1=38;5;114', '*.py=38;5;180',
    '*.json=38;5;215', '*.toml=38;5;215', '*.yaml=38;5;215', '*.yml=38;5;215',
    '*.png=38;5;176', '*.jpg=38;5;176', '*.gif=38;5;176', '*.svg=38;5;176',
    '*.zip=38;5;203', '*.7z=38;5;203', '*.tar=38;5;203', '*.gz=38;5;203',
    '*.exe=38;5;114', '*.lua=38;5;111'
) -join ':')
# Lunar Vim
Set-Alias lvim 'C:\Users\kawasaki\.local\bin\lvim.ps1'

function pss($session){
        psmux a -t $session
    }
# nvim-config-alt
function ovim($str){$env:NVIM_APPNAME="ovim";nvim $str;Remove-Item Env:NVIM_APPNAME}
function tvim($str){$env:NVIM_APPNAME="tvim";nvim $str;Remove-Item Env:NVIM_APPNAME}
function obvim($str){$env:NVIM_APPNAME="obvim";nvim $str;Remove-Item Env:NVIM_APPNAME}
function nvchad($str){$env:NVIM_APPNAME="nvchad";nvim $str;Remove-Item Env:NVIM_APPNAME}
function normal($str){$env:NVIM_APPNAME="normal";nvim $str;Remove-Item Env:NVIM_APPNAME}
function cvim($str){$env:NVIM_APPNAME="cvim";nvim $str;Remove-Item Env:NVIM_APPNAME}
function orgvim($str){$env:NVIM_APPNAME="orgvim";nvim $str;Remove-Item Env:NVIM_APPNAME}
function pyvim($str){$env:NVIM_APPNAME="pyvim";nvim $str;Remove-Item Env:NVIM_APPNAME}
function orgmodevim($str){$env:NVIM_APPNAME="orgmode";nvim $str;Remove-Item Env:NVIM_APPNAME}
function mvim($str){$env:NVIM_APPNAME="mvim";nvim $str;Remove-Item Env:NVIM_APPNAME}
function testvim($str){$env:NVIM_APPNAME="testvim";nvim $str;Remove-Item Env:NVIM_APPNAME}

function memovim{ nvim -u "C:\Users\kawasaki\obsidian\2026_master/obsidian_nvim_init.lua"}
function nbvim{ nvim -u "C:\Users\kawasaki\nb-obsidian\nb-statusline.lua"}

function init-ai-memory {
    powershell -ExecutionPolicy Bypass -File "C:\Users\kawasaki\powershell_scripts\init-ai-memory.ps1" @args
}

function gclone {
    powershell -ExecutionPolicy Bypass -File "C:\Users\kawasaki\powershell_scripts\clone-drive.ps1" @args
}


function init-claude-memory {
    claude mcp add -s project basic-memory -- uvx basic-memory mcp
    }

function agyc {
    agy -c --dangerously-skip-permissions
    }

function agyd {
    agy  --dangerously-skip-permissions
    }

function agyr {
    & "C:\Users\kawasaki\powershell_scripts\agy-resume.ps1" @args
    }

# Codexのalternate screenはZellijのスクロールバックに履歴を残さない。
# Zellij内だけinline modeにして、通常のマウスホイールで遡れるようにする。
function codex {
    $codexExe = "C:\Users\kawasaki\AppData\Local\Programs\OpenAI\Codex\bin\codex.exe"

    if ($env:ZELLIJ -or $env:ZELLIJ_SESSION_NAME) {
        & $codexExe --no-alt-screen @args
    }
    else {
        & $codexExe @args
    }
}

function codexc {
    codex resume --last 
    }

function zellij {
    & "C:\Users\kawasaki\AppData\Local\Zellij\zellij.exe" @args
}

# terminal-obsidian
function to {
    & "$env:APPDATA\Python\Python314\Scripts\terminal-obsidian.exe" @args
}


function update-codex {
    irm https://chatgpt.com/codex/install.ps1 | iex
    }


function claudec {
    & claude -c --dangerously-skip-permissions @args
}

function clauded {
        claude --dangerously-skip-permissions
    }

function oc {
    opencode -c --auto @args
  }

#$env:EDITOR = 'C:\\Users\\kawasaki\\codex\\260701_simple_markdown\\mdprompt-claude.cmd'
#$env:VISUAL = 'C:\\Users\\kawasaki\\codex\\260701_simple_markdown\\mdprompt-claude.cmd'
$env:EDITOR = 'micro'
$env:VISUAL = 'micro'
function yazi {
	& 'C:\Users\kawasaki\scoop\apps\yazi\current\yazi.exe' @args
}

function y {
	$tmp = (New-TemporaryFile).FullName
	yazi @args --cwd-file="$tmp"
	$cwd = Get-Content -Path $tmp -Encoding UTF8
	if ($cwd -and $cwd -ne $PWD.Path -and (Test-Path -LiteralPath $cwd -PathType Container)) {
		Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
	}
	Remove-Item -Path $tmp
}

# edit-PS-Run
function eps {
    param(
        [string]$Editor = $env:EDITOR
    )

    if ([string]::IsNullOrWhiteSpace($Editor)) {
        $Editor = "notepad"
    }
    $tmp = Join-Path $env:TEMP ("psrun_" + [guid]::NewGuid().ToString() + ".ps1")

    @'
# ここにPowerShellスクリプトを書く
# 保存して閉じると、そのまま実行します。

'@ | Set-Content -Path $tmp -Encoding UTF8

    & $Editor $tmp

    Write-Host ""
    Write-Host "Running script:" -ForegroundColor Yellow
    Write-Host $tmp
    Write-Host ""

    & $tmp

    Remove-Item $tmp -ErrorAction SilentlyContinue
}

# >>> cmdlauncher >>>
function cl {
    & "C:\Users\kawasaki\claude\260718_rg_fzf-fd\launcher.ps1" @args
    $__clCd = Join-Path $env:USERPROFILE '.cmdlauncher\lastdir'
    if (Test-Path $__clCd) {
        $__clDir = (Get-Content $__clCd -Raw).Trim()
        Remove-Item $__clCd -Force
        if ($__clDir -and (Test-Path -LiteralPath $__clDir)) { Set-Location -LiteralPath $__clDir }
    }
}
# <<< cmdlauncher <<<


# ── Profile initialization cache ──────────────────────────────

$profileCacheDir = Join-Path $env:LOCALAPPDATA 'PowerShell\ProfileCache'

if (-not (Test-Path $profileCacheDir)) {
    New-Item -ItemType Directory -Path $profileCacheDir -Force | Out-Null
}

# zoxide
$zoxideInitCache = Join-Path $profileCacheDir 'zoxide-init.ps1'

if (-not (Test-Path $zoxideInitCache)) {
    zoxide init powershell |
        Set-Content -Path $zoxideInitCache -Encoding utf8
}

. $zoxideInitCache

# Oh My Posh
# NO_COLOR が立っていると OMP は色を消すため、カラフルなプロンプトのために外す
Remove-Item Env:NO_COLOR -ErrorAction SilentlyContinue
$ompInitCache = Join-Path $profileCacheDir 'oh-my-posh-init.ps1'
$ompConfig = 'C:\Users\kawasaki\AppData\Local\omp-manager\themes\paradox.omp.json'

if (-not (Test-Path $ompInitCache)) {
    oh-my-posh init pwsh --config $ompConfig |
        Set-Content -Path $ompInitCache -Encoding utf8
}

. $ompInitCache

. 'C:\Users\kawasaki\AppData\Roaming\dystroy\broot\config\launcher\powershell\br.ps1'


function nvim {
    $server = '\\.\pipe\nvim-main'

    # 既存のNeovimサーバーが動いているか確認
    & nvim.exe --server $server --remote-expr '1' *> $null
    $serverExists = $LASTEXITCODE -eq 0

    if ($serverExists) {
        # ファイル名が指定された場合、既存Neovimで開く
        if ($args.Count -gt 0) {
            & nvim.exe --server $server --remote @args

            if ($LASTEXITCODE -ne 0) {
                return
            }
        }

        # 既存Neovimの画面へ再接続
        & nvim.exe --server $server --remote-ui
    }
    else {
        # 初回は新しいNeovimを起動
        & nvim.exe --listen $server @args
    }
}

# >>> splashboard >>>
# Added by `splashboard install`. Safe to remove.
Invoke-Expression (& splashboard init powershell | Out-String)
# <<< splashboard <<<

function quake{
  wt -w _quake `
  new-tab -p "MAIN" `; `
  new-tab -p "CODEX" `; `
  new-tab -p "SSH" `; `
  new-tab -p "NOTES"
}

# >>> lifeos >>>
# Added by LifeOS install. Launches Claude Code with the LifeOS system prompt appended.
function lifeos {
    bun "C:\Users\kawasaki\.claude\LIFEOS\TOOLS\lifeos.ts" -s "C:\Users\kawasaki\.claude\LIFEOS\LIFEOS_SYSTEM_PROMPT.md" @args
}
# <<< lifeos <<<

# hermes profile picker: fzfで選んだプロファイルでhermesを開く
function hp {
    $hermesExe = "C:\Users\kawasaki\AppData\Local\hermes\bin\hermes.exe"

    $profiles = & $hermesExe profile list 2>$null |
        Where-Object { $_.Trim() -ne '' -and $_.Trim() -notmatch '^[─\s]+$' -and $_.Trim() -notlike 'Profile *' } |
        ForEach-Object { (($_.Trim() -replace '^◆\s*', '') -split '\s+')[0] }

    $selected = $profiles | fzf --prompt='hermes profile> ' --height=40% --reverse
    if (-not $selected) { return }

    if ($args.Count -gt 0) {
        & $hermesExe --profile $selected @args
    }
    else {
        & $hermesExe --profile $selected chat
    }
}

# hermes cron browser: fzfでcronジョブ→結果mdを選んでbatで見る
function hcron {
    & "C:\Users\kawasaki\hermes\scripts\cron-browser.ps1" @args
}

# カンペ: AutoHotkeyのQuakeショートカットとよく使うコマンドの一覧を標準出力する。
# AutoHotkey側(space-layer.ahk / Ctrl+Alt+Shift+K)と内容を揃えること。
function kanpe {
    Write-Host ""
    Write-Host "GLOBAL / QUAKE"
    Write-Host "  Alt + ``                      WezTerm        専用Quakeを表示 / 非表示"
    Write-Host "  Ctrl + Alt + Shift + 9       Obsidian       表示 / 非表示"
    Write-Host "  Ctrl + Alt + Shift + 6       Firefox Quake  専用窓・位置とサイズを記憶"
    Write-Host ""
    Write-Host "KEY LAYERS"
    Write-Host "  Space 長押し                 Space Layer    J=IME ON  F=OFF  H=BS  G=Space  B=Enter  V=Esc"
    Write-Host "  Ctrl + Alt + Shift + K       カンペ         表示 / 非表示（Quake方式）"
    Write-Host ""
    Write-Host "COMMANDS"
    Write-Host "  hp                           hermes profile fzfでプロファイルを選んでhermesを開く"
    Write-Host "  hcron                        hermes cron    fzfでcronジョブ結果を選んでbatで見る"
    Write-Host "  kanpe                        このカンペ     この一覧をターミナルに標準出力"
    Write-Host ""
}
