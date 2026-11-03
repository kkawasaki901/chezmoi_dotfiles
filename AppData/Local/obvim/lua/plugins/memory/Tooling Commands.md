---
title: Tooling Commands
type: note
tags:
  - project
  - tooling
  - commands
  - plugins
---

# Tooling Commands

## Validation

```powershell
lua -e "assert(loadfile('plugins.lua'))"
$env:NVIM_APPNAME='obvim'; nvim --headless "+lua local c=require('obsidian').get_client(); assert(c.opts.notes_subdir == 'Inbox'); assert(c.opts.daily_notes.folder == 'Daily'); assert(c.opts.daily_notes.template == 'template_normal.md'); assert(c.opts.templates.folder == 'Templates'); assert(vim.fn.exists(':ObsidianNew') == 2)" +qa
```

## Common commands

- [command] Install: 要確認
- [command] Dev: 要確認
- [command] Build: 要確認
- [command] Test: 要確認
- [command] Lint: 要確認
- [command] Format: 要確認

## Environment

- [env] OS: Windows
- [env] Shell: PowerShell
- [env] Package manager: 要確認
- [env] Runtime: 要確認

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
