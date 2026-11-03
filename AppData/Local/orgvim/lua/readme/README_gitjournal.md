# gitjournal.nvim (minimal local GitJournal-style notes)

- Single-file Neovim plugin to append notes into daily Markdown files.
- Creates/updates YAML front matter with `created` and `modified` timestamps.
- Opens a floating window for quick entry; close with `:q` to append.

## Install

Place this repo on your `runtimepath` (e.g., `~/.config/nvim/pack/plugins/start/gitjournal/`) or use a plugin manager.

Lazy.nvim example (local path):

```lua
{
  dir = vim.fn.stdpath('config') .. '/pack/plugins/start/gitjournal',
  name = 'gitjournal.nvim',
}
```

Or as a local plugin with any manager that supports `dir`.

## Setup

Set your journal directory (created if missing):

```vim
:GitJournalSetDir ~/Journal
```

Or in your config:

```lua
vim.g.gitjournal_dir = vim.fn.expand('~/Journal')
```

## Usage

- `:GitJournalNote` – open a popup to type a memo; close with `:q` to append.
- On first write of the day, file `YYYY-MM-DD.md` is created with front matter:

```yaml
---
created: 2026-02-18T00:28:07+09:00
modified: 2026-02-18T01:13:41+09:00
---
```

- Each appended entry:
  - 1st line: current time, e.g., `15:34:00`
  - Following lines: your memo
  - `modified` is updated each append

## Default Keymap

The plugin sets simple default mappings:

```text
<leader>jn  ->  :GitJournalNote
<leader>jl  ->  :GitJournalList
```

Disable it in your config if you prefer your own mappings:

```lua
vim.g.gitjournal_default_keymaps = false
```

Example custom keymap:

```lua
vim.keymap.set('n', '<leader>jn', ':GitJournalNote<CR>', { silent = true, desc = 'GitJournal: New note' })
vim.keymap.set('n', '<leader>jl', ':GitJournalList<CR>', { silent = true, desc = 'GitJournal: List journals' })
```

## Tips

- Pair the directory with a Git repo if you want history (`git init` in the folder).
- Consider adding the journal directory to your backups or cloud sync.

## Commands

- `:GitJournalSetDir <path>` – set journal directory.
- `:GitJournalNote` – open popup, append on `:q`.
- `:GitJournalOpenToday [edit|split|vsplit|tab]` – open or create today’s `YYYY-MM-DD.md` with the chosen window method (default `edit`).
- `:GitJournalList [edit|split|vsplit|tab]` – show a simple picker of existing journal files and open the selection with the chosen method.

Examples:

```vim
:GitJournalOpenToday         " open in current window (edit)
:GitJournalOpenToday split   " horizontal split
:GitJournalOpenToday vsplit  " vertical split
:GitJournalOpenToday tab     " new tab
"
:GitJournalList              " list and open in current window
:GitJournalList split        " list and open in horizontal split
```
