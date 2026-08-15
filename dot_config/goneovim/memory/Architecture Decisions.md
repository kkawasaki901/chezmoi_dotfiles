---
title: Architecture Decisions
type: note
tags:
- project
- architecture
- decisions
- goneovim
permalink: goneovim/architecture-decisions
---

# Architecture Decisions

## Decision log

### 2026-07-05: Basic Memoryをプロジェクト記憶として使う

- [decision] このプロジェクトではBasic Memoryを作業記憶として使う
- [reason] 久しぶりの再開や別エージェントへの引き継ぎを楽にするため
- [constraint] 重要な判断だけ記録し、細かい試行錯誤は記録しない
- [scope] 記憶はこのプロジェクトの memory/ に分離する

### 2026-07-05: AGENTS.mdを共通エージェント指示として使う

- [decision] Claude / Codex / Antigravity 向けの共通作業ルールは AGENTS.md に集約する
- [reason] ツールごとに同じ運用ルールを重複管理しないため
- [note] Antigravity向けには .agents/rules/project-memory.md から AGENTS.md を読むように案内する

## Relations

- relates_to [[Project Overview]]
- relates_to [[Current State]]
- relates_to [[Open Questions]]