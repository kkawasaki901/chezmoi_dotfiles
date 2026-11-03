return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  config = function()
    -- setup()で指定できる共通項目:
    -- parser_install_dir: parserの保存先。指定時はruntimepathにも追加する。
    -- ensure_installed: 自動導入する言語名の配列、または"all"。
    -- sync_install: ensure_installedを同期インストールするか。
    -- auto_install: bufferを開いた時に不足parserを導入するか。
    -- ignore_install: "all"指定時でも導入しない言語。
    -- modules: 外部Treesitter moduleを手動登録するためのテーブル。
    -- 各module共通: enable、disable（言語配列または関数）。
    -- highlight固有: additional_vim_regex_highlighting（booleanまたは言語配列）。
    -- 現在のcheckoutに含まれる標準moduleはhighlightのみ。外部moduleは任意キーを追加できる。
    require("nvim-treesitter.configs").setup({
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "org" },
      },
    })
  end,
}
