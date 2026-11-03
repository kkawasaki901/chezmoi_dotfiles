---
title: Architecture Decisions
type: note
tags:
- project
- architecture
- decisions
- wezterm
permalink: wezterm/architecture-decisions
---

# Architecture Decisions

## Decision log

### 2026-07-23: Basic Memoryをプロジェクト記憶として使う

- [decision] このプロジェクトではBasic Memoryを作業記憶として使う
- [reason] 久しぶりの再開や別エージェントへの引き継ぎを楽にするため
- [constraint] 重要な判断だけ記録し、細かい試行錯誤は記録しない
- [scope] 記憶はこのプロジェクトの memory/ に分離する

### 2026-07-23: AGENTS.mdを共通エージェント指示として使う

- [decision] Claude / Codex / Antigravity 向けの共通作業ルールは AGENTS.md に集約する
- [reason] ツールごとに同じ運用ルールを重複管理しないため
- [note] Antigravity向けには .agents/rules/project-memory.md から AGENTS.md を読むように案内する

### 2026-10-30: leader key + which-key風ヒントをstatus barに復活

- [decision] `config/bindings.lua` の leader を復活（`Ctrl+Alt+Space`, timeout 1000ms）。neovimのwhich-keyのようなポップアップはWezTerm標準には無いため、右ステータスバーに代替表示する方式を採用
- [reason] key_table（LEADER+f/p/s）を使う際、押せるキーが分からないため
- [impl] `events/right-status.lua` の `update-right-status` で `window:active_key_table()` を見て、`utils/keytable-hints.lua` の文字列を右ステータスに出す
- [impl] LEADER+s → `pane_split` key_table（one_shot）を追加。`v`=縦分割、`h`=横分割
- [note] ヒント文字列を増やす場合は `utils/keytable-hints.lua` に追記するだけでよい

### 2026-10-30: 左ステータスバーにアクティブペインのカレントディレクトリを表示

- [decision] `events/left-status.lua` に cwd セグメントを追加。`update-right-status` イベント内で `pane:get_current_working_dir().file_path` を読み、ホームディレクトリは `~` に置換、`MAX_CWD_LEN`（36文字）を超える場合は末尾ディレクトリを優先して先頭を `…` で省略（`shorten_path`関数）
- [reason] 複数タブ/ペインを行き来する際に今どこのディレクトリにいるか見切れずに分かるようにしたい
- [note] 既存のLEADER/key_table名表示（左ステータスの1〜4番セグメント）はそのまま残し、cwdセグメントの後ろに条件付きで連結する形にした
- [constraint] リモートドメイン等で `get_current_working_dir()` がnilの場合は空文字表示にフォールバック

## Relations

- relates_to [[Project Overview]]
- relates_to [[Current State]]
- relates_to [[Open Questions]]