# Claude instructions

## このプロジェクトでは AGENTS.md を主要な作業ガイドとして扱う。

作業開始時に AGENTS.md を読む。

Basic Memory が使える場合は、このプロジェクトの memory/ に対応する記憶を確認する。

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


