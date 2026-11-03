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
- Current State は短く保つ。
- 別プロジェクトの memory/ と混ぜない。
- このプロジェクトの記憶は、このプロジェクト直下の memory/ を正とする。

## Design changes

設計変更前は以下を確認する。

- Architecture Decisions
- Open Questions

まだ決まっていない方針があれば Open Questions に記録する。

## Error investigation

エラー調査時は以下を確認する。

- Known Errors

再発しそうなエラーは Known Errors に記録する。

## Work completion

作業終了時は、必要に応じて以下を更新する。

- Current State
- Architecture Decisions
- Known Errors
- Tooling Commands
- Open Questions

コマンドが確定したら Tooling Commands を更新する。
未決事項が出たら Open Questions に記録する。
一時的な試行錯誤や細かいログは記録しない。
