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
- 2026-10-30: 左ステータスバー（上のタブバー内）にアクティブペインのカレントディレクトリを常時表示（`events/left-status.lua`）。`~`置換＋36文字超で末尾ディレクトリ優先の省略表示。既存のLEADER/key_table名表示はcwdの後ろにそのまま続く
- 2026-10-30: LEADER（`Ctrl+Alt+Space`）と`pane_split`key_tableのtimeout_millisecondsを1000→86400000（実質無制限）に変更。`config/bindings.lua`。理由: agy起動中など操作が遅れるとタイムアウトで自動キャンセルされ押下が吸われてしまうため。中断はEscapeで即キャンセル可（WezTerm仕様でどのキー入力でもLEADER解除）
- 2026-10-30: 時計の左に常時表示のLEADER覚書（`Ctrl+Alt+Space →s:分割`）を追加（`events/right-status.lua` の `leader_icon`/`leader_text` セグメント）。key_table起動中だけ出るwhich-keyヒントとは別物
- 2026-10-30: leader key（`Ctrl+Alt+Space`）を復活し、右ステータスバーにwhich-key風ヒントを表示する仕組みを追加。LEADER+s でペイン分割（v=縦/h=横）を選べる `pane_split` key_table を追加
- 2026-10-07: 起動時の workspace（ws1-2pane / ws2-ide / ws3-dashboard）のペイン分割を廃止し、単一ペインの窓にした（`config/workspace.lua`）
- 2026-10-07: タブ切り替えを Alt+1〜8、workspace 切り替えを Ctrl+Alt+1〜4 に変更（Alt+9 は workspace 一覧のまま）
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