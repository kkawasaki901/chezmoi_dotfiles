---
title: Known Errors
type: note
tags:
- project
- errors
- AutoHotkey
permalink: auto-hotkey/known-errors
---

# Known Errors

## Error log

### 未作成の仮想デスクトップ指定時のエラー

- [symptom] 存在しないデスクトップのホットキーを押すとエラーが発生する
- [cause] SwitchDesktopが不足分を自動作成してから切り替える実装だった
- [fix] 指定番号がGetDesktopCount以上ならそのままreturnする
- [avoid] GoToDesktopNumberの前に存在範囲を確認する

### GUIボタンをクリックしてもデスクトップが切り替わらなくなる

- [symptom] Alt+ZのGUIは表示されるが、ボタンをクリックしても移動しない
- [cause] アクティブなGUIを破棄した直後にDLLを呼び、Windowsのフォーカス復帰とデスクトップ切り替えが競合していた
- [fix] デスクトップを先に切り替え、DLL呼び出しが完了してからGUIをDestroyする
- [avoid] DLL呼び出しの直前にGUIをHideまたはDestroyしない

### GUIからのデスクトップ切り替え時に画面がちらつく

- [symptom] Alt+数字では滑らかだが、GUIボタンでは切り替え直前に画面がちらつく
- [cause] GUIをHideして75ms待つ間に、元のデスクトップが一度再描画されていた
- [fix] Hideと待機を廃止し、Alt+数字と同様に即座にSwitchDesktopを呼ぶ
- [avoid] デスクトップ切り替え前に可視状態を変更しない

### SwitchDesktops.ahkの多重起動

- [symptom] ホットキーやGUIの動作が不安定になる
- [cause] 同じスクリプトの新旧プロセスが同時に起動し、同一ホットキーを登録していた
- [fix] 対象プロセスだけを終了し、/restart付きで1プロセスだけ起動する
- [avoid] 動作確認後にテスト用AutoHotkeyプロセスを残さない

### Focus To-Do Quakeが本体を表示しない

- [symptom] `Ctrl+Alt+Shift+Q`を押してもFocus To-Do本体が出ない、または表示切替が不規則になる
- [cause] `FocusToDo.exe`には本体以外にタイトル付きの不可視`GDI+ Hook Window Class`があり、最初の非空タイトル窓を選ぶ実装が補助窓を保持していた
- [fix] タイトルが`Focus To-Do`で、クラス名が`WindowsForms10.Window.`から始まる本体だけを選ぶ
- [validation] 実キーで本体の表示、非表示、同一HWNDの再表示を確認済み

### Firefox窓を追加するとCtrl+Alt+Shift+7の対象が変わる

- [symptom] Firefoxの新規窓を開いた後、7番のQuakeトグルが以前と別のFirefox窓を操作する
- [cause] AHK内の一時HWNDが使えない場合、`WinGetList`で最初に見つかったFirefox窓を採用していた
- [fix] 専用Win32プロパティで対象を固定し、タグなし時も既存窓を勝手に採用しない
- [validation] Firefoxが複数窓ある状態で固定HWNDだけが表示・非表示され、タグが維持されることを確認

### Contour Quakeで本体の隣に別の変なウィンドウが出る

- [symptom] `Ctrl+Alt+Shift+C`で表示される窓が正しいContourではなく、Qtの内部窓（`_q_titlebar`）になる
- [cause] DetectHiddenWindows有効下で`WinExist("ahk_pid")`が最初に返す窓が、非表示のQt補助窓だった（本体は`Qt6103QWindowIcon`で可視）
- [fix] 可視かつクラスが`_q_`で始まらない窓を`WaitForVisibleTerminalWindow`で選び、タグ検索でも`_q_`窓を除外する
- [avoid] `ahk_pid`で取った窓をそのまま使わない。Qt系アプリは補助窓が先に作られる
- [symptom] 初回Quake起動時に右下に白い長方形が一瞬出る（Contourが既定位置で描画される）
- [fix] 可視になった本体窓を見つけたら直ちにWinHideし、位置とスタイルを整えてからWinShowする
- [validation] 実キー（Ctrl+Alt+Shift+C）で初回起動し、右下の長方形が出ないことを画面キャプチャで確認

### AHK v2文字列中のバックティックは2つ重ねないと落ちる

- [symptom] `"Alt + `"`のように文字列内にバックティック1つを書くと`Missing """`でリロードが失敗する
- [cause] AHK v2はバックティックをエスケープ文字として使うため、直後の`"`がエスケープされてしまう
- [fix] リテラルのバックティックを書くときは``` `` ```（2つ）にする
- [avoid] 文字列中にバックスラッシュ系記号を書くときはAHKのエスケープ規則を先に確認する

## Template

### エラー名

- [symptom] 何が起きたか
- [cause] 原因
- [fix] 解決策
- [avoid] 再発防止

## Relations

- relates_to [[Current State]]
- relates_to [[Tooling Commands]]