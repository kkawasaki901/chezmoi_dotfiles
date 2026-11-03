-- Neovide configuration
-- 公式ドキュメント: https://neovide.dev/configuration.html
--
-- 使い方:
--   1. 変更したい設定行の先頭にある「--」を削除する
--   2. Neovideを再起動する
--
-- このファイルは通常のNeovimでも読み込まれますが、Neovide以外では何もしません。
if not vim.g.neovide then
  return
end

-- ============================================================================
-- 表示
-- ============================================================================

-- 使用フォント。フォント名、フォールバック、サイズなどを指定する。
-- 例: "Hack,Noto Color Emoji:h14"、太字は :b、斜体は :i。
-- vim.o.guifont = "Source Code Pro:h14"

-- 行間。負の値も指定できる。
-- vim.opt.linespace = 0

-- フォント定義を変えずに画面全体を拡大・縮小する倍率。
-- vim.g.neovide_scale_factor = 1.0

-- 文字描画のガンマとコントラスト。
-- ガンマ0.0は標準sRGB。Alacritty風の例は gamma=0.8、contrast=0.1。
-- vim.g.neovide_text_gamma = 0.0
-- vim.g.neovide_text_contrast = 0.5

-- モニターのサブピクセル配置。通常の横置きモニターは "RGBH" が多い。
-- 候補: "RGBH", "BGRH", "RGBV", "BGRV", "Unknown"
-- vim.g.neovide_pixel_geometry = "RGBH"

-- ウィンドウ端とNeovim描画領域の余白。
-- vim.g.neovide_padding_top = 0
-- vim.g.neovide_padding_bottom = 0
-- vim.g.neovide_padding_right = 0
-- vim.g.neovide_padding_left = 0

-- タイトルバー背景色と文字色（Windowsのみ）。
-- CSSで解釈できる色名や16進色を指定できる。
-- vim.g.neovide_title_background_color = "green"
-- vim.g.neovide_title_text_color = "pink"

-- カラースキームのNormal背景色をタイトルバーへ適用する例（Windowsのみ）。
-- vim.g.neovide_title_background_color = string.format(
--   "%x",
--   vim.api.nvim_get_hl(0, { id = vim.api.nvim_get_hl_id_by_name("Normal") }).bg
-- )

-- ウィンドウ角の形（Windowsのみ）。
-- 候補: "default", "round", "round_small", "do_not_round"
-- vim.g.neovide_corner_preference = "round"

-- ウィンドウ背景をぼかす（macOSのみ）。ぼかし量は opacity に従う。
-- vim.g.neovide_window_blurred = true

-- フローティングウィンドウの横・縦方向のぼかし半径。
-- vim.g.neovide_floating_blur_amount_x = 2.0
-- vim.g.neovide_floating_blur_amount_y = 2.0

-- フローティングウィンドウの影を有効化する。
-- vim.g.neovide_floating_shadow = true

-- フローティングウィンドウの仮想的な高さ。
-- vim.g.neovide_floating_z_height = 10

-- 影を作る光源の角度。
-- vim.g.neovide_light_angle_degrees = 45

-- 影を作る光源の半径。
-- vim.g.neovide_light_radius = 5

-- フローティングウィンドウの角丸。0.0で無効、0.0～1.0で指定する。
-- vim.g.neovide_floating_corner_radius = 0.0

-- ウィンドウ全体の不透明度。0.0（透明）～1.0（不透明）。
-- vim.g.neovide_opacity = 0.8

-- Normal背景色の不透明度。1.0にすると背景透過を無効化する。
-- vim.g.neovide_normal_opacity = 0.8

-- 不透明ウィンドウの周囲に灰色の枠を描く（macOSのみ、既定値 true）。
-- vim.g.neovide_show_border = true

-- 分割などでウィンドウ位置が変わる際のアニメーション秒数。0で無効。
-- vim.g.neovide_position_animation_length = 0.15

-- スクロールアニメーションの秒数。
-- vim.g.neovide_scroll_animation_length = 0.3

-- 1画面以上スクロールした際、末尾何行をアニメーションするか。
-- 0で即時移動、9999など大きな値で全範囲をアニメーションする。
-- vim.g.neovide_scroll_animation_far_lines = 1

-- 処理中にプログレスバーを表示する。
-- vim.g.neovide_progress_bar_enabled = true

-- プログレスバーの高さ（ピクセル）。
-- vim.g.neovide_progress_bar_height = 5.0

-- プログレスバーのアニメーション速度。
-- vim.g.neovide_progress_bar_animation_speed = 200.0

-- 100%到達後にプログレスバーを隠すまでの秒数。
-- vim.g.neovide_progress_bar_hide_delay = 0.2

-- キー入力を始めたらマウスポインターを隠す。
-- vim.g.neovide_hide_mouse_when_typing = false

-- :messages やシェル出力などのメッセージ領域でドラッグ選択を許可する。
-- vim.g.neovide_message_area_drag_selection = false

-- 下線、波線、破線などの太さ倍率。大きすぎる値では表示が欠ける場合がある。
-- vim.g.neovide_underline_stroke_scale = 1.0

-- OSウィンドウのテーマ。
-- 候補: "auto", "light", "dark", "bg_color"
-- vim.g.neovide_theme = "auto"

-- 連続する描画レイヤーをまとめ、影やぼかしの乱れを軽減する実験的設定。
-- 別の描画問題を起こす可能性がある。
-- vim.g.experimental_layer_grouping = false

-- ============================================================================
-- 動作
-- ============================================================================

-- 描画リフレッシュレート。--no-vsync で起動した場合のみ有効。
-- vim.g.neovide_refresh_rate = 60

-- Neovideが非アクティブなときのリフレッシュレート。
-- vim.g.neovide_refresh_rate_idle = 5

-- 常時再描画する。アニメーションが途中で止まる場合の回避策。
-- vim.g.neovide_no_idle = true

-- 未保存の変更がある状態で終了するとき確認する（既定で有効）。
-- vim.g.neovide_confirm_quit = true

-- リモートNeovim接続時の終了動作。
-- 候補: "always_quit", "always_detach", "prompt"
-- vim.g.neovide_detach_on_quit = "always_quit"

-- ウィンドウフルスクリーンを有効化する。
-- vim.g.neovide_fullscreen = true

-- Dockとメニューバーを隠す簡易フルスクリーン（macOSのみ）。
-- vim.g.neovide_macos_simple_fullscreen = true

-- 前回終了時のウィンドウサイズを次回起動時に復元する。
-- コマンドラインの --size が指定された場合はそちらが優先される。
-- vim.g.neovide_remember_window_size = true

-- 左上にフレーム時間のグラフを表示するプロファイラー。
-- vim.g.neovide_profiler = false

-- カーソルが意図せずコマンドラインへ点滅移動する問題を抑える。
-- 逆に移動を妨げる場合は false を試す。
-- vim.g.neovide_cursor_hack = true

-- 対応する括弧をOSの検索インジケーターで強調する（macOSのみ）。
-- vim.g.neovide_highlight_matching_pair = true

-- 現在のファイルをタイトルバーのプロキシアイコンとして表示する（macOSのみ）。
-- vim.g.neovide_proxy_icon = true

-- ============================================================================
-- 入力
-- ============================================================================

-- macOSのOptionキーをMetaキーとして扱う。
-- 候補: "both", "only_left", "only_right", "none"
-- vim.g.neovide_input_macos_option_key_is_meta = "only_left"

-- IME入力を有効化する。
-- vim.g.neovide_input_ime = true

-- 挿入モードと検索コマンドラインのときだけIMEを有効にする例。
-- 使用する場合は、このブロック全体の各行から「--」を削除する。
-- local function set_ime(args)
--   vim.g.neovide_input_ime = args.event:match("Enter$") ~= nil
-- end
--
-- local ime_input = vim.api.nvim_create_augroup("ime_input", { clear = true })
--
-- vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
--   group = ime_input,
--   pattern = "*",
--   callback = set_ime,
-- })
--
-- vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineLeave" }, {
--   group = ime_input,
--   pattern = "[/\\?]",
--   callback = set_ime,
-- })

-- タップとスクロールを区別する移動距離（ピクセル）。
-- 負の値ではタップ判定を無効化し、すべてスクロールとして扱う。
-- vim.g.neovide_touch_deadzone = 6.0

-- タッチ操作がドラッグ選択に切り替わるまでの秒数。
-- vim.g.neovide_touch_drag_timeout = 0.17

-- ============================================================================
-- カーソル
-- ============================================================================

-- カーソル移動アニメーションの秒数。0で無効。
-- vim.g.neovide_cursor_animation_length = 0.150

-- 1～2文字程度の短い横移動に使うアニメーション秒数。
-- vim.g.neovide_cursor_short_animation_length = 0.04

-- カーソル軌跡の長さ。0.0～1.0。
-- 1.0では先端が即座に移動して軌跡が最大になり、小さいほど滑らかだが遅延が増える。
-- vim.g.neovide_cursor_trail_size = 1.0

-- カーソルのアンチエイリアスを有効化する。
-- vim.g.neovide_cursor_antialiasing = true

-- 挿入モード中もカーソル移動をアニメーションする。
-- vim.g.neovide_cursor_animate_in_insert_mode = true

-- エディター領域とコマンドライン間の移動をアニメーションする。
-- vim.g.neovide_cursor_animate_command_line = true

-- 非アクティブ時に表示するブロックカーソル輪郭の幅（em）。
-- 0以下ではカーソルが見えなくなる。
-- vim.g.neovide_cursor_unfocused_outline_width = 0.125

-- カーソル点滅を滑らかにアニメーションする。
-- guicursor に blinkoff、blinkon、blinkwait の設定が必要。
-- vim.g.neovide_cursor_smooth_blink = false

-- guicursorに色指定がない場合、カーソル下のセル色を代替色として使う。
-- vim.g.neovide_cursor_cell_color_fallback = false

-- ============================================================================
-- カーソルのパーティクル効果
-- ============================================================================

-- パーティクル効果。空文字列で無効。
-- 候補: "", "railgun", "torpedo", "pixiedust", "sonicboom", "ripple", "wireframe"
-- 文字列1つ、または複数効果の配列を指定できる。
-- vim.g.neovide_cursor_vfx_mode = ""
-- vim.g.neovide_cursor_vfx_mode = { "railgun", "ripple" }

-- パーティクルの不透明度。
-- vim.g.neovide_cursor_vfx_opacity = 200.0

-- 通常パーティクルの寿命（秒）。
-- vim.g.neovide_cursor_vfx_particle_lifetime = 0.5

-- sonicboom、ripple、wireframe用の強調パーティクル寿命（秒）。
-- 0の場合は通常パーティクルの寿命を使う。
-- vim.g.neovide_cursor_vfx_particle_highlight_lifetime = 0.2

-- 移動1行あたりに生成するパーティクル密度。
-- vim.g.neovide_cursor_vfx_particle_density = 0.7

-- パーティクルの移動速度（ピクセル/秒）。
-- vim.g.neovide_cursor_vfx_particle_speed = 10.0

-- railgun専用。粒子群の動きのばらつき。
-- 大きいほど個別に動き、小さいほど線状にまとまる。
-- vim.g.neovide_cursor_vfx_particle_phase = 1.5

-- railgun専用。粒子の速度方向が回転する強さ。
-- vim.g.neovide_cursor_vfx_particle_curl = 1.0

-- ============================================================================
-- 自動検出・デバッグ用
-- ============================================================================

-- マウスグリッド検出。Neovim 0.12.0以降が必要。
-- 対応していないNeovimでは動作未定義のため、通常は自動検出に任せる。
-- vim.g.neovide_has_mouse_grid_detection = true

-- ============================================================================
-- config.toml / 環境変数でのみ設定する項目（macOS）
-- ============================================================================

-- 以下はLuaの vim.g では設定せず、Neovideの config.toml または環境変数を使う。
-- 参考用としてここにまとめている。

-- 複数ウィンドウをmacOSネイティブタブへまとめる:
-- system-native-tabs = true

-- グローバル起動ショートカット:
-- system-pinned-hotkey = "ctrl+shift+z"
-- system-switcher-hotkey = "ctrl+shift+n"

-- macOSアプリケーションメニューのショートカット:
-- system-hide-hotkey = "cmd+h"
-- system-hide-others-hotkey = "cmd+alt+h"
-- system-quit-hotkey = "cmd+q"
-- system-new-window-hotkey = "cmd+n"
-- system-minimize-hotkey = "cmd+m"
-- system-fullscreen-hotkey = "cmd+ctrl+f"
-- system-show-all-tabs-hotkey = "cmd+shift+e"

-- ネイティブタブの前後移動:
-- system-tab-prev-hotkey = "cmd+shift+["
-- system-tab-next-hotkey = "cmd+shift+]"

-- グローバル起動ショートカットを環境変数で設定する例:
-- launchctl setenv NEOVIDE_SYSTEM_PINNED_HOTKEY "ctrl+shift+z"
-- launchctl setenv NEOVIDE_SYSTEM_SWITCHER_HOTKEY "ctrl+shift+n"

-- 補足:
-- g:neovide_background_color はNeovide 0.16.0で削除されており、設定しても効果がない。
-- 背景透過には neovide_opacity と neovide_normal_opacity を使用する。
