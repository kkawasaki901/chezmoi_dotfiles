# qutebrowser 設定ファイル
# 場所: %APPDATA%\qutebrowser\config\config.py
# 反映: qutebrowser 内で :config-source (または再起動)
#
# 方針:
# - 検索は Google を基底にし、プレフィックスで他エンジンを使い分ける
# - 配色はデスクトップ (GlazeWM/Zebar) と揃えて Catppuccin Mocha
# - フォントは JetBrainsMono NF

# GUI (:set) での設定変更を autoconfig.yml から読み込まない。
# この config.py を設定の唯一の正とする。
config.load_autoconfig(False)

# ============================================================
# 検索エンジン
# ============================================================
# アドレスバーに直接語句を打つと DEFAULT (Google) で検索。
# 「プレフィックス + 空白 + 語句」で他エンジンを指定できる。
#   例: `w 圏論` → 日本語版 Wikipedia
c.url.searchengines = {
    "DEFAULT": "https://www.google.com/search?q={}",
    "g": "https://www.google.com/search?q={}",
    "d": "https://duckduckgo.com/?q={}",
    "yt": "https://www.youtube.com/results?search_query={}",
    "gh": "https://github.com/search?q={}&type=repositories",
    "w": "https://ja.wikipedia.org/wiki/Special:Search?search={}",
    "we": "https://en.wikipedia.org/wiki/Special:Search?search={}",
    "a": "https://www.amazon.co.jp/s?k={}",
    "eijiro": "https://eow.alc.co.jp/search?q={}",
}

# スタートページと :open のデフォルト
c.url.start_pages = ["https://www.google.com/"]
c.url.default_page = "https://www.google.com/"

# ============================================================
# 全般
# ============================================================
# 終了時のセッションを自動保存し、次回起動時に復元できるようにする
c.auto_save.session = True

# ダウンロード先と、完了後にバーを自動で閉じるまでの時間 (ms)
c.downloads.location.directory = "C:/Users/kawasaki/Downloads"
c.downloads.remove_finished = 10000

# HTTP Accept-Language (日本語優先) とロケール (日本語化)
# ※ content.locale という設定は存在しないため、Chromium の --lang で指定する
c.content.headers.accept_language = "ja-JP,ja;q=0.9,en-US;q=0.8,en;q=0.7"
c.qt.args = ["lang=ja"]

# 広告ブロック (Brave の adblock ライブラリがあれば併用する "auto")
c.content.blocking.enabled = True
c.content.blocking.method = "auto"

# 動画の自動再生を無効化。通知はサイトごとに確認する
c.content.autoplay = False
c.content.notifications.enabled = "ask"

# スムーズスクロール
c.scrolling.smooth = True

# `,e` などで開く外部エディタ (Windows Terminal で PowerShell プロファイルを使用して nvim を起動)
c.editor.command = [
    "wt.exe", "-w", "new", "nt", "-p", "PowerShell",
    "C:/Users/kawasaki/scoop/apps/neovim/current/bin/nvim.exe",
    "{file}", "-c", "normal {line}G{column0}l",
]

# ============================================================
# タブ / UI
# ============================================================
c.tabs.position = "top"
c.tabs.show = "multiple"          # タブが1つのときはタブバーを隠す
c.tabs.title.format = "{audio}{index}: {current_title}"
c.tabs.indicator.width = 0        # 読み込みインジケータ縦線を消す
c.tabs.last_close = "close"       # 最後のタブを閉じたらウィンドウを閉じる

c.statusbar.show = "always"
c.completion.height = "40%"
c.completion.shrink = True

# ダークモードをサイト側に伝える (対応サイトはダーク配色になる)
c.colors.webpage.preferred_color_scheme = "dark"

# ============================================================
# フォント
# ============================================================
c.fonts.default_family = "JetBrainsMono NF"
c.fonts.default_size = "11pt"
c.fonts.web.family.fixed = "JetBrainsMono NF"

# ヒント (fキーで表示される文字) を大きくする
c.fonts.hints = f"bold 16pt {c.fonts.default_family}"

# キーヒント、ステータスバー、補完画面の文字も少し大きく見やすくする
c.fonts.keyhint = f"13pt {c.fonts.default_family}"
c.fonts.statusbar = f"13pt {c.fonts.default_family}"
c.fonts.completion.entry = f"13pt {c.fonts.default_family}"
c.fonts.completion.category = f"bold 13pt {c.fonts.default_family}"

# ============================================================
# 配色: Catppuccin Mocha
# https://catppuccin.com/palette (Mocha)
# ============================================================
mocha = {
    "rosewater": "#f5e0dc",
    "flamingo": "#f2cdcd",
    "pink": "#f5c2e7",
    "mauve": "#cba6f7",
    "red": "#f38ba8",
    "maroon": "#eba0ac",
    "peach": "#fab387",
    "yellow": "#f9e2af",
    "green": "#a6e3a1",
    "teal": "#94e2d5",
    "sky": "#89dceb",
    "sapphire": "#74c7ec",
    "blue": "#89b4fa",
    "lavender": "#b4befe",
    "text": "#cdd6f4",
    "subtext1": "#bac2de",
    "subtext0": "#a6adc8",
    "overlay2": "#9399b2",
    "overlay1": "#7f849c",
    "overlay0": "#6c7086",
    "surface2": "#585b70",
    "surface1": "#45475a",
    "surface0": "#313244",
    "base": "#1e1e2e",
    "mantle": "#181825",
    "crust": "#11111b",
}

# --- 補完ウィンドウ ---
c.colors.completion.fg = mocha["text"]
c.colors.completion.odd.bg = mocha["base"]
c.colors.completion.even.bg = mocha["mantle"]
c.colors.completion.category.fg = mocha["mauve"]
c.colors.completion.category.bg = mocha["crust"]
c.colors.completion.category.border.top = mocha["crust"]
c.colors.completion.category.border.bottom = mocha["crust"]
c.colors.completion.item.selected.fg = mocha["crust"]
c.colors.completion.item.selected.bg = mocha["mauve"]
c.colors.completion.item.selected.border.top = mocha["mauve"]
c.colors.completion.item.selected.border.bottom = mocha["mauve"]
c.colors.completion.item.selected.match.fg = mocha["crust"]
c.colors.completion.match.fg = mocha["peach"]
c.colors.completion.scrollbar.fg = mocha["overlay0"]
c.colors.completion.scrollbar.bg = mocha["mantle"]

# --- ステータスバー ---
c.colors.statusbar.normal.fg = mocha["text"]
c.colors.statusbar.normal.bg = mocha["mantle"]
c.colors.statusbar.insert.fg = mocha["crust"]
c.colors.statusbar.insert.bg = mocha["green"]
c.colors.statusbar.passthrough.fg = mocha["crust"]
c.colors.statusbar.passthrough.bg = mocha["sky"]
c.colors.statusbar.command.fg = mocha["text"]
c.colors.statusbar.command.bg = mocha["mantle"]
c.colors.statusbar.caret.fg = mocha["crust"]
c.colors.statusbar.caret.bg = mocha["pink"]
c.colors.statusbar.caret.selection.fg = mocha["crust"]
c.colors.statusbar.caret.selection.bg = mocha["mauve"]
c.colors.statusbar.private.fg = mocha["subtext1"]
c.colors.statusbar.private.bg = mocha["crust"]
c.colors.statusbar.url.fg = mocha["text"]
c.colors.statusbar.url.success.https.fg = mocha["green"]
c.colors.statusbar.url.success.http.fg = mocha["yellow"]
c.colors.statusbar.url.error.fg = mocha["red"]
c.colors.statusbar.url.warn.fg = mocha["peach"]
c.colors.statusbar.url.hover.fg = mocha["sapphire"]
c.colors.statusbar.progress.bg = mocha["mauve"]

# --- タブバー ---
c.colors.tabs.bar.bg = mocha["crust"]
c.colors.tabs.odd.fg = mocha["subtext0"]
c.colors.tabs.odd.bg = mocha["crust"]
c.colors.tabs.even.fg = mocha["subtext0"]
c.colors.tabs.even.bg = mocha["crust"]
c.colors.tabs.selected.odd.fg = mocha["text"]
c.colors.tabs.selected.odd.bg = mocha["surface0"]
c.colors.tabs.selected.even.fg = mocha["text"]
c.colors.tabs.selected.even.bg = mocha["surface0"]
c.colors.tabs.pinned.odd.fg = mocha["subtext0"]
c.colors.tabs.pinned.odd.bg = mocha["crust"]
c.colors.tabs.pinned.even.fg = mocha["subtext0"]
c.colors.tabs.pinned.even.bg = mocha["crust"]
c.colors.tabs.pinned.selected.odd.fg = mocha["text"]
c.colors.tabs.pinned.selected.odd.bg = mocha["surface0"]
c.colors.tabs.pinned.selected.even.fg = mocha["text"]
c.colors.tabs.pinned.selected.even.bg = mocha["surface0"]

# --- ヒント (f キーのリンク選択ラベル) ---
c.colors.hints.fg = mocha["crust"]
c.colors.hints.bg = mocha["peach"]
c.colors.hints.match.fg = mocha["surface2"]
c.hints.border = "1px solid " + mocha["crust"]

# --- メッセージ / プロンプト ---
c.colors.messages.error.fg = mocha["crust"]
c.colors.messages.error.bg = mocha["red"]
c.colors.messages.error.border = mocha["red"]
c.colors.messages.warning.fg = mocha["crust"]
c.colors.messages.warning.bg = mocha["peach"]
c.colors.messages.warning.border = mocha["peach"]
c.colors.messages.info.fg = mocha["text"]
c.colors.messages.info.bg = mocha["mantle"]
c.colors.messages.info.border = mocha["mantle"]
c.colors.prompts.fg = mocha["text"]
c.colors.prompts.bg = mocha["mantle"]
c.colors.prompts.border = "1px solid " + mocha["surface0"]
c.colors.prompts.selected.fg = mocha["crust"]
c.colors.prompts.selected.bg = mocha["mauve"]

# --- ダウンロードバー / キーヒント / コンテキストメニュー ---
c.colors.downloads.bar.bg = mocha["crust"]
c.colors.downloads.start.fg = mocha["crust"]
c.colors.downloads.start.bg = mocha["blue"]
c.colors.downloads.stop.fg = mocha["crust"]
c.colors.downloads.stop.bg = mocha["green"]
c.colors.downloads.error.fg = mocha["red"]
c.colors.keyhint.fg = mocha["text"]
c.colors.keyhint.suffix.fg = mocha["peach"]
c.colors.keyhint.bg = mocha["mantle"]
c.colors.contextmenu.menu.fg = mocha["text"]
c.colors.contextmenu.menu.bg = mocha["base"]
c.colors.contextmenu.selected.fg = mocha["crust"]
c.colors.contextmenu.selected.bg = mocha["mauve"]
c.colors.contextmenu.disabled.fg = mocha["overlay0"]
c.colors.contextmenu.disabled.bg = mocha["base"]

# ============================================================
# エイリアス
# ============================================================
c.aliases = {
    "q": "quit",
    "w": "session-save",
    "wq": "quit --save",
    "badd": "spawn --userscript C:/Users/kawasaki/AppData/Roaming/qutebrowser/userscripts/qute-bookmark.bat",
    "qadd": "spawn --userscript C:/Users/kawasaki/AppData/Roaming/qutebrowser/userscripts/qute-quickmark.bat",
    "raindrop-save": 'jseval (function(){var rspW=450,rspH=600,rspL=parseInt((screen.width/2)-(rspW/2)),rspT=parseInt((screen.height/2)-(rspH/2));window.open("https://app.raindrop.io/add?link="+encodeURIComponent(window.location.href)+"&title="+encodeURIComponent(document.title),"raindrop","width="+rspW+",height="+rspH+",top="+rspT+",left="+rspL+",toolbar=no,location=no,status=no,menubar=no,scrollbars=yes,resizable=yes");})()',
    "g": "open -t g",
    "yh-save": "spawn --userscript C:/Users/kawasaki/AppData/Roaming/qutebrowser/userscripts/qute-yank-h2.bat",
}

# ============================================================
# キーバインド (デフォルトへの追加・上書きのみ)
# ============================================================
# J / K でタブ移動 (vim のバッファ移動感覚)
config.bind("J", "tab-next")
config.bind("K", "tab-prev")

# xb でステータスバー、xt でタブバーの表示を切り替え
config.bind("xb", "config-cycle statusbar.show always never")
config.bind("xt", "config-cycle tabs.show multiple never")

# M でカスタムブックマーク追加コマンドを開く (引数にタグを指定可能)
config.bind("M", "cmd-set-text -s :badd ")

# [ / ] でタブ移動、{ / } でタブの順番を左右へ移動
config.bind('[', 'tab-prev')
config.bind(']', 'tab-next')
config.bind('{', 'tab-move -')
config.bind('}', 'tab-move +')

# m でカスタムクイックマーク追加コマンドを開く (引数にタグを指定可能)
config.bind("m", "cmd-set-text -s :qadd ")

# gr で現在のページを Raindrop.io に保存する新規タブを開く
config.bind('gr', 'open -t https://app.raindrop.io/add?link={url}&title={title}')

# gR でヒント表示されたリンク先を Raindrop.io に保存する新規タブを開く (※ f から始まるキーはデフォルトのヒント機能と競合するため gR を使用)
config.bind('gR', 'hint links run open -t https://app.raindrop.io/add?link={hint-url}')

# gq でクイックマークの一覧画面を開く
config.bind('gq', 'bookmark-list -q')

# スクロール時のヌルッとした滑り（スムーズスクロール）を無効にし、遅延なく即座に動くようにする
c.scrolling.smooth = False

# u キーを Vim の Ctrl-u のように画面半分スクロール（上がる）に設定
config.bind('u', 'scroll-page 0 -0.5')

# + / - / = キーによるズーム動作を明示的に定義 (キーボードレイアウト等による誤動作を防ぐため)
config.bind('+', 'zoom-in')
config.bind('-', 'zoom-out')
config.bind('=', 'zoom')

# yh で現在の「## タイトル」と「URL」（改行区切り）をヤンクする
config.bind('yh', 'yh-save')

# Ctrl + PgDn / PgUp で細かく（150pxずつ）上下スクロールする
config.bind('<Ctrl-PgDown>', 'scroll-px 0 150')
config.bind('<Ctrl-PgUp>', 'scroll-px 0 -150')

# ChatGPTなど、左サイドバー内からcaretが抜けにくいページ用。
# cvでcaretモードへ入り、main本文の最初の表示テキストへcaretを置く。
# その後vで範囲選択を開始し、yでコピーする。
chat_main_caret = r'''(function(){
  const root = document.querySelector('main,[role="main"]');
  if (!root) return 'main not found';
  const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, {
    acceptNode(node) {
      if (!node.textContent.trim()) return NodeFilter.FILTER_REJECT;
      const element = node.parentElement;
      if (!element || element.closest('[aria-hidden="true"],script,style')) return NodeFilter.FILTER_REJECT;
      const style = getComputedStyle(element);
      return style.display === 'none' || style.visibility === 'hidden'
        ? NodeFilter.FILTER_REJECT : NodeFilter.FILTER_ACCEPT;
    }
  });
  const node = walker.nextNode();
  if (!node) return 'text not found';
  const range = document.createRange();
  range.setStart(node, 0);
  range.collapse(true);
  const selection = getSelection();
  selection.removeAllRanges();
  selection.addRange(range);
  node.parentElement.scrollIntoView({block:'center'});
  return 'ok';
})()'''.replace('\n', ' ')
config.bind('cv', f'mode-enter caret ;; jseval --quiet {chat_main_caret}')
