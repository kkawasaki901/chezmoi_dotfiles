param(
    [string]$ProjectName = (Split-Path -Leaf (Get-Location)),
    [string]$MemoryDir = "memory"
)

$ErrorActionPreference = "Stop"

function Write-FileIfMissing {
    param(
        [string]$Path,
        [string]$Content
    )

    if (-not (Test-Path $Path)) {
        $parent = Split-Path -Parent $Path

        if ($parent -and -not (Test-Path $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }

        $Content | Set-Content -Path $Path -Encoding UTF8
        Write-Host "Created: $Path"
    }
    else {
        Write-Host "Skipped:  $Path"
    }
}

function Get-SafeTag {
    param(
        [string]$Text
    )

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return "project"
    }

    return ($Text -replace '[^\p{L}\p{Nd}_-]', '_')
}

$today = Get-Date -Format "yyyy-MM-dd"
$ProjectTag = Get-SafeTag $ProjectName

New-Item -ItemType Directory -Path $MemoryDir -Force | Out-Null
New-Item -ItemType Directory -Path ".agents\rules" -Force | Out-Null

Write-FileIfMissing "AGENTS.md" @"
# AGENTS.md

## Project guide

このプロジェクトでは Basic Memory を使って作業記憶を管理する。

このファイルは Claude / Codex / Antigravity など、複数のAIエージェント向けの共通作業ガイドとして扱う。

## Startup

作業開始時は以下を確認する。

- Project Overview
- Current State
- Architecture Decisions
- Known Errors
- 必要に応じて Tooling Commands
- 未決事項が関係しそうな場合は Open Questions

memoryフォルダが存在せず、Basic Memoryを使えない場合は、推測せずにその旨を報告する。
その場合は、powershell上で、init-ai-memory コマンドを実行することでmemoryフォルダの生成と初期ノートの作成ができる。
そのようにしてからリトライをし、その結果を報告すること。
コマンドが見つからない場合は下記を試してほしい。
powershell -ExecutionPolicy Bypass -File "C:\Users\kawasaki\powershell_scripts\init-ai-memory.ps1"

## Memory rules

- 全ノートを読むのではなく、目的に応じて検索する。
- 新しいノートを作る前に、既存ノートに追記できないか確認する。
- 一時的な試行錯誤や細かいログは記録しない。
- 重要な設計判断、次回TODO、再発しそうなエラーだけ記録する。
- `Current State` は短く保つ。
- 別プロジェクトの `memory/` と混ぜない。
- このプロジェクトの記憶は、このプロジェクト直下の `memory/` を正とする。

## Design changes

設計変更前は以下を確認する。

- Architecture Decisions
- Open Questions

まだ決まっていない方針があれば `Open Questions` に記録する。

## Error investigation

エラー調査時は以下を確認する。

- Known Errors

再発しそうなエラーは `Known Errors` に記録する。

## Work completion

作業終了時は、必要に応じて以下を更新する。

- Current State
- Architecture Decisions
- Known Errors
- Tooling Commands
- Open Questions

コマンドが確定したら `Tooling Commands` を更新する。
未決事項が出たら `Open Questions` に記録する。
一時的な試行錯誤や細かいログは記録しない。
"@

Write-FileIfMissing ".agents\rules\project-memory.md" @"
# Project Memory Rule

Read and follow `AGENTS.md`.

Use this project's `memory/` directory as the project-specific Basic Memory notes.

memoryフォルダが存在せず、Basic Memoryを使えない場合は、推測せずにその旨を報告する。
その場合は、powershell上で、init-ai-memory コマンドを実行することでmemoryフォルダの生成と初期ノートの作成ができる。
そのようにしてからリトライをし、その結果を報告すること。
コマンドが見つからない場合は下記を試してほしい。
powershell -ExecutionPolicy Bypass -File "C:\Users\kawasaki\powershell_scripts\init-ai-memory.ps1"

Do not mix memory from other projects.

Before starting work, check the relevant notes in `memory/`, especially:

- Project Overview
- Current State
- Architecture Decisions
- Known Errors
- Tooling Commands
- Open Questions

Record only important decisions, recurring errors, durable TODOs, and confirmed commands.
Do not record temporary trial-and-error logs.
"@

Write-FileIfMissing "CLAUDE.md" @"
# Claude instructions

## このプロジェクトでは `AGENTS.md` を主要な作業ガイドとして扱う。

作業開始時に `AGENTS.md` を読む。

Basic Memory が使える場合は、このプロジェクトの `memory/` に対応する記憶を確認する。

memoryフォルダが存在せず、Basic Memoryを使えない場合は、推測せずにその旨を報告する。
その場合は、powershell上で、init-ai-memory コマンドを実行することでmemoryフォルダの生成と初期ノートの作成ができる。
そのようにしてからリトライをし、その結果を報告すること。
コマンドが見つからない場合は下記を試してほしい。
powershell -ExecutionPolicy Bypass -File "C:\Users\kawasaki\powershell_scripts\init-ai-memory.ps1"

確認後、以下を短く報告してから作業を始める。

- 参照したノート名
- Current Stateの要点
- 今回関係しそうなArchitecture Decisions
- 注意すべきKnown Errors

Basic Memoryを使えない場合は、推測せず「Basic Memoryを使えません」と報告する。


"@

Write-FileIfMissing (Join-Path $MemoryDir "Project Overview.md") @"
---
title: Project Overview
type: note
tags:
  - project
  - overview
  - $ProjectTag
---

# Project Overview

## Summary

- [project] $ProjectName
- [status] 要確認
- [goal] 要確認

## Tech stack

- [stack] 要確認

## Important constraints

- [constraint] Windows環境を優先する
- [constraint] ローカル保存を優先する
- [constraint] 破壊的変更は避ける

## Relations

- relates_to [[Current State]]
- relates_to [[Architecture Decisions]]
- relates_to [[Known Errors]]
- relates_to [[Tooling Commands]]
- relates_to [[Open Questions]]
"@

Write-FileIfMissing (Join-Path $MemoryDir "Current State.md") @"
---
title: Current State
type: note
tags:
  - project
  - current
  - $ProjectTag
---

# Current State

## Last updated

- ${today}: 初期メモリを作成

## Done

- [status] Basic Memory用の初期ノートを作成
- [status] AGENTS.mdを作成
- [status] CLAUDE.mdを作成
- [status] Antigravity用の .agents/rules/project-memory.md を作成

## Now

- [status] プロジェクト内容は要確認

## Next

- [todo] Project Overviewを実際の内容に合わせて更新する
- [todo] Tooling Commandsに起動・テスト・ビルドコマンドを記録する
- [todo] Open Questionsの未決事項を整理する

## Blockers

- [risk] 要確認

## Relations

- relates_to [[Project Overview]]
- relates_to [[Architecture Decisions]]
- relates_to [[Known Errors]]
- relates_to [[Tooling Commands]]
- relates_to [[Open Questions]]
"@

Write-FileIfMissing (Join-Path $MemoryDir "Architecture Decisions.md") @"
---
title: Architecture Decisions
type: note
tags:
  - project
  - architecture
  - decisions
  - $ProjectTag
---

# Architecture Decisions

## Decision log

### ${today}: Basic Memoryをプロジェクト記憶として使う

- [decision] このプロジェクトではBasic Memoryを作業記憶として使う
- [reason] 久しぶりの再開や別エージェントへの引き継ぎを楽にするため
- [constraint] 重要な判断だけ記録し、細かい試行錯誤は記録しない
- [scope] 記憶はこのプロジェクトの `memory/` に分離する

### ${today}: AGENTS.mdを共通エージェント指示として使う

- [decision] Claude / Codex / Antigravity 向けの共通作業ルールは `AGENTS.md` に集約する
- [reason] ツールごとに同じ運用ルールを重複管理しないため
- [note] Antigravity向けには `.agents/rules/project-memory.md` から `AGENTS.md` を読むように案内する

## Relations

- relates_to [[Project Overview]]
- relates_to [[Current State]]
- relates_to [[Open Questions]]
"@

Write-FileIfMissing (Join-Path $MemoryDir "Known Errors.md") @"
---
title: Known Errors
type: note
tags:
  - project
  - errors
  - $ProjectTag
---

# Known Errors

## Error log

現時点では未登録。

## Template

### エラー名

- [symptom] 何が起きたか
- [cause] 原因
- [fix] 解決策
- [avoid] 再発防止

## Relations

- relates_to [[Current State]]
- relates_to [[Tooling Commands]]
"@

Write-FileIfMissing (Join-Path $MemoryDir "Tooling Commands.md") @"
---
title: Tooling Commands
type: note
tags:
  - project
  - tooling
  - commands
  - $ProjectTag
---

# Tooling Commands

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

- [command] Initialize AI memory: `init-ai-memory`
- [command] Claude normal start: `claude`
- [command] Claude resume from current directory: `claude-resume-current`

## Notes

- [note] コマンドが失敗した場合は、エラーメッセージと解決策を `Known Errors` に記録する。
- [note] 一時的なコマンドや試行錯誤は記録しない。
- [note] 繰り返し使うコマンドだけ残す。

## Relations

- relates_to [[Project Overview]]
- relates_to [[Current State]]
- relates_to [[Known Errors]]
"@

Write-FileIfMissing (Join-Path $MemoryDir "Open Questions.md") @"
---
title: Open Questions
type: note
tags:
  - project
  - questions
  - decisions
  - $ProjectTag
---

# Open Questions

## Active questions

- [question] このプロジェクトの最終ゴールは何か
- [question] 主要な技術スタックは何か
- [question] 起動・テスト・ビルドコマンドは何か
- [question] 触ってはいけないファイルやディレクトリはあるか

## Resolved questions

### YYYY-MM-DD: 質問タイトル

- [question] 何を決める必要があったか
- [answer] 決定内容
- [reason] 理由
- [moved_to] 必要なら [[Architecture Decisions]] に移動する

## Rules

- [rule] 未決事項だけ `Active questions` に置く。
- [rule] 決まったものは `Resolved questions` に移す。
- [rule] 設計判断として重要なものは `Architecture Decisions` にも記録する。
- [rule] 古い未決事項は放置せず、定期的に整理する。

## Relations

- relates_to [[Current State]]
- relates_to [[Architecture Decisions]]
- relates_to [[Project Overview]]
"@

# Basic Memory project registration
# MCP自体の初期設定はグローバルで行うため、このスクリプトでは扱わない。
# ここでは、このプロジェクトの memory/ を Basic Memory の project として登録するだけ。
if (Get-Command basic-memory -ErrorAction SilentlyContinue) {
    $memoryPath = (Resolve-Path $MemoryDir).Path

    $existingProjects = basic-memory project list 2>$null | Out-String

    if ($existingProjects -notmatch [regex]::Escape($ProjectName)) {
        basic-memory project add $ProjectName $memoryPath
        Write-Host "Registered Basic Memory project: $ProjectName"
    }
    else {
        Write-Host "Basic Memory project may already exist: $ProjectName"
    }

    Write-Host ""
    Write-Host "Basic Memory status:"
    basic-memory status
}
else {
    Write-Warning "basic-memory command not found. Install it first: uv tool install basic-memory"
}

Write-Host ""
Write-Host "Done."
Write-Host "Created or checked:"
Write-Host "- AGENTS.md"
Write-Host "- CLAUDE.md"
Write-Host "- .agents/rules/project-memory.md"
Write-Host "- $MemoryDir/*.md"
Write-Host ""
Write-Host "Next:"
Write-Host "- update memory/Project Overview.md"
Write-Host "- update memory/Tooling Commands.md"
Write-Host "- update memory/Open Questions.md"