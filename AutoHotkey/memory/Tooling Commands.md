---
title: Tooling Commands
type: note
tags:
- project
- tooling
- commands
- AutoHotkey
permalink: auto-hotkey/tooling-commands
---

# Tooling Commands

## Common commands

- [command] Install: 要確認
- [command] Run Win11 virtual desktop switch: & 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe' '.\Win11-Virtual-Desktop-Switch\SwitchDesktops.ahk'
- [command] Build: 要確認
- [command] Startup/error check: & 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe' /ErrorStdOut '.\Win11-Virtual-Desktop-Switch\SwitchDesktops.ahk'
- [command] Lint: 要確認
- [command] Format: 要確認

## Environment

- [env] OS: Windows
- [env] Shell: PowerShell
- [env] Package manager: 要確認
- [env] Runtime: AutoHotkey v2 at C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe

## AI commands

- [command] Initialize AI memory: init-ai-memory
- [command] Claude normal start: claude
- [command] Claude resume from current directory: claude-resume-current

## Notes

- [note] コマンドが失敗した場合は、エラーメッセージと解決策を Known Errors に記録する。
- [note] 一時的なコマンドや試行錯誤は記録しない。
- [note] 繰り返し使うコマンドだけ残す。
- [note] Alt + `: WezTerm Quakeを表示・非表示する。
- [note] Ctrl+Alt+Shift+9: Obsidianを表示・非表示する。
- [note] Ctrl+Alt+Shift+6: Firefox Quakeを表示・非表示する。
- [note] Ctrl+Alt+Shift+K: ショートカット一覧（カンニングペーパー）をQuake方式で表示・非表示する。ターミナルからは`kanpe`。
- [command] Reload shortcut cheat sheet: & 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe' /restart /ErrorStdOut '.\space-layer.ahk'
- [command] Reload quake (WezTerm/Obsidian/Firefox Quake): & 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe' /restart /ErrorStdOut '.\alacritty-quake.ahk'
- [note] alacritty-quake.ahkの縮小前フル版バックアップ: alacritty-quake.ahk.bak-20261030-trim
- [note] kanpe: PowerShellから同じカンペ内容を標準出力するコマンド（Microsoft.PowerShell_profile.ps1で定義）

## Relations

- relates_to [[Project Overview]]
- relates_to [[Current State]]
- relates_to [[Known Errors]]