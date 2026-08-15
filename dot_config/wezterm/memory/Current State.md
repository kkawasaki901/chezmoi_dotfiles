---
title: Current State
type: note
tags:
- project
- current
- wezterm
permalink: wezterm/current-state
---

# Current State

## Last updated
- 2026-07-23: WezTerm のコピー／ペーストを Ctrl+Shift+C／Ctrl+Shift+V に統一
## Done
- [status] Basic Memory 用の初期ノートを作成
- [status] `config/bindings.lua` の F12 を `ActivateCopyMode` に設定
- [status] 旧 F12 の `ShowDebugOverlay` 割り当てを削除
- [status] コピーを `Ctrl+Shift+C`、ペーストを `Ctrl+Shift+V` に設定
- [status] 通常モードの `Ctrl+C` と `Ctrl+V` は端末アプリへ渡す構成
- [status] `wezterm --config-file wezterm.lua show-keys --lua` が終了コード0で設定を読み込むことを確認
## Now
- [status] F12 でコピーモードを起動できる構成
- [status] Ctrl+Shift+C／Ctrl+Shift+V でコピー／ペースト
- [status] 通常モードの Ctrl+C／Ctrl+V は端末アプリへ渡される構成
## Next
- [todo] なし
## Blockers
- [status] なし
## Relations

- relates_to [[Project Overview]]
- relates_to [[Architecture Decisions]]
- relates_to [[Known Errors]]
- relates_to [[Tooling Commands]]
- relates_to [[Open Questions]]