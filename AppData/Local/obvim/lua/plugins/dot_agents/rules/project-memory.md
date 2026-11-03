# Project Memory Rule

Read and follow AGENTS.md.

Use this project's memory/ directory as the project-specific Basic Memory notes.

memoryフォルダが存在せず、Basic Memoryを使えない場合は、推測せずにその旨を報告する。
その場合は、powershell上で、init-ai-memory コマンドを実行することでmemoryフォルダの生成と初期ノートの作成ができる。
そのようにしてからリトライをし、その結果を報告すること。
コマンドが見つからない場合は下記を試してほしい。
powershell -ExecutionPolicy Bypass -File "C:\Users\kawasaki\powershell_scripts\init-ai-memory.ps1"

Do not mix memory from other projects.

Before starting work, check the relevant notes in memory/, especially:

- Project Overview
- Current State
- Architecture Decisions
- Known Errors
- Tooling Commands
- Open Questions

Record only important decisions, recurring errors, durable TODOs, and confirmed commands.
Do not record temporary trial-and-error logs.
