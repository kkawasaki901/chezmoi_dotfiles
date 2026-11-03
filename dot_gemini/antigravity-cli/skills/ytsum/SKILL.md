---
name: ytsum
description: youtubeの文字おこしをもとに、内容をまとめるスキル
metadata:
  owner: data-platform
  version: "0.1.0"
---

# YouTube Summary Batch Skill

## Purpose

`Youtube_Summary/Clip` フォルダ内のファイルを対象に、各ファイルへ `ytsumpart` サブエージェントを適用し、処理済みファイルを `Youtube_Summary/Inbox` に移動する。

## Target folders

* Input folder:

  * `C:\Users\kawasaki\obsidian\2026_master\Youtube_Summary\Clip`

* Output folder:

  * `C:\Users\kawasaki\obsidian\2026_master\Youtube_Summary\Inbox`

## Batch behavior

1. `Youtube_Summary/Clip` フォルダ内の全ファイルを列挙する。
2. 各ファイルごとに、サブエージェント `ytsumpart` を1つ割り当てる。
3. 同時に実行するサブエージェント数の上限は8とする。
4. 実行可能な分の処理が完了したら停止する。
5. 処理に成功したファイルのみ、`Youtube_Summary/Inbox` に移動する。
6. 移動後、処理済みファイルすべてのファイル名をAndroid互換にリネームする。

## Filename sanitization

Android上でエラーになるため、処理済みファイル名に含まれる以下の文字を `_` に置換する。

```regex
r'[\\/:*?"<>|／]'
```

リネーム対象は、処理が無事に完了し、`Youtube_Summary/Inbox` に移動されたファイルのみとする。

## Subagent: ytsumpart

### Role

与えられた1つのファイルを読み取り、`Transcript` セクションの内容をもとに詳細なまとめノートを作成する。

### Task

1. 対象ファイルを読む。
2. `Transcript` という段落または見出しを探す。
3. `Transcript` の段落の中身をもとに、まとめノートを作成する。
4. 情報量はできるだけ削らず、見やすく構造化する。
5. 作成したまとめを、`Transcript` の直前に `Summary` という段落または見出しとして挿入する。
6. 既に `Summary` が存在する場合は、重複作成せず、既存の `Summary` を更新する。
7. ファイルを書き戻す。
8. 正常に完了した場合のみ、そのファイルを次のフォルダへ移動する。

```text
C:\Users\kawasaki\obsidian\2026_master\Youtube_Summary\Inbox
```

### Summary formatting

`Summary` は以下の方針で作成する。

* 日本語で書く
* 情報量を落としすぎない
* 箇条書き、見出し、階層構造を使って読みやすくする
* 話の流れが追えるようにする
* 重要な主張、理由、具体例、結論を残す
* Transcriptの単なる短縮ではなく、後から内容を理解できるノートにする

### Error handling

以下の場合はファイルを移動しない。

* `Transcript` が見つからない
* ファイルの読み取りに失敗した
* Summaryの挿入に失敗した
* ファイルの保存に失敗した

失敗したファイルは `Youtube_Summary/Clip` に残し、次回再実行できるようにする。
