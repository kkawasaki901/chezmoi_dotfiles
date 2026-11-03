return {
  "nvim-orgmode/org-bullets.nvim",
  dependencies = { "nvim-orgmode/orgmode" },
  opts = {
    -- symbols = {                           -- 表示記号。各項目をfalseにすると無効化。
    --   list = "•",                        -- 箇条書き記号。string|false。
    --   headlines = { "◉", "○", "✸", "✿" }, -- 見出しレベル別。配列|変換関数|false。
    --   checkboxes = {                      -- {表示文字, highlight} の組。
    --     half = { "", "@org.checkbox.halfchecked" },
    --     done = { "✓", "@org.keyword.done" },
    --     todo = { "˟", "@org.keyword.todo" },
    --   },
    -- },
    -- indent = true,       -- 見出し記号をレベルに合わせて字下げする。
    -- concealcursor = false, -- cursor行でも記号をconcealする。
  },
}
