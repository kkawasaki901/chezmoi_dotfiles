---
title: Tooling Commands
type: note
tags:
- project
- tooling
- commands
- goneovim
permalink: goneovim/tooling-commands
---

# Tooling Commands

## Common commands

- [command] TOML syntax check: `python -c "import tomllib; tomllib.load(open('settings.toml','rb')); print('TOML_OK')"`

## Environment

- [env] OS: Windows
- [env] Shell: PowerShell
- [env] Configuration format: TOML
- [env] TOML validation: Python 3 `tomllib`

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