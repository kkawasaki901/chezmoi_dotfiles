---
title: Tooling Commands
type: note
tags:
- project
- tooling
- commands
- wezterm
permalink: wezterm/tooling-commands
---

# Tooling Commands

## Common commands
- [command] Validate config loads: `wezterm --config-file wezterm.lua show-keys --lua`（※このコマンドは既定キーのみ表示し、本設定のカスタムキーは出ないため、キー割り当ての検証には使えない）
- [command] Lua 構文チェック: `"/c/Program Files (x86)/Lua/5.1/luac" -p config/bindings.lua`
## Environment
- [env] OS: Windows
- [env] Shell: PowerShell
- [env] Runtime: WezTerm Lua configuration
## AI commands

- [command] Initialize AI memory: init-ai-memory
- [command] Claude normal start: claude
- [command] Claude resume from current directory: claude-resume-current

## Notes

- [note] コマンドが失敗した場合は、エラーメッセージと解決策を Known Errors に記録する。
- [note] 一時的なコマンドや試行錯誤は記録しない。
- [note] 繰り返し使うコマンドだけ残す。

## Relations

- relates_to [[Project Overview]]
- relates_to [[Current State]]
- relates_to [[Known Errors]]