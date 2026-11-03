# Global Gemini Instructions

## Basic Memory policy

すべてのプロジェクトで Basic Memory を使って作業記憶を管理する。

### 基本方針

作業開始時は、そのプロジェクトに対応する Basic Memory の記憶を確認する。

memoryフォルダが存在せず、Basic Memoryを使えない場合は、推測せずにその旨を報告する。
その場合は、powershell上で、init-ai-memory コマンドを実行することでmemoryフォルダの生成と初期ノートの作成ができる。
そのようにしてからリトライをし、その結果を報告すること。

優先して確認するノート:

- Project Overview
- Current State
- Architecture Decisions
- Known Errors
- Tooling Commands
- Open Questions

ただし、全ノートを無差別に読むのではなく、作業目的に応じて必要なノートを検索・参照する。

### プロジェクトごとの独立性

Basic Memory の管理はプロジェクトごとに独立させる。

現在の作業ディレクトリに `memory/` がある場合は、その `memory/` をこのプロジェクトの記憶として扱う。

memoryフォルダが存在せず、Basic Memoryを使えない場合は、推測せずにその旨を報告する。
その場合は、powershell上で、init-ai-memory コマンドを実行することでmemoryフォルダの生成と初期ノートの作成ができる。
そのようにしてからリトライをし、その結果を報告すること。

別プロジェクトの記憶を混ぜないこと。

プロジェクト固有の判断、エラー、TODO、コマンドは、そのプロジェクトの `memory/` 配下に記録する。

### 作業開始時

作業開始時に Basic Memory を使える場合は、関連ノートを確認し、以下を短く報告してから作業を始める。

memoryフォルダが存在せず、Basic Memoryを使えない場合は、推測せずにその旨を報告する。
その場合は、powershell上で、init-ai-memory コマンドを実行することでmemoryフォルダの生成と初期ノートの作成ができる。
そのようにしてからリトライをし、その結果を報告すること。

- 参照したノート名
- Current State の要点
- 今回関係しそうな Architecture Decisions
- 注意すべき Known Errors

Basic Memory を使えない場合は、推測せずに「Basic Memoryを使えません」と報告する。

memoryフォルダが存在せず、Basic Memoryを使えない場合は、推測せずにその旨を報告する。
その場合は、powershell上で、init-ai-memory コマンドを実行することでmemoryフォルダの生成と初期ノートの作成ができる。
そのようにしてからリトライをし、その結果を報告すること。

### 記録ルール

新しいノートを作る前に、既存ノートへ追記できないか確認する。

記録するもの:

- 重要な設計判断
- 次回も必要になるTODO
- 再発しそうなエラーと解決策
- 確定した起動・ビルド・テスト・デプロイコマンド
- プロジェクト固有の制約

記録しないもの:

- 一時的な試行錯誤
- 細かすぎるログ
- その場限りの雑談
- すぐ不要になる中間状態

### 作業終了時

作業終了時は、必要に応じて以下を更新する。

- Current State
- Architecture Decisions
- Known Errors
- Tooling Commands
- Open Questions

`Current State` は短く保つ。
古い未決事項は `Open Questions` で整理する。
