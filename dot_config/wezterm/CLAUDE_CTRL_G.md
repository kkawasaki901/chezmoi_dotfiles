# Claude CLI の `Ctrl+G` と外部エディタ

## 症状と切り分け

- `$EDITOR=edit` の状態では、Claude CLI からMicrosoft Editを起動すると停止したように見えた。
- `$EDITOR=notepad` では正常に外部エディタを起動できた。

原因は `Ctrl+G` やWezTermのキー処理ではなく、Claude Codeと同じ端末内で別のTUIであるMicrosoft Editを起動した際の端末制御の競合と判断した。

## 対処

PowerShellプロファイルで `$EDITOR` と `$VISUAL` を `notepad` にする。WezTermでは `Ctrl+G` を加工せず、Claude Codeへ通常どおり送信する。

## 注意点

`$EDITOR` を再び端末型エディタへ変更する場合は、Claude Codeとの組み合わせで動作確認する。
