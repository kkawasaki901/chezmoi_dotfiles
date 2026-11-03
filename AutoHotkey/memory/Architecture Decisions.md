---
title: Architecture Decisions
type: note
tags:
- project
- architecture
- decisions
- AutoHotkey
permalink: auto-hotkey/architecture-decisions
---

# Architecture Decisions

## Decision log

### 2026-09-15: Basic Memoryをプロジェクト記憶として使う

- [decision] このプロジェクトではBasic Memoryを作業記憶として使う
- [reason] 久しぶりの再開や別エージェントへの引き継ぎを楽にするため
- [constraint] 重要な判断だけ記録し、細かい試行錯誤は記録しない
- [scope] 記憶はこのプロジェクトの memory/ に分離する

### 2026-09-15: AGENTS.mdを共通エージェント指示として使う

- [decision] Claude / Codex / Antigravity 向けの共通作業ルールは AGENTS.md に集約する
- [reason] ツールごとに同じ運用ルールを重複管理しないため
- [note] Antigravity向けには .agents/rules/project-memory.md から AGENTS.md を読むように案内する

### 2026-09-15: 未作成の仮想デスクトップ指定は無視する

- [decision] ホットキーが現在存在しないデスクトップ番号を指す場合は何もしない
- [reason] 意図しない自動作成やDLL呼び出しエラーを防ぐため

### 2026-09-15: デスクトップ選択GUIは開くたびに再構築する

- [decision] Alt+Zを押すたびに現在のデスクトップ数と名前をDLLから取得してボタンを生成する
- [reason] デスクトップの追加、削除、名前変更を次回表示へ確実に反映するため
- [fallback] 名前が空、またはGetDesktopNameを利用できない場合は「デスクトップ N」と表示する

### 2026-09-20: Emacs Quakeは専用タイトルのGUIフレームを再利用する

- [decision] `Ctrl+Alt+Shift+W`で`runemacs.exe --title "Emacs Quake"`を起動し、タイトルと`emacs.exe`で専用ウィンドウを識別する
- [reason] 通常のEmacs GUIを誤って表示・非表示しないため
- [behavior] マウス位置のモニターへ80%中央、枠なし、最前面で表示し、再押下時は終了せず非表示にする

### 2026-09-20: Ctrl+Alt+Shift+QはFocus To-Do Quakeに使う

- [decision] `Ctrl+Alt+Shift+Q`をEmacs QuakeからFocus To-Do Quakeへ変更する
- [implementation] `FocusToDo.exe`の既存ウィンドウを再利用し、未起動時はAppsFolder AppIDから起動する
- [behavior] マウス位置のモニターへ80%中央、枠なし、最前面で表示し、再押下時は終了せず非表示にする
- [note] Emacs Quakeは後に`Ctrl+Alt+Shift+W`へ再割り当てした

### 2026-09-25: Ctrl+Alt+Shift+7はタグ付きFirefox専用窓だけを操作する

- [decision] 対象ウィンドウへWin32プロパティ`Codex_FirefoxFixedQuake`を付け、AHK再読み込み後も同じ窓を検索する
- [reason] Firefoxの新規ウィンドウ追加や列挙順変更でQuake対象が途中から別窓へ移るのを防ぐため
- [fallback] 固定対象が閉じられた場合は他の既存窓へ乗り換えず、新しい専用窓を作成してタグ付けする

### 2026-10-13: DeleteキーをLeaderに使わない

- [decision] Delete Leaderのホットキー、Which Key GUI、選択処理、Shift+BackspaceによるDelete代替を削除する
- [reason] Deleteキーを通常の編集キーとしてそのまま使える状態へ戻すため
- [constraint] Space長押しレイヤー、Quakeショートカット、独立したショートカット一覧GUIは維持する

### 2026-10-06: RioとContourのQuake窓を専用タグで再利用する

- [decision] Ctrl+Alt+Shift+RをRio、Ctrl+Alt+Shift+CをContourのQuakeトグルに割り当てる
- [implementation] 起動した専用窓へWin32プロパティを付け、AHK再読み込み後も通常窓と区別する
- [behavior] マウス位置のモニターへ80%中央、枠なし、最前面で表示し、再押下時は終了せず非表示にする

### 2026-10-30: ショートカット一覧GUIをQuake方式でトグルする

- [decision] `Ctrl+Alt+Shift+K`で既存のショートカット一覧GUI（space-layer.ahk内）を表示・非表示トグルする
- [reason] Delete Leader削除後、GUIを呼び出す常設の入口がなくなっていたため。他のQuake窓と同じ「同じキーで出し入れ」操作に揃える
- [implementation] `ShortcutGuiVisible`フラグで表示状態を追跡し、`ToggleShortcutGui()`が`ShowShortcutGui()`/`HideShortcutGui()`を呼び分ける
- [note] `--show-shortcuts`起動引数での表示経路は維持

### 2026-10-30: alacritty-quake.ahkをWezTerm/Obsidian/Firefox Quakeだけに縮小する

- [decision] 常駐するQuake系ホットキーをWezTerm(Alt+`)、Obsidian(Ctrl+Alt+Shift+9)、Firefox Quake(Ctrl+Alt+Shift+6)の3本だけに絞る
- [reason] 使っていないQuake窓（Alacritty, Raindrop, Firefox通常トグル, Zenn/Qiita, WSJ/X, 4窓ダッシュボード, Chrome Quake, Focus To-Do Quake, Emacs Quake, Quick Memo Quake, Rio Quake, Contour Quake）を整理するため
- [constraint] 削除前の全文は`alacritty-quake.ahk.bak-20261030-trim`に残す。復元が必要なら差し戻す
- [note] カンペGUI（space-layer.ahk）の表示内容もこの3本＋Space Layer＋Kトグルだけに揃えた

### 2026-10-30: カンペはAutoHotkey GUIとターミナルコマンドの2系統で提供する

- [decision] `Ctrl+Alt+Shift+K`のGUI表示に加え、PowerShellプロファイルの`kanpe`関数でも同じ一覧を標準出力する
- [reason] ターミナル作業中にGUIを出さずに確認できるようにするため
- [constraint] 内容は手で二重管理（GUIとPowerShell関数を両方更新する）。共有データファイル化はしていない
- [implementation] `kanpe`は`C:\Users\kawasaki\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`の`hcron`直後に定義

## Relations

- relates_to [[Project Overview]]
- relates_to [[Current State]]
- relates_to [[Open Questions]]