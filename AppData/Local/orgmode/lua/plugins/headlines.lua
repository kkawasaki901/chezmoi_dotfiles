return {
  "lukas-reineke/headlines.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {
    org = {
      -- org（およびmarkdown/rmd/norg）で指定できる全項目:
      -- query: 対象を抽出するvim.treesitter.Query。
      -- treesitter_language: filetypeとparser言語が異なる場合の言語名。
      -- headline_highlights: 見出しレベル別highlight配列。
      -- bullet_highlights: bulletレベル別highlight配列。
      -- bullets: 見出し先頭に表示する記号配列。
      -- codeblock_highlight: code block背景のhighlight名。
      -- dash_highlight / dash_string: 区切り線のhighlightと表示文字。
      -- quote_highlight / quote_string: 引用のhighlightと表示文字。
      -- fat_headlines: 見出し上下に装飾行を描画するか。
      -- fat_headline_upper_string / fat_headline_lower_string: 上下装飾文字。
      headline_highlights = {
        "Headline1", "Headline2", "Headline3",
        "Headline4", "Headline5", "Headline6",
      },
    },
  },
}
