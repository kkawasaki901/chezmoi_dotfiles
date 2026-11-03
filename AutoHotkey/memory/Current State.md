---
title: Current State
type: note
tags:
- project
- current
- AutoHotkey
permalink: auto-hotkey/current-state
---

# Current State

## Last updated

- 2026-09-15: 初期メモリを作成
- 2026-09-15: Win11-Virtual-Desktop-Switchの代替ホットキーを追加
- 2026-09-15: 未作成の仮想デスクトップ指定を無視するように変更
- 2026-09-15: Alt+Zで仮想デスクトップ名の選択GUIを開く機能を追加
- 2026-09-15: GUIボタンからの切り替えが停止するフォーカス競合を修正
- 2026-09-15: GUI経由の切り替え時に発生するちらつきを解消
- 2026-09-20: Ctrl+Alt+Shift+Qで専用Emacs GUIをQuake表示・非表示する機能を追加
- 2026-09-20: Ctrl+Alt+Shift+QをFocus To-Do Quakeへ変更
- 2026-09-25: Focus To-Do Quakeが不可視GDI+補助窓を拾う問題を修正し、実キーで表示・非表示・再表示を確認
- 2026-09-25: Ctrl+Alt+Shift+WにEmacs Quakeを割り当て、通常Emacsと分離した専用窓の表示・非表示・再表示を確認
- 2026-09-25: Ctrl+Alt+Shift+7のFirefox対象を専用タグで固定し、追加窓が増えても対象が変わらないよう修正
- 2026-10-13: Delete Leaderメニューと付随キー処理を削除し、DeleteとShift+BackspaceをWindows標準動作へ戻した
- 2026-10-06: Ctrl+Alt+Shift+R/CにRio/Contour Quakeを追加
- 2026-10-06: Contour Quakeが_q_titlebarを拾う問題を修正（実キーで確認済み）
- 2026-10-06: Contour背景opacityを0.60、配色をWindows Terminal既定（Campbell）に変更
- 2026-10-30: Ctrl+Alt+Shift+Kでショートカット一覧GUI（カンニングペーパー）をQuake方式（同じキーで表示・非表示）にトグルする機能を追加
- 2026-10-30: alacritty-quake.ahkをWezTerm/Obsidian/Firefox Quakeのみに縮小（Alacritty, Raindrop, Firefox通常トグル, Zenn/Qiita, WSJ/X, 4窓ダッシュボード, Chrome Quake, Focus To-Do Quake, Emacs Quake, Quick Memo Quake, Rio Quake, Contour Quakeを削除）。フル版は alacritty-quake.ahk.bak-20261030-trim に保存
- 2026-10-30: カンペGUIの内容も縮小後の3つ＋Space Layer＋Kトグルだけに合わせ、COMMANDSセクション（hp, hcron, kanpe）を追加
- 2026-10-30: PowerShellプロファイルに`kanpe`関数を追加し、同じカンペ内容をターミナルへ標準出力できるようにした

## Done

- [status] Basic Memory用の初期ノートを作成
- [status] AGENTS.mdを作成
- [status] CLAUDE.mdを作成
- [status] Antigravity用の .agents/rules/project-memory.md を作成
- [status] Alt+Q/W/Eを仮想デスクトップ4/5/6、Alt+A/S/Dを7/8/9に割り当て
- [status] ホットキーが未作成のデスクトップを指す場合は何もしない
- [status] Alt+ZのGUIに既存デスクトップの名前ボタンを表示し、クリックで切り替える
- [status] GUIボタンでは先にデスクトップを切り替え、完了後にGUIを破棄する
- [status] Emacs Quakeはマウス位置のモニターへ80%中央・枠なし・最前面で表示し、同じ専用ウィンドウを再利用する
- [status] Ctrl+Alt+Shift+QはFocus To-Doをマウス位置のモニターへ80%中央・枠なし・最前面で表示または非表示にする
- [status] Ctrl+Alt+Shift+RはRio、Ctrl+Alt+Shift+CはContourの専用Quake窓を表示・非表示する
- [status] Ctrl+Alt+Shift+Kでショートカット一覧GUIをQuake方式で表示・非表示する（space-layer.ahk）。ターミナルからは`kanpe`で同内容を標準出力
- [status] alacritty-quake.ahkはWezTerm(Alt+`)、Obsidian(Ctrl+Alt+Shift+9)、Firefox Quake(Ctrl+Alt+Shift+6)の3本のみ常駐

## Now

- [status] Win11-Virtual-Desktop-SwitchはAutoHotkey v2とVirtualDesktopAccessor.dllを使用

## Next

- [todo] Project Overviewを実際の内容に合わせて更新する
- [todo] Tooling Commandsに起動・テスト・ビルドコマンドを記録する
- [todo] Open Questionsの未決事項を整理する

## Blockers

- [risk] 現在なし

## Relations

- relates_to [[Project Overview]]
- relates_to [[Architecture Decisions]]
- relates_to [[Known Errors]]
- relates_to [[Tooling Commands]]
- relates_to [[Open Questions]]